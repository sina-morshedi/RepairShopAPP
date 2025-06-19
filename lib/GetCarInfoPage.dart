import 'package:flutter/material.dart';
import 'dboAPI.dart';
import 'type.dart';
import 'package:autonetwork/Common.dart';

class GetCarInfoPage extends StatefulWidget {
  const GetCarInfoPage({super.key});

  @override
  State<GetCarInfoPage> createState() => _GetCarInfoPageState();
}

class _GetCarInfoPageState extends State<GetCarInfoPage> with SingleTickerProviderStateMixin {
  String mode = 'Yeni Araç Kaydı';
  List<List<TextEditingController>> controllers = [];
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  String? _errorMessage;
  int? _carId;
  final dboAPI api = dboAPI();

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

  final List<String> tag_labelText = [
    "ŞASE NO",
    "MOTOR NO",
    "PLAKA",
    "MARKASI",
    "TİCARİ ADI",
    "MODEL YILI",
    "YAKIT CİNSİ",
  ];
  String? selectedPlate;
  final TextEditingController searchController = TextEditingController();

  final TextEditingController chassisNoController = TextEditingController();
  final TextEditingController motorNoController = TextEditingController();
  final TextEditingController licensePlateNoController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController feulTypeController = TextEditingController();


  bool get isEditMode => mode == 'Mevcut Aracı Düzenle';
  bool get canEdit => !isEditMode || (selectedPlate != null && selectedPlate!.isNotEmpty);

  void _onPlateSelected() {
    setState(() {
      if (isEditMode && selectedPlate != null) {
      } else {
        chassisNoController.clear();
        motorNoController.clear();
        licensePlateNoController.clear();
        brandController.clear();
        modelController.clear();
        yearController.clear();
        feulTypeController.clear();
      }
      // saveEditCarInfo();
    });
  }

  Future<ApiResponseDatabase<carInfoFromDb>> _fetchCarInfoByLicensePlate(String plate) async {
    return await api.jobGetCarInfoWithID('license_plate', plate);
  }

  Future<void> fetchCarInfo() async {
    String plate = licensePlateNoController.text.trim().toUpperCase();

    if (plate.isEmpty) {
      print("Plaka boş olamaz");
      return;
    }

    ApiResponseDatabase<carInfo> response = await api.jobGetCarInfo('license_plate', plate);

    if (response.data != null) {
      carInfo car = response.data!;
      print("Araç bilgileri bulundu: ${car.license_plate}");

    } else if (response.dbo_error != null) {
      print("Hata: ${response.dbo_error!.message}");
    } else if (response.error != null) {
      print("Beklenmeyen hata: ${response.error!.message}");
    }
  }

  void searchByPlate() async{
    carInfoFromDb? car = await CarInfoUtility.searchByPlate(context, tag_labelText[2], searchController.text.trim().toUpperCase());
    if (car != null) {
      setState(() {
        _carId = car.car_id;
        licensePlateNoController.text = car.license_plate ?? '';
        chassisNoController.text = car.chassis_no ?? '';
        motorNoController.text = car.motor_no ?? '';
        brandController.text = car.brand ?? '';
        modelController.text = car.brand_model ?? '';
        yearController.text = car.model_year?.toString() ?? '';
        feulTypeController.text = car.fuel_type ?? '';
        selectedPlate = licensePlateNoController.text;
      });

    }
  }

