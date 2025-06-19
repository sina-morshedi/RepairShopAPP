import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CropImagePage(),
    );
  }
}

class CropImagePage extends StatefulWidget {
  const CropImagePage({super.key});

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  final CropController _controller = CropController();
  Uint8List? _imageData;
  Uint8List? _croppedData;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? imageFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      setState(() {
        _imageData = bytes;
        _croppedData = null;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Your Image Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickImage,
          ),
          if (_imageData != null)
            IconButton(
              icon: const Icon(Icons.crop),
              onPressed: () {
                _controller.crop();
              },
            ),
        ],
      ),
      body: Center(
        child: _imageData == null
            ? const Text('Select an image from gallery')
            : _croppedData != null
            ? Image.memory(_croppedData!)
            : Crop(
          image: _imageData!,
          controller: _controller,
          onCropped: (image) {
            // do something with image data
          },
          interactive: true,
          aspectRatio: 1,
          baseColor: Colors.black.withOpacity(0.5),
          maskColor: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}
