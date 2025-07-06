import 'dart:ui';
import 'package:autonetwork/Common.dart';
import 'package:autonetwork/DTO/CarInfoDTO.dart';
import 'package:autonetwork/DTO/CarRepairLogResponseDTO.dart';
import 'package:autonetwork/DTO/CarRepairLogRequestDTO.dart';
import 'package:autonetwork/DTO/CarProblemReportRequestDTO.dart';
import 'package:autonetwork/DTO/TaskStatusDTO.dart';
import 'package:autonetwork/GetCarInfoApp.dart';
import 'package:flutter/material.dart';
import '../dboAPI.dart';
import '../type.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'user_prefs.dart';
import 'package:autonetwork/DTO/UserProfileDTO.dart';
import 'Components/ShareComponents.dart';
import 'Components/CarRepairedLogCard.dart';
import '../backend_services/backend_services.dart';
import 'package:autonetwork/Pages/Components/helpers/app_helpers.dart';
import 'user_prefs.dart';

class GetCarProblemPage extends StatefulWidget {
  const GetCarProblemPage({super.key});

  @override
  _GetCarProblemPageState createState() => _GetCarProblemPageState();
}

class _GetCarProblemPageState extends State<GetCarProblemPage>
    with SingleTickerProviderStateMixin {
  final plateController = TextEditingController();
  Map<String, dynamic>? carData;
  CarRepairLogResponseDTO? carLog;
  String? car_id;

  late stt.SpeechToText speech;
  bool _isListening = false;
  bool _shouldContinueListening = false;
  int _activeField = 0;
  bool isEnabled = false;
  bool needUpdate = false;
  bool isResultEnabled = false;
  TextEditingController _controllerProblemText = TextEditingController();

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    needUpdate = false;
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
    _controllerProblemText.dispose();
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
    isEnabled = false;
    needUpdate = false;
    final response = await backend_services().getCarInfoByLicensePlate(plateController.text.toUpperCase());

    if(response.status == 'success'){
      final response = await CarRepairLogApi().getLatestLogByLicensePlate(plateController.text.toUpperCase());

      if(response.status == 'success') {
        setState(() {
          carLog = response.data;
          isResultEnabled = true;
          if(carLog!.taskStatus.taskStatusName == 'GİRMEK') {
            isEnabled = true;
          }else if(carLog!.taskStatus.taskStatusName == 'SORUN GİDERME') {
            setState(() {
              _controllerProblemText.text = carLog!.problemReport!.problemSummary!;
            });
            isEnabled = true;
            needUpdate= true;
          }
          else
            isEnabled = false;
        });
      }
      else {
        await StringHelper.showErrorDialog(context, response.message!);
        final confirm = await StringHelper.showConfirmationDialog(context, 'Araç girişini şimdi mi kaydetmek istiyorsunuz?');
        if(confirm == true){
          _CarEntry();
        }

      }
    }
    else
      StringHelper.showErrorDialog(context, response.message!);

  }
  void _CarEntry() async{
    TaskStatusDTO? taskStatusLog;
    final user = await UserPrefs.getUserWithID();
    final taskStatus  = await TaskStatusApi().getTaskStatusByName('GİRMEK');
    if(taskStatus.status == 'success')
        taskStatusLog = taskStatus.data;
    else {
      StringHelper.showErrorDialog(
          context, 'Task Status Respone: ${taskStatus.message!}');
      return;
    }

    final carResponse = await backend_services().getCarInfoByLicensePlate(plateController.text.toUpperCase());
    if(carResponse.status == 'success') {
      final selectedCar = carResponse.data;
      if (selectedCar != null) {
        final logRequest = CarRepairLogRequestDTO(
          carId: selectedCar!.id,
          creatorUserId: user!.userId,
          description: '',
          taskStatusId: taskStatusLog!.id!,
          dateTime: DateTime.now(),
          problemReportId: null,
        );

        final response = await CarRepairLogApi().createLog(logRequest);

        if(response.status == 'success' && response.data != null)
          StringHelper.showInfoDialog(context, 'Araba girişi kaydedildi');
        else
          StringHelper.showErrorDialog(context, 'Creat Log: ${response.message!}');
      }
      else
        StringHelper.showErrorDialog(context, carResponse.message!);
    }
  }

  void saveProblem() async {
    if (carInfo == null) return;

    final problemText = _controllerProblemText.text.trim();
    if (problemText.isEmpty) {
      StringHelper.showErrorDialog(context, "Lütfen problemi giriniz");
      return;
    }

    final user = await UserPrefs.getUserWithID();
    if(user == null){
      StringHelper.showErrorDialog(context, 'kullanıcı bilgiye bulamadım.');
      return;
    }

    // Create problem report DTO
    if(needUpdate){
      final reportDTO = CarProblemReportRequestDTO(
        id: carLog!.problemReport!.id,
        carId: carLog!.carInfo.id,
        creatorUserId: user!.userId,
        problemSummary: problemText,
        dateTime: DateTime.now(),
      );
      final updateResponse = await CarProblemReportApi().updateReport(reportDTO);
      if(updateResponse.status == 'success')
        StringHelper.showInfoDialog(context, updateResponse.message!);
      else
        StringHelper.showErrorDialog(context, updateResponse.message!);
    }
    else{
      final reportDTO = CarProblemReportRequestDTO(
        carId: carLog!.carInfo.id,
        creatorUserId: user!.userId,
        problemSummary: problemText,
        dateTime: DateTime.now(),
      );

      // Save problem report
      final saveResponse = await CarProblemReportApi().createReport(reportDTO);

      if (saveResponse.status == 'success' && saveResponse.data != null) {
        _controllerProblemText.clear();

        // Now create a CarRepairLog based on saved problem report
        final createdProblemReport = saveResponse.data!;

        final taskStatus  = await TaskStatusApi().getTaskStatusByName('SORUN GİDERME');
        if(taskStatus.status != 'success') {
          StringHelper.showErrorDialog(
              context, 'Task Status Respone: ${taskStatus.message!}');
          return;
        }
        if (taskStatus.status == 'success' && taskStatus.data != null) {

          final logRequest = CarRepairLogRequestDTO(
            carId: createdProblemReport.carId,
            creatorUserId: user.userId,
            description: '',
            taskStatusId: taskStatus.data!.id!,
            dateTime: DateTime.now(),
            problemReportId: createdProblemReport.id,
          );

          final logResponse = await CarRepairLogApi().createLog(logRequest);

          if (logResponse.status == 'success') {
            StringHelper.showInfoDialog(
                context,"CarRepairLog başarıyla oluşturuldu.");
          } else {
            StringHelper.showErrorDialog(
                context,"CarRepairLog oluşturulamadı: ${logResponse.message}");
          }
        } else {
          StringHelper.showErrorDialog(
              context,"TaskStatus not found or error: ${taskStatus.message}");
        }


      } else {
        // Show error if saving problem report failed
        StringHelper.showErrorDialog(
            context,
            "Problem raporu kaydedilirken hata oluştu: ${saveResponse.message}"
        );
      }
    }

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
    UserProfileDTO? user = await UserPrefs.getUserWithID();

    final result = await Sharecomponents.showRepairDialog(context, carLog!.carInfo);
    if(result == true){
      setState(() {
        isEnabled = true;
      });
    }
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
                      CarRepairedLogCard(log: carLog!),

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