  void showErrorDialog(BuildContext context, String errorMessage, String errorCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('HATA', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage),
            SizedBox(height: 12),
            Text(
              'HATA KODU: $errorCode',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  bool validateString(String tag, String str) {
      if (str.isEmpty) {
        showErrorDialog(context, "$tag'nin kutusu boş","-1");
        return false;
      }
      if (str.contains('  ')) {
        showErrorDialog(context, "$tag: boşluk kullanma","-1");
        return false;
      }

      if (RegExp(r'[a-z]').hasMatch(str)) {
        showErrorDialog(context, "$tag: küçük harf kullanma","-1");
        return false;
      }

      return true;
  }
  bool validateNumber(String tag, String str) {
    if (str.isEmpty) {
      showErrorDialog(context, "$tag'nin kutusu boş","-1");
      return false;
    }
    if (str.contains('  ')) {
      showErrorDialog(context, "$tag: boşluk kullanma","-1");
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(str)) {
      showErrorDialog(context, "$tag: Sadece numarayı yazın.","-1");
      return false;
    }

    return true;
  }


  Future<void> saveEditCarInfo() async {

    int i = 0;

    print('isEditMode: $isEditMode');
    if(isEditMode) {
      if (_carId == null) {
        setState(() {
          _errorMessage = "Araç bilgisi yüklü değil.";
        });
        showErrorDialog(context, "_carId: Araç bilgisi yüklü değil.", "-1");
        return;
      }
    }

    if(validateString(tag_labelText[0], chassisNoController.text) == false)return;
    if(validateString(tag_labelText[1], motorNoController.text) == false)return;
    if(validateString(tag_labelText[2], licensePlateNoController.text) == false)return;
    if(validateString(tag_labelText[3], brandController.text) == false)return;
    if(validateString(tag_labelText[4], modelController.text) == false)return;
    if(validateString(tag_labelText[6], feulTypeController.text) == false)return;
    if(validateNumber(tag_labelText[5], yearController.text) == false)return;

    Map<String, dynamic> carData = {
      "chassis_no": chassisNoController.text.toUpperCase(),
      "motor_no": motorNoController.text.toUpperCase(),
      "license_plate": licensePlateNoController.text.toUpperCase(),
      "brand": brandController.text.toUpperCase(),
      "brand_model": modelController.text.toUpperCase(),
      "model_year": int.tryParse(yearController.text),
      "fuel_type": feulTypeController.text.toUpperCase(),
      "date_time": DateTime.now().toIso8601String()
    };

    ApiResponseDatabase response;
    print("isEditMode: $isEditMode");
    if(isEditMode){
      print("isEditMode: 1");
      response = await api.jobUpdateCarInfo(_carId!, carData);
    }
    else{
      print("isEditMode: 2");
      response = await api.jobPostCarInfo(carData);
    }

    if (response.hasError) {
      if(response.dbo_error != null)
        showErrorDialog(context, response.dbo_error!.message, response.dbo_error!.error_code);
      if(response.error != null)
        showErrorDialog(context, response.error!.message, response.error!.statusCode.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Araç bilgileri güncellendi",
            style: TextStyle(color: Colors.green),
          ),
        ),
      );

    }
  }


  @override
  void initState() {
    super.initState();

    // Initialize controllers
    for (int i = 0; i < rowCount; i++) {
      List<TextEditingController> rowControllers = [];
      for (int j = 0; j < columnCount; j++) {
        rowControllers.add(TextEditingController(text: ""));
      }
      controllers.add(rowControllers);
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }
  @override
  void dispose() {
    // searchController.dispose();
    // brandController.dispose();
    // modelController.dispose();
    // yearController.dispose();
    // chassisController.dispose();
    chassisNoController.dispose();
    motorNoController.dispose();
    licensePlateNoController.dispose();
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();
    feulTypeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıtlı Araçlar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Yeni Araç Kaydı'),
                        value: 'Yeni Araç Kaydı',
                        groupValue: mode,
                        onChanged: (val) {
                          setState(() {
                            mode = val!;
                            selectedPlate = null;
                            chassisNoController.clear();
                            motorNoController.clear();
                            licensePlateNoController.clear();
                            brandController.clear();
                            modelController.clear();
                            yearController.clear();
                            feulTypeController.clear();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Mevcut Aracı Düzenle'),
                        value: 'Mevcut Aracı Düzenle',
                        groupValue: mode,
                        onChanged: (val) {
                          setState(() {
                            mode = val!;
                            selectedPlate = null;
                            chassisNoController.clear();
                            motorNoController.clear();
                            licensePlateNoController.clear();
                            brandController.clear();
                            modelController.clear();
                            yearController.clear();
                            feulTypeController.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (isEditMode) ...[
                  TextField(
                    controller: searchController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: selectedPlate,
                      hintText: 'Değerinizi girin',
                    ),
                    onSubmitted: (val) {
                      setState(() {
                        _onPlateSelected();
                        searchByPlate();

                      });
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 20),
                // سایر TextField ها و ElevatedButton دقیقاً همون‌طور که قبل نوشتی 👇
                TextField(
                  controller: chassisNoController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[0],
                    border: OutlineInputBorder(),
                  ),
                  enabled: canEdit,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: motorNoController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[1],
                    border: OutlineInputBorder(),
                  ),
                  enabled: canEdit,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: licensePlateNoController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[2],
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: canEdit,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: brandController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[3],
                    border: OutlineInputBorder(),
                  ),
                  enabled: canEdit,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: modelController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[4],
                    border: OutlineInputBorder(),
                  ),
                  enabled: canEdit,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: yearController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[5],
                    border: OutlineInputBorder(),
                  ),
                  enabled: canEdit,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: feulTypeController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[6],
                    border: OutlineInputBorder(),
                  ),
                  enabled: canEdit,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:(){
                    final info = {
                      tag_labelText[0]: chassisNoController.text,
                      tag_labelText[1]: motorNoController.text,
                      tag_labelText[2]: isEditMode ? selectedPlate : null,
                      tag_labelText[3]: brandController.text,
                      tag_labelText[4]: modelController.text,
                      tag_labelText[5]: yearController.text,
                      tag_labelText[6]: feulTypeController.text,
                    };
                    saveEditCarInfo();
                  },
                  child: Text(isEditMode ? 'Değişiklikleri Kaydet' : 'Yeni Araç Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
