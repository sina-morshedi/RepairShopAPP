import 'dart:ui';
import 'package:autonetwork/DTO/CarRepairLogResponseDTO.dart';
import 'package:autonetwork/DTO/CarRepairLogRequestDTO.dart';
import 'package:autonetwork/DTO/CarProblemReportRequestDTO.dart';
import 'package:autonetwork/DTO/TaskStatusDTO.dart';
import 'package:autonetwork/DTO/FilterRequestDTO.dart';
import 'package:autonetwork/DTO/PartUsed.dart';
import 'package:autonetwork/DTO/PaymentRecord.dart';
import 'package:flutter/material.dart';
import '../type.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'user_prefs.dart';
import 'package:autonetwork/DTO/UserProfileDTO.dart';
import 'Components/ShareComponents.dart';
import 'Components/CarRepairedLogCard.dart';
import 'Components/CarRepairLogListView.dart';
import '../backend_services/backend_services.dart';
import 'package:autonetwork/Pages/Components/helpers/app_helpers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'Components/helpers/invoice_pdf_helper.dart';
import 'Components/DecimalTextInputFormatter.dart';



class GetCarProblem extends StatefulWidget {
  final String? plate;
  final VoidCallback? onProblemSaved;  // این خط جدید

  const GetCarProblem({super.key, this.plate, this.onProblemSaved});

  @override
  _GetCarProblemState createState() => _GetCarProblemState();
}

