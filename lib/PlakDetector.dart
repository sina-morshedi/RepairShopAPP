import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

List<CameraDescription> cameras = [];

class PlakDetector extends StatelessWidget {
  const PlakDetector({super.key});
  @override
  Widget build(BuildContext context) {
    return const OCRFromAsset();
  }
}

class OCRFromAsset extends StatefulWidget {
  const OCRFromAsset({super.key});

  @override
  State<OCRFromAsset> createState() => _OCRFromAssetState();
}

class _OCRFromAssetState extends State<OCRFromAsset> {
  String _extractedText = '';
  bool _isLoading = false;
  File? _imageFile;
  DateTime? selectedDateTime;

  List<List<TextEditingController>> controllers = [];
  final TextEditingController dateTextController = TextEditingController();
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
  List<Map<String, String>> dataCarInfo = [];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> saveCarInfo() async {
    Map<String, String> data = {};

    setState(() {
      for (int i = 0; i < tag_text.length; i++) {
        data[tag_text[i]] = controllers[i][0].text;
      }
    });
    print(data);
    bool success = await saveTaggedStrings(data);

    if (!success) {
      Fluttertoast.showToast(
        msg: "Bu Plaka zaten mevcut! Lütfen benzersiz bir Plaka girin.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> loadCarInfo() async {
    dataCarInfo = await readTaggedStrings();
    print(dataCarInfo);
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tagged_strings.json');
  }

  Future<void> deleteJsonFile() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
        print('File deleted successfully.');
      } else {
        print('File does not exist.');
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  Future<bool> saveTaggedStrings(Map<String, String> newTaggedStrings) async {
    final file = await _localFile;

    List<Map<String, String>> dataList = [];
    print(newTaggedStrings);

    if (await file.exists()) {
      try {
        final contents = await file.readAsString();
        if (contents.trim().isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(contents);

          dataList = jsonList
              .map(
                (item) => Map<String, String>.from(
                  item.map(
                    (key, value) => MapEntry(key.toString(), value.toString()),
                  ),
                ),
              )
              .toList();

          String newTag = newTaggedStrings["PLAKA"] ?? "";
          bool tagExists = dataList.any(
            (element) => element["PLAKA"] == newTag,
          );

          if (tagExists) {
            print('Duplicate tag found: $newTag');
            return false;
          }
        }
      } catch (e) {
        print('Error reading or parsing file: $e');
      }
    }

    dataList.add(newTaggedStrings);
    final jsonString = jsonEncode(dataList);
    await file.writeAsString(jsonString);
    return true;
  }

  Future<List<Map<String, String>>> readTaggedStrings() async {
    try {
      final file = await _localFile;
      String jsonString = await file.readAsString();

      List<dynamic> jsonList = jsonDecode(jsonString);

      // Convert each item in the list to Map<String, String>
      return jsonList
          .whereType<Map>() // make sure each item is a map
          .map(
            (item) => item.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          )
          .toList();
    } catch (e) {
      print('Error reading file: $e');
      return [];
    }
  }

  Future<void> _processAssetImage() async {
    setState(() {
      _isLoading = true;
    });

    final byteData = await rootBundle.load('assets/images/RBSN.jpg');

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/temp_image.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    setState(() {
      _imageFile = file;
    });

    final inputImage = InputImage.fromFile(file);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      _extractedText = recognizedText.text;
      _isLoading = false;
      print(_extractedText);
      List<String> lines = _extractedText.split('\n');

      for (int k = 0; k < keyword.length; k++) {
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].contains(keyword[k])) {
            // Check if there's a next line
            if (i + 1 < lines.length) {
              print('The word "${keyword[k]}" was found.');
              print('Next line: ${lines[i + 1]}');
              controllers[k][0].text = lines[i + 1];
            } else {
              print(
                'The word "$keyword" was found on the last line. No next line available.',
              );
            }
            break; // Remove this if you want to find all occurrences
          }
        }
      }
    });

    textRecognizer.close();
  }

  Future<void> pickDateTime(BuildContext context) async {
    // Show date picker
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    // Show time picker
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    // Combine date and time into a single DateTime
    final DateTime dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    selectedDateTime = dateTime;

    // Convert to formatted string
    final String formattedDateTime = DateFormat('yyyy-MM-dd – HH:mm').format(dateTime);
    print('Selected date and time: $formattedDateTime');
  }
  final int rowCount = 7;
  final int columnCount = 1;

  List<String> labelText = [
    "PLAKA",
    "MARKASI",
    "TİCARİ ADI",
    "MODEL YILI",
    "YAKIT CİNSİ",
    "MOTOR NO",
    "ŞASE NO",
  ];
  @override
  void initState() {
    super.initState();

    // Get current date and time
    final DateTime now = DateTime.now();       // ✅ Correct way
    final TimeOfDay time = TimeOfDay.now();    // ✅ For time only

    //TODO Image process
    // Run asset image processing
    // _processAssetImage();

    // Initialize controllers
    for (int i = 0; i < rowCount; i++) {
      List<TextEditingController> rowControllers = [];
      for (int j = 0; j < columnCount; j++) {
        rowControllers.add(TextEditingController(text: "?"));
      }
      controllers.add(rowControllers);
    }

    // Combine date and time
    final DateTime dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    selectedDateTime = dateTime;
    dateTextController.text = DateFormat('yyyy-MM-dd – HH:mm').format(selectedDateTime!);
  }


  @override
  void dispose() {
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    dateTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: null,
              icon: Icon(Icons.camera_alt),
              label: Text('Take Picture'),
            ),
            SizedBox(
              height: 100,
              child: TextField(
                controller: TextEditingController(text: _extractedText),
                readOnly: true,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ruhsat Bilgi',
                  alignLabelWithHint: true,
                  contentPadding: EdgeInsets.all(12),
                ),
                scrollPhysics: const BouncingScrollPhysics(),
              ),
            ),
            // Car Information text Box
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(rowCount, (row) {
                          return Row(
                            children: List.generate(columnCount, (col) {
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(1),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        labelText[row * columnCount + col],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      TextField(
                                        controller: controllers[row][col],
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.white,
                    child: const Text(
                      'Ruhsat Bilgi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenWidth * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),

                      TextField(
                        readOnly: true,
                        controller: dateTextController,
                        onTap: () async {
                          await pickDateTime(context);
                          if (selectedDateTime != null) {
                            dateTextController.text = DateFormat('yyyy-MM-dd – HH:mm').format(selectedDateTime!);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Date & Time',
                          border: OutlineInputBorder(),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 12),
                SizedBox(
                  width: screenWidth * 0.25,
                  child: ElevatedButton(
                    onPressed: () {
                      saveCarInfo();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5F46AA),
                      foregroundColor: Colors.white,
                    ),
                    child: AutoSizeText(
                      'KAYDET',
                      maxLines: 1,
                      style: TextStyle(fontSize: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                SizedBox(
                  width: screenWidth * 0.21,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5F46AA),
                      foregroundColor: Colors.white,
                    ),
                    child: AutoSizeText(
                      'İPTAL',
                      maxLines: 1,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      loadCarInfo();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5F46AA),
                      foregroundColor: Colors.white,
                    ),
                    child: AutoSizeText(
                      'Load',
                      maxLines: 1,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      deleteJsonFile();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5F46AA),
                      foregroundColor: Colors.white,
                    ),
                    child: AutoSizeText(
                      'Reset',
                      maxLines: 1,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class CameraPreviewScreen extends StatefulWidget {
//   const CameraPreviewScreen({super.key});
//   @override
//   State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
// }
//
// class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
//   CameraController? controller;
//
//   @override
//   void initState() {
//     super.initState();
//     if (cameras.isNotEmpty) {
//       controller = CameraController(
//         cameras[0],
//         ResolutionPreset.medium,
//       );
//       controller!.initialize().then((_) {
//         if (!mounted) return;
//         setState(() {});
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (controller == null || !controller!.value.isInitialized) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Arac Plaka')),
//       body: Center(
//         child: AspectRatio(
//           aspectRatio: controller!.value.aspectRatio,
//           child: CameraPreview(controller!),
//         ),
//       ),
//     );
//   }
// }
