import 'package:autonetwork/dboAPI.dart';
import 'package:autonetwork/type.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:autonetwork/Common.dart';


class GetCarInfoApp extends StatefulWidget {
  const GetCarInfoApp({super.key});

  @override
  State<GetCarInfoApp> createState() => _OCRFromAssetState();
}

class _OCRFromAssetState extends State<GetCarInfoApp> {
  DateTime? selectedDateTime;
  List<CameraDescription>? cameras;
  List<List<TextEditingController>> controllers = [];
  final TextEditingController dateTextController = TextEditingController();

  static const List<String> tag_dbo = [
    "chassis_no",
    "motor_no",
    "license_plate",
    "brand",
    "brand_model",
    "model_year",
    "fuel_type",
    "date_time"
  ];
  final int rowCount = tag_dbo.length-1;
  final int columnCount = 1;

  List<String> tag_labelText = [
    "ŞASE NO",
    "MOTOR NO",
    "PLAKA",
    "MARKASI",
    "TİCARİ ADI",
    "MODEL YILI",
    "YAKIT CİNSİ",
  ];

  List<Map<String, String>> dataCarInfo = [];

  List<String> keyword = [
    "PLAKA",
    "MARKASI",
    "CARİ ADI",
    "MODEL YILI",
    "YAKIT",
  ];
  @override
  void initState() {
    super.initState();

    _initCameras();

    // Initialize controllers
    for (int i = 0; i < rowCount; i++) {
      List<TextEditingController> rowControllers = [];
      for (int j = 0; j < columnCount; j++) {
        rowControllers.add(TextEditingController(text: ""));
      }
      controllers.add(rowControllers);
    }

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

  String toUpperIfHasLowerCase(String input) {
    if (input.contains(RegExp(r'[a-z]'))) {
      return input.toUpperCase();
    }
    return input;
  }


  Future<void> saveCarInfo() async {
    Map<String, String> data = {};
    final restrictedIndices = {
      tag_index.chassis_no,
      tag_index.motor_no,
      tag_index.license_plate,
      tag_index.fuel_type,
    };
    int i = 0;
    for (i = 0; i < tag_dbo.length-1; i++) {
      tag_index tag = tag_index.values[i];
      if(tag_index.chassis_no == tag || tag_index.motor_no == tag
          || tag_index.license_plate == tag || tag_index.fuel_type == tag){
        if(controllers[i][0].text.contains(' '))
        {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${tag_labelText[i]}: lütfen ${tag_dbo[i]} kutuya boşluk eklemeyin",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      if(restrictedIndices.contains(i) && int.tryParse(controllers[i][0].text) != null){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${tag_labelText[i]}: Lütfen MODEL YILI kutuya numara giriniz",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if(controllers[i][0].text.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${tag_labelText[i]}: lütfen ekle",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    carInfo car = carInfo(
        chassis_no: controllers[tag_index.chassis_no.index][0].text.trim(),
        motor_no: controllers[tag_index.motor_no.index][0].text.trim(),
        license_plate: controllers[tag_index.license_plate.index][0].text.trim(),
        brand: controllers[tag_index.brand.index][0].text.trim(),
        brand_model: controllers[tag_index.brand_model.index][0].text.trim(),
        model_year: int.tryParse(controllers[tag_index.model_year.index][0].text.trim()) ?? 0,
        fuel_type: controllers[tag_index.fuel_type.index][0].text.trim(),
        date_time: DateTime.now());

    dboAPI obj1 = dboAPI();
    ApiResponseDatabase<void>? response = await obj1.jobPostCarInfo(car.toJson());
    String message;

    if(response.hasError) {
      if(response.dbo_error != null)
        message = response.dbo_error!.message;
      else
        message = response.error!.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
  }else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "ruhsat bilgi kaydedildi",
          style: const TextStyle(color: Colors.green),
        ),
      ),
    );
    return;
  }

  }


  // Future<void> _processAssetImage() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   final byteData = await rootBundle.load('assets/images/RBSN.jpg');
  //
  //   final tempDir = await getTemporaryDirectory();
  //   final file = File('${tempDir.path}/temp_image.png');
  //   await file.writeAsBytes(byteData.buffer.asUint8List());
  //
  //   setState(() {
  //     _imageFile = file;
  //   });
  //
  //   final inputImage = InputImage.fromFile(file);
  //   final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  //   final recognizedText = await textRecognizer.processImage(inputImage);
  //
  //   setState(() {
  //     _extractedText = recognizedText.text;
  //     _isLoading = false;
  //     print(_extractedText);
  //     List<String> lines = _extractedText.split('\n');
  //
  //     for (int k = 0; k < keyword.length; k++) {
  //       for (int i = 0; i < lines.length; i++) {
  //         if (lines[i].contains(keyword[k])) {
  //           // Check if there's a next line
  //           if (i + 1 < lines.length) {
  //             print('The word "${keyword[k]}" was found.');
  //             print('Next line: ${lines[i + 1]}');
  //             controllers[k][0].text = lines[i + 1];
  //           } else {
  //             print(
  //               'The word "$keyword" was found on the last line. No next line available.',
  //             );
  //           }
  //           break; // Remove this if you want to find all occurrences
  //         }
  //       }
  //     }
  //   });
  //
  //   textRecognizer.close();
  // }


  Future<void> _initCameras() async {
    cameras = await availableCameras();
    setState(() {});
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
              //     () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => CropImage(cameras: cameras!),
              //     ),
              //   );
              // },
              icon: Icon(Icons.camera_alt),
              label: Text('kamera'),
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
                                        tag_labelText[row * columnCount + col],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      TextField(
                                        controller: controllers[row][col],
                                        textCapitalization: TextCapitalization.characters,
                                        keyboardType: tag_labelText[row * columnCount + col] == 'MODEL YILI'
                                            ? TextInputType.number
                                            : TextInputType.text,
                                        inputFormatters: tag_labelText[row * columnCount + col] == 'MODEL YILI'
                                            ? [FilteringTextInputFormatter.digitsOnly]
                                            : [],
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
                  width: screenWidth * 0.35,
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
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                SizedBox(
                  width: screenWidth * 0.35,
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
                      for (var row in controllers) {
                        for (var controller in row) {
                          controller.clear();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5F46AA),
                      foregroundColor: Colors.white,
                    ),
                    child: AutoSizeText(
                      'SİL',
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