class _GetCarProblemState extends State<GetCarProblem>
    with SingleTickerProviderStateMixin {
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  Map<String, dynamic>? carData;
  CarRepairLogResponseDTO? carLog;
  String? car_id;


  List<String> statusOptions=[];
  List<CarRepairLogResponseDTO> _logs = [];

  pw.Font? customFont;
  pw.MemoryImage? logoImage;

  late stt.SpeechToText speech;
  bool _isListening = false;
  bool _shouldContinueListening = false;
  int _activeField = 0;
  bool isEnabled = false;
  bool needUpdate = false;
  bool isResultEnabled = false;
  bool showInvoice = false;
  bool isUserButtonEnabled = true;

  UserProfileDTO? user;
  List<UserProfileDTO>? usersLogs;
  String? selectedUserId;


  double totalPrice = 0;

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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    speech = stt.SpeechToText();
    loadAssets();

    if (widget.plate != null && widget.plate!.isNotEmpty) {
      _licensePlateController.text = widget.plate!.toUpperCase();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchPlate();
      });
    }
  }



  Future<void> loadAssets() async {
    final fontData = await rootBundle.load("assets/fonts/Vazirmatn-Regular.ttf");
    final imageData = await rootBundle.load("assets/images/invoice-logo.png");

    setState(() {
      customFont = pw.Font.ttf(fontData);
      logoImage = pw.MemoryImage(imageData.buffer.asUint8List());
    });
  }

  @override
  void dispose() {
    isResultEnabled = false;
    _isListening = false;
    _shouldContinueListening = false;
    speech.stop();
    _controller.dispose();
    _licensePlateController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  void _clearPartControllers() {
    _licensePlateController.clear();
    _problemController.clear();
  }

  void _startListening() {

    speech.listen(
      onResult: (val) => setState(() {
        if (val.finalResult) {
          final oldText = _problemController.text;
          final newText = '$oldText ${val.recognizedWords}';
          _problemController.text = newText.trim();
          _problemController.selection = TextSelection.fromPosition(
            TextPosition(offset: _problemController.text.length),
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
    isResultEnabled = false;
    isEnabled = false;
    needUpdate = false;
    isUserButtonEnabled = true;

    final plate = _licensePlateController.text.trim().toUpperCase();
    if (plate.isEmpty) return;

    final response = await CarInfoApi().getCarInfoByLicensePlate(_licensePlateController.text.toUpperCase());

    if(response.status == 'success'){
      final response = await CarRepairLogApi().getLatestLogByLicensePlate(_licensePlateController.text.toUpperCase());

      if(response.status == 'success') {
        setState(() {
          _clearPartControllers();
          carLog = response.data;
          isResultEnabled = true;
          if(carLog!.taskStatus.taskStatusName == 'GİRMEK') {
            isEnabled = true;
          }else if(carLog!.taskStatus.taskStatusName == 'SORUN GİDERME') {
            setState(() {
              _problemController.text = carLog!.problemReport!.problemSummary!;
            });
            isEnabled = true;
            needUpdate= true;
          }else if (carLog!.taskStatus.taskStatusName == 'FATURA') {
            isEnabled = false;
            needUpdate= false;

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

    final carResponse = await CarInfoApi().getCarInfoByLicensePlate(_licensePlateController.text.toUpperCase());
    if(carResponse.status == 'success') {
      final selectedCar = carResponse.data;
      if (selectedCar != null) {
        final customerId = carLog?.customer?.id ?? "";
        final logRequest = CarRepairLogRequestDTO(
          carId: selectedCar!.id,
          creatorUserId: user!.userId,
          description: '',
          taskStatusId: taskStatusLog!.id!,
          dateTime: DateTime.now(),
          problemReportId: null,
          customerId: customerId
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

    final problemText = _problemController.text.trim();
    if (problemText.isEmpty) {

      await StringHelper.showErrorDialog(context, "Lütfen problemi giriniz");
      return;
    }

    final user = await UserPrefs.getUserWithID();

    if (user == null) {
      await StringHelper.showErrorDialog(context, 'kullanıcı bilgiye bulamadım.');
      return;
    }

    if (needUpdate) {
      final reportDTO = CarProblemReportRequestDTO(
        id: carLog!.problemReport!.id,
        carId: carLog!.carInfo.id,
        creatorUserId: user.userId,
        problemSummary: problemText,
        dateTime: DateTime.now(),
      );

      final updateResponse = await CarProblemReportApi().updateReport(reportDTO);


      if (updateResponse.status == 'success') {
        await StringHelper.showInfoDialog(context, updateResponse.message!);
        widget.onProblemSaved?.call();
      } else {
        await StringHelper.showErrorDialog(context, updateResponse.message!);
      }

    } else {
      final reportDTO = CarProblemReportRequestDTO(
        carId: carLog!.carInfo.id,
        creatorUserId: user.userId,
        problemSummary: problemText,
        dateTime: DateTime.now(),
      );

      final saveResponse = await CarProblemReportApi().createReport(reportDTO);


      if (saveResponse.status == 'success' && saveResponse.data != null) {
        final createdProblemReport = saveResponse.data!;
        widget.onProblemSaved?.call();
        _problemController.clear();

        final taskStatus = await TaskStatusApi().getTaskStatusByName('SORUN GİDERME');


        if (taskStatus.status != 'success') {
          await StringHelper.showErrorDialog(
              context, 'Task Status Respone: ${taskStatus.message!}');
          return;
        }

        if (taskStatus.data != null) {
          final customerId = carLog?.customer?.id ?? "";
          final logRequest = CarRepairLogRequestDTO(
            carId: createdProblemReport.carId,
            creatorUserId: user.userId,
            description: '',
            taskStatusId: taskStatus.data!.id!,
            dateTime: DateTime.now(),
            problemReportId: createdProblemReport.id,
            customerId: customerId,
          );

          final logResponse = await CarRepairLogApi().createLog(logRequest);


          if (logResponse.status == 'success') {
            if (!mounted) return;
            await StringHelper.showInfoDialog(context, "CarRepairLog başarıyla oluşturuldu.");
          } else {
            await StringHelper.showErrorDialog(
                context, "CarRepairLog oluşturulamadı: ${logResponse.message}");
          }
        } else {
          await StringHelper.showErrorDialog(
              context, "TaskStatus not found or error: ${taskStatus.message}");
        }

      } else {
        await StringHelper.showErrorDialog(
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
      _licensePlateController.clear();
      _problemController.clear();
      carData = null;
      _activeField = 0;
      isEnabled = false;
    });
  }

  void showRepairDialog() async{
    final result = await Sharecomponents.showRepairDialog(context, carLog!.carInfo);
    if(result == true){
      setState(() {
        isEnabled = true;
      });
    }
  }

  Widget buildResultSection() {

    if (!isResultEnabled || carLog == null) return SizedBox.shrink();

    if (carLog!.taskStatus.taskStatusName == 'GİRMEK' ||
        carLog!.taskStatus.taskStatusName == 'SORUN GİDERME') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CarRepairedLogCard(log: carLog!),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _problemController,
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
                onPressed: _listen,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: saveProblem,
                child: const Text("Kaydet"),
              ),
              ElevatedButton(
                onPressed: _resetPage,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Reset"),
              ),
            ],
          ),
        ],
      );
    }

    return CarRepairedLogCard(log: carLog!);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text("Plaka ile Ara")),
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
                    if (widget.plate == null || widget.plate!.isEmpty) ...[
                      TextField(
                        controller: _licensePlateController,
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
                    ],
                    if (isResultEnabled) ...[
                      buildResultSection(),
                    ],
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