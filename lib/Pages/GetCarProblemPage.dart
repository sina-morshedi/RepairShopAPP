import 'dart:ui';
import 'package:autonetwork/DTO/CarRepairLogResponseDTO.dart';
import 'package:autonetwork/DTO/CarRepairLogRequestDTO.dart';
import 'package:autonetwork/DTO/CarProblemReportRequestDTO.dart';
import 'package:autonetwork/DTO/TaskStatusDTO.dart';
import 'package:autonetwork/DTO/PartUsed.dart';
import 'package:flutter/material.dart';
import '../type.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'user_prefs.dart';
import 'package:autonetwork/DTO/UserProfileDTO.dart';
import 'Components/ShareComponents.dart';
import 'Components/CarRepairedLogCard.dart';
import '../backend_services/backend_services.dart';
import 'package:autonetwork/Pages/Components/helpers/app_helpers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'Components/helpers/invoice_pdf_helper.dart';



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
  bool isDeliveryButtonDisabled = false;

  TextEditingController _controllerProblemText = TextEditingController();
  UserProfileDTO? user;
  List<UserProfileDTO>? usersLogs;
  String? selectedUserId;

  List<TextEditingController> _priceControllers = [];
  List<TextEditingController> _quantityControllers = [];
  List<TextEditingController> _partNameControllers = [];

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState(){
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
    _load();
    loadAssets();
    _loadUsers();
    // _initControllers();
  }
  void _load() async{
    user = await UserPrefs.getUserWithID();
    print(user!.permission.permissionName);
  }

  void _initControllers(List<PartUsed> parts) {
    _partNameControllers = parts.map((p) => TextEditingController(text: p.partName)).toList();
    _priceControllers = parts.map((p) => TextEditingController(text: p.partPrice.toString())).toList();
    _quantityControllers = parts.map((p) => TextEditingController(text: p.quantity.toString())).toList();
  }

  Future<void> loadAssets() async {
    final fontData = await rootBundle.load("assets/fonts/Vazirmatn-Regular.ttf");
    final imageData = await rootBundle.load("assets/images/Logo.png");

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
    isUserButtonEnabled = true;
    isDeliveryButtonDisabled = false;
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

  void _onSave() async {
    final parts = carLog?.partsUsed ?? [];

    for (int i = 0; i < parts.length; i++) {
      final name = _partNameControllers[i].text.trim();
      final priceText = _priceControllers[i].text.trim();
      final quantityText = _quantityControllers[i].text.trim();

      if (name.isEmpty) {
        StringHelper.showErrorDialog(context, 'Lütfen ${i + 1}. parçanın adını giriniz.');
        return;
      }

      final price = double.tryParse(priceText);
      if (price == null || price < 0) {
        StringHelper.showErrorDialog(context, 'Lütfen ${i + 1}. parçanın fiyatını düzgün giriniz.');
        return;
      }

      final qty = int.tryParse(quantityText);
      if (qty == null || qty <= 0) {
        StringHelper.showErrorDialog(context, 'Lütfen ${i + 1}. parçanın adedini düzgün giriniz.');
        return;
      }

      parts[i] = PartUsed(
        partName: name,
        partPrice: price,
        quantity: qty,
      );
    }

    final bool _needUpdate = carLog!.taskStatus.taskStatusName == "FATURA"? true:false;

    if(_needUpdate) {
      final request = CarRepairLogRequestDTO(
          carId: carLog!.carInfo.id,
          creatorUserId: user!.userId,
          assignedUserId: carLog!.assignedUser!.userId,
          description: carLog!.description,
          problemReportId: carLog!.problemReport!.id,
          taskStatusId: carLog!.taskStatus.id!,
          partsUsed: carLog!.partsUsed,
          dateTime: DateTime.now());

      final response = await CarRepairLogApi().updateLog(carLog!.id!, request);
      if(response.status == 'success'){
        StringHelper.showInfoDialog(context, 'Faturayı güncelledi.');
      }
      else
        StringHelper.showErrorDialog(context, response.message!);
    }
    else{
      final responseTask = await TaskStatusApi().getTaskStatusByName('FATURA');
      if(responseTask.status != 'success'){
        StringHelper.showErrorDialog(context, responseTask.message!);
        return;
      }
      final request = CarRepairLogRequestDTO(
          carId: carLog!.carInfo.id,
          creatorUserId: user!.userId,
          assignedUserId: carLog!.assignedUser!.userId,
          description: carLog!.description,
          problemReportId: carLog!.problemReport!.id,
          taskStatusId: responseTask.data!.id!,
          partsUsed: carLog!.partsUsed,
          dateTime: DateTime.now());

      final response = await CarRepairLogApi().createLog(request);
      if(response.status == 'success') {
        StringHelper.showInfoDialog(context, 'Fatura kaydedildi.');
      }
      else
        StringHelper.showErrorDialog(context, response.message!);
    }
  }

  void _onLoad()async {
    final response = await CarRepairLogApi().getLatestLogByLicensePlate(plateController.text.toUpperCase());
    List<PartUsed?> parts;
    if(response.status == 'success')
      parts = response.data!.partsUsed!;
    else{
      StringHelper.showErrorDialog(context, response.message!);
      return;
    }


    // پاک‌سازی کنترلرهای فعلی
    _partNameControllers.clear();
    _priceControllers.clear();
    _quantityControllers.clear();

    // ایجاد کنترلرهای جدید بر اساس داده‌های موجود
    for (var part in parts) {
      _partNameControllers.add(TextEditingController(text: part!.partName));
      _priceControllers.add(TextEditingController(text: part.partPrice.toString()));
      _quantityControllers.add(TextEditingController(text: part.quantity.toString()));
    }

    setState(() {});
  }

  Widget buildInvoiceViewSection() {
    final parts = carLog?.partsUsed ?? [];

    if (_partNameControllers.length != parts.length ||
        _priceControllers.length != parts.length ||
        _quantityControllers.length != parts.length) {
      _initControllers(parts);
    }

    double totalPrice = 0;
    for (var p in parts) {
      totalPrice += p.partPrice * p.quantity;
    }

    void addNewPart() {
      setState(() {
        parts.add(PartUsed(partName: '', partPrice: 0, quantity: 1));
        _partNameControllers.add(TextEditingController());
        _priceControllers.add(TextEditingController(text: '0'));
        _quantityControllers.add(TextEditingController(text: '1'));
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CarRepairedLogCard(log: carLog!),
        const SizedBox(height: 20),

        ElevatedButton.icon(
          onPressed: (customFont == null || logoImage == null || parts.isEmpty)
              ? null
              :  () {
            InvoicePdfHelper.generateAndDownloadInvoicePdf(
              customFont: customFont!,
              logoImage: logoImage!,
              parts: parts,
              log: carLog!,
              licensePlate: carLog!.carInfo.licensePlate,
            );
          },
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Faturayı PDF olarak oluştur"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 16),

        if (parts.isNotEmpty)
          ...List.generate(parts.length, (index) {
            return Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _partNameControllers[index],
                    decoration: InputDecoration(
                      labelText: "Parça Adı",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        parts[index] = PartUsed(
                          partName: value,
                          partPrice: parts[index].partPrice,
                          quantity: parts[index].quantity,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priceControllers[index],
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: "Fiyat (₺)",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            final newPrice = double.tryParse(value) ?? 0.0;
                            setState(() {
                              parts[index] = PartUsed(
                                partName: parts[index].partName,
                                partPrice: newPrice,
                                quantity: parts[index].quantity,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _quantityControllers[index],
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: "Adet",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            final newQty = int.tryParse(value) ?? 1;
                            setState(() {
                              parts[index] = PartUsed(
                                partName: parts[index].partName,
                                partPrice: parts[index].partPrice,
                                quantity: newQty,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Text(
                    "Toplam: ${(parts[index].partPrice * parts[index].quantity).toStringAsFixed(2)} ₺",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 10),
        Text(
          "Genel Toplam: ${totalPrice.toStringAsFixed(2)} ₺",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),

        const SizedBox(height: 10),
        /// 🔻 ردیف دکمه‌های Save، Load، Add
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 🔸 ردیف اول: Kaydet, Yükle, Add
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: isDeliveryButtonDisabled ? null : () async {
                        _onSave();
                      },
                      child: const Text("Kaydet"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isDeliveryButtonDisabled ? null : () async {
                        _onLoad();
                      },
                      child: const Text("Yükle"),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 36,
                    color: isDeliveryButtonDisabled ? Colors.grey : Colors.green,
                  ),
                  tooltip: "Yeni parça ekle",
                  onPressed: isDeliveryButtonDisabled ? null : addNewPart,
                ),

              ],
            ),

            const SizedBox(height: 10),

            /// 🔸 ردیف دوم: فقط دکمه‌ی Teslim Et (اگر در وضعیت FATURA باشه)
            if (carLog?.taskStatus.taskStatusName == 'FATURA')
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: isDeliveryButtonDisabled ? null : () async {
                    _vehicleDelivery();
                  },
                  icon: const Icon(Icons.car_rental),  // آیکون سمت چپ متن است
                  label: const Text("Teslim Et"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),

              ),
          ],
        ),




      ],
    );
  }

  void _loadUsers()async{
    final response = await backend_services().fetchAllProfile();

    if(response.status == 'success'){
      usersLogs = response.data;
    }
    else
      StringHelper.showErrorDialog(context, response.message!);
  }

  Widget buildResultSection() {
    if (!isResultEnabled || carLog == null) return SizedBox.shrink();

    if ((carLog!.taskStatus.taskStatusName == 'FATURA' || carLog!.taskStatus.taskStatusName == 'İŞ BİTTİ') &&
        user!.permission.permissionName == 'Yönetici') {
      return buildInvoiceViewSection();
    } else if (carLog!.taskStatus.taskStatusName == 'GİRMEK' ||
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
          const SizedBox(height: 10),
          if (carLog!.taskStatus.taskStatusName == 'SORUN GİDERME' && usersLogs != null) ...[
            const SizedBox(height: 10),
            buildUserDropdown(),
          ],
        ],
      );
    }

    return CarRepairedLogCard(log: carLog!);
  }

  Widget buildUserDropdown() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey), // خط دور درابتان
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Kullanıcı Seçiniz"),
                value: selectedUserId,
                items: usersLogs?.map((user) {
                  return DropdownMenuItem<String>(
                    value: user.userId,
                    child: Text('${user.firstName} ${user.lastName}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUserId = value;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: isUserButtonEnabled
              ? () {
            if (selectedUserId != null) {
              sendUserSelectionToBackend(selectedUserId!);
            } else {
              print("Kullanıcı seçilmedi.");
            }
          }
              : null,
          child: Icon(
            Icons.check_circle,
            color: isUserButtonEnabled ? Colors.green : Colors.grey,
            size: 32,
          ),
        ),

      ],
    );
  }

  void sendUserSelectionToBackend(String? userId) async{
    if (userId == null) return;

    TaskStatusDTO? taskStatusLog;
    final user = await UserPrefs.getUserWithID();
    final taskStatus  = await TaskStatusApi().getTaskStatusByName('USTA');
    if(taskStatus.status == 'success')
      taskStatusLog = taskStatus.data;
    else {
      StringHelper.showErrorDialog(
          context, 'Task Status Respone: ${taskStatus.message!}');
      return;
    }
    final logRequest = CarRepairLogRequestDTO(
      carId: carLog!.carInfo.id,
      creatorUserId: user!.userId,
      description: '',
      taskStatusId: taskStatusLog!.id!,
      dateTime: DateTime.now(),
      problemReportId: carLog!.problemReport!.id,
      assignedUserId: userId,
    );

    final response = await CarRepairLogApi().createLog(logRequest);

    if(response.status == 'success'){
      setState(() {
        isUserButtonEnabled = false;
      });
      StringHelper.showInfoDialog(context, 'Bilgiler başarıyla kaydedildi.');
    }
    else
      StringHelper.showErrorDialog(context, response.message!);
  }

  void _vehicleDelivery()async{
    if(user == null){
      StringHelper.showErrorDialog(context, 'Kullanıcı bulunamadı.');
      return;
    }

    final responseTask = await TaskStatusApi().getTaskStatusByName("GÖREV YOK");
    if(responseTask.status == 'success'){
      final request = CarRepairLogRequestDTO(
          carId: carLog!.carInfo.id,
          creatorUserId: user!.userId,
          taskStatusId: responseTask.data!.id!,
          assignedUserId: carLog!.assignedUser!.userId,
          problemReportId: carLog!.problemReport!.id,
          partsUsed: carLog!.partsUsed,
          dateTime: DateTime.now()
      );
      final response = await CarRepairLogApi().createLog(request);
      if(response.status == 'success') {
        setState(() {
          isDeliveryButtonDisabled = true;
        });

        StringHelper.showInfoDialog(context, 'Bilgiler kaydedildi.');
      }
      else
        StringHelper.showErrorDialog(context, response.message!);

    }
    else
      StringHelper.showErrorDialog(context, responseTask.message!);

  }
}