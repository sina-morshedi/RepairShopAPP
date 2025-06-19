import 'dart:ui';
import 'dart:ffi' as ffi;
import 'package:autonetwork/Common.dart';
import 'package:autonetwork/GetCarInfoApp.dart';
import 'package:flutter/material.dart';
import 'dboAPI.dart';
import 'type.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'user_prefs.dart';

class GetCarProblemPage extends StatefulWidget {
  const GetCarProblemPage({super.key});

  @override
  _GetCarProblemPageState createState() => _GetCarProblemPageState();
}

class _GetCarProblemPageState extends State<GetCarProblemPage>
    with SingleTickerProviderStateMixin {
  final plateController = TextEditingController();
  final problemController = TextEditingController();
  Map<String, dynamic>? carData;
  carInfoFromDb?car;
  int? car_id;

  late stt.SpeechToText speech;
  bool _isListening = false;
  bool _shouldContinueListening = false;
  int _activeField = 0;
  bool isEnabled = false;
  bool isResultEnabled = false;
  TextEditingController _controllerProblemText = TextEditingController();

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward(); // start animation on page open
    speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    isResultEnabled = false;
    _isListening = false;
    _shouldContinueListening = false;
    speech.stop();
    _controller.dispose();
    plateController.dispose();
    problemController.dispose();
    super.dispose();
  }

  void _startListening() {

    speech.listen(
      onResult: (val) => setState(() {
        if (val.finalResult) {
          final oldText = _controllerProblemText.text;
          final newText = '$oldText ${val.recognizedWords}';
          _controllerProblemText.text = newText.trim();
          _controllerProblemText.selection = TextSelection.fromPosition(
            TextPosition(offset: _controllerProblemText.text.length),
          );
        }
      }),
      localeId: 'tr-TR',
      listenFor: const Duration(seconds: 10),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await speech.initialize(
        onStatus: (val) {
          print('Status$_activeField: $val');
          if ((val == 'notListening' || val == 'done') &&
              _shouldContinueListening) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!speech.isListening) {
                _startListening();
              }
            });
          }
        },
        onError: (val) {
          print('Error: $val');
          if (val.errorMsg == 'error_speech_timeout' ||
              val.errorMsg == 'error_no_match') {
            _startListening();
          }
          setState(() {
            // if (_activeField == 1) _isListening1 = false;
            // if (_activeField == 2) _isListening2 = false;
          });
        },
      );
      print('Av: $available');
      if (available) {
        setState(() {
          _isListening = true;
          _shouldContinueListening = true;
          _startListening();
        });
      }
    } else {
      setState(() {
        _isListening = false;
        _shouldContinueListening = false;
      });

      speech.stop();
    }
  }

  void searchPlate() async{
    car = await CarInfoUtility.searchByPlate(
        context,
        CarInfoUtility.tag_labelText[tag_index.license_plate.index],
        plateController.text);

    setState(() {
      if(car != null) {
        car_id = car!.car_id;
        carData = {
          'plaka': plateController.text,
          'marka': '${car!.brand}',
          'model': '${car!.brand_model}',
          'yıl': '${car!.model_year}',
        };
        isResultEnabled = true;
      }
    });
  }

  void saveProblem() {
    final text = problemController.text;
    print("Problem saved: $text");
    // Your save logic here
  }

  void _resetPage() {
    setState(() {
      isResultEnabled = false;
      _isListening = false;
      _shouldContinueListening = false;
      speech.stop();
      plateController.clear();
      _controllerProblemText.clear();
      carData = null;
      _activeField = 0;
      isEnabled = false;
    });
  }

  void showRepairDialog() async{
    dboAPI api = dboAPI();
    UserWithID? user = await UserPrefs.getUserWithID();
    print(user!.toJson());
    List<TaskStatus?> task = await UserPrefs.getTaskStatus();
    int task_id = CarInfoUtility.GetTaskID(task, 'START');

    final result = await CarInfoUtility.showRepairDialog(context, car!.toPrettyString());

    // var response = await api.jobPostProblemReport(carData);

    setState(() {
      if (result == true) {
        CarRepairLog log = CarRepairLog(
            car_id: car_id!,
            creator_user_id: user!.UserID,
            department_id: null,
            problem_report_id: null,
            car_required_departments_id: null,
            description: null,
            task_status_id: task_id,
            date_time: DateTime.now().toIso8601String());
         api.jobPostCarRepairLog(log.toJson());
        isEnabled = true;
      } else {
        isEnabled = false;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plaka ile Ara")),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: plateController,
                      decoration: const InputDecoration(
                        labelText: "Plaka girin",
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: searchPlate,
                      child: const Text("Ara"),
                    ),
                    const SizedBox(height: 20),
                    if (isResultEnabled) ...[
                      Card(
                        child: ListTile(
                          title: Text(carData!['plaka']),
                          subtitle: Text(
                              "${carData!['marka']} - ${carData!['model']} (${carData!['yıl']})"),
                          onTap: () {
                              showRepairDialog();
                              },
                        ),
                      ),

                      const SizedBox(height: 20),
                      isEnabled
                          ? Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controllerProblemText,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    labelText: "Araç problemi",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                                onPressed: () {
                                  _listen();
                                  print('Mic button pressed for First Text');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      )
                          : const SizedBox.shrink(),

                      const SizedBox(height: 10),
                      isEnabled
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: saveProblem,
                            child: const Text("Kaydet"),
                          ),
                          ElevatedButton(
                            onPressed: _resetPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("Reset"),
                          ),
                        ],
                      )
                          : const SizedBox.shrink(),

                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}