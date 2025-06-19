import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final cameras = await availableCameras();  // Access available cameras
//   runApp(MyApp(cameras: cameras));
// }
//
// class MyApp extends StatelessWidget {
//   final List<CameraDescription> cameras;
//   const MyApp({Key? key, required this.cameras}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: CropImage(cameras: cameras),
//     );
//   }
// }

enum CropStage { view, zoom, crop, done }

class CropImage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CropImage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CropImage> createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  final _cropController = CropController();
  Uint8List? _imageData;
  Uint8List? _croppedData;
  Uint8List? _originalImage;
  bool ResetFlag = false;
  List<String> keyword = [
    "PLAKA",
    "MARKASI",
    "CARİ ADI",
    "MODEL YILI",
    "YAKIT",
  ];
  List<String> tag_text = [
    "PLAKA",
    "MARKASI",
    "TİCARİ ADI",
    "MODEL YILI",
    "YAKIT",
  ];

  CropStage _stage = CropStage.view;

  final GlobalKey _zoomKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> recognizeTextFromImageData(Uint8List? imageData) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/temp_image.jpg';
      final file = await File(filePath).writeAsBytes(imageData!);
      final inputImage = InputImage.fromFilePath(file.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      print('[Recognized text]: ${recognizedText.text}');
      textRecognizer.close();
    } catch (e) {
      print('Error recognizing text: $e');
    }
  }

  Future<void> _processAssetImage() async {

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }
  Future<void> _loadImage() async {
    final data = await DefaultAssetBundle.of(context).load('assets/images/camera.png');
    setState(() {
      _imageData = data.buffer.asUint8List();
      // _imageData = _originalImage;  // Save the original image
    });
  }

  void _startZoom() async{
    if (_imageData != null) {
      await recognizeTextFromImageData(_imageData!);
    }
    setState(() {
      _stage = CropStage.zoom;
    });
  }

  Future<void> _finishZoom() async {
    try {
      RenderRepaintBoundary boundary = _zoomKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/zoomed_image.png';
      final file = await File(filePath).writeAsBytes(pngBytes);

      final zoomedImageBytes = await file.readAsBytes();

      setState(() {
        _imageData = zoomedImageBytes;
        _stage = CropStage.crop;
      });
    } catch (e) {
      print("Error capturing zoomed image: $e");
    }
  }

  void _performCrop() {
    _cropController.crop();
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(cameras: widget.cameras),
      ),
    );
    if (result != null && result is Uint8List) {
      setState(() {
        _imageData = result;
        _originalImage = result;  // Save original camera image
        _croppedData = null;
        _stage = CropStage.view;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;
    final heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/Logo.png', fit: BoxFit.cover),
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5F46AA),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20), // ← Distance from AppBar
        child: Column(
          children: [
            Container(
              width: widthScreen * 0.7,
              height: (widthScreen * 0.7) * 1.5,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Builder(
                  builder: (context) {
                    if (_imageData == null) {
                      return const Center(child: Text('Henüz resim yüklenmedi.'));
                    }

                    if (_stage == CropStage.view) {
                      return Image.memory(_imageData!);
                    } else if (_stage == CropStage.zoom) {
                      return RepaintBoundary(
                        key: _zoomKey,
                        child: InteractiveViewer(
                          maxScale: 5,
                          minScale: 1,
                          child: Image.memory(_imageData!),
                        ),
                      );
                    } else if (_stage == CropStage.crop) {
                      return Crop(
                        controller: _cropController,
                        image: _imageData!,
                        onCropped: (croppedResult) {
                          if (croppedResult is CropSuccess) {
                            setState(() {
                              _croppedData = croppedResult.croppedImage;
                              _stage = CropStage.done;
                            });
                          }
                        },
                      );
                    } else {
                      return _croppedData != null
                          ? Image.memory(_croppedData!)
                          : const Text('Kırpılmış görüntü yok');
                    }
                  },
                ),
              ),

            ),

            // 🔵 Buttons are always visible
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _openCamera,
                    child: const Text('Kamerayı aç'),
                  ),
                  const SizedBox(width: 10),
                  if (_imageData != null && _stage == CropStage.view)
                    ElevatedButton(
                      onPressed: _startZoom,
                      child: const Text('Yakınlaştırmayı Başlat'),
                    ),
                  if (_imageData != null && _stage == CropStage.zoom)
                    ElevatedButton(
                      onPressed: _finishZoom,
                      child: const Text('Yakınlaştırmayı bitir'),
                    ),
                  if (_imageData != null && _stage == CropStage.crop)
                    ElevatedButton(
                      onPressed: _performCrop,
                      child: const Text('Resmi Kırp'),
                    ),
                  if (_imageData != null && _stage == CropStage.done)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _stage = CropStage.view;
                          _croppedData = null;
                          ResetFlag = true;

                          if (_originalImage != null) {
                            _imageData = _originalImage;
                          }
                        });
                      },
                      child: const Text('Tekrar başlat'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),


    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isInitialized = false;


  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
      _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isInitialized = true;

        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized) return;
    final image = await _controller.takePicture();
    final bytes = await File(image.path).readAsBytes();

    Navigator.pop(context, bytes);
  }

  @override
  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;
    final heightScreen = MediaQuery.of(context).size.height;

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/Logo.png', fit: BoxFit.cover),
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5F46AA),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20), // ← Distance from the top
        child: Align(
          alignment: Alignment.topCenter, // ← Align to the top instead of center
          child: Container(
            width: widthScreen * 0.7,
            height: (widthScreen * 0.7) * 1.5,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CameraPreview(_controller),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

}
