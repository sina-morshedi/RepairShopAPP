import 'package:flutter/material.dart';
import '../dboAPI.dart';
import '../type.dart';
import 'package:autonetwork/utils/string_helper.dart';
import 'package:autonetwork/backend_services/backend_services.dart';
import 'package:autonetwork/DTO/CarInfo.dart';
import 'package:autonetwork/backend_services/ApiEndpoints.dart';

class GetCarInfoPage extends StatefulWidget {
  const GetCarInfoPage({super.key});

  @override
  State<GetCarInfoPage> createState() => _GetCarInfoPageState();
}

class _GetCarInfoPageState extends State<GetCarInfoPage>
    with SingleTickerProviderStateMixin {
  String mode = 'Yeni Araç Kaydı';
  List<List<TextEditingController>> controllers = [];
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final dboAPI api = dboAPI();

  static const List<String> tag_dbo = [
    "chassis_no",
    "motor_no",
    "license_plate",
    "brand",
    "brand_model",
    "model_year",
    "fuel_type",
    "date_time",
  ];
  final int rowCount = tag_dbo.length - 1;
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
  final TextEditingController licensePlateNoController =
      TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController fuelTypeController = TextEditingController();

  bool get isEditMode => mode == 'Mevcut Aracı Düzenle';
  bool get canEdit =>
      !isEditMode || (selectedPlate != null && selectedPlate!.isNotEmpty);

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
        fuelTypeController.clear();
      }
      // saveEditCarInfo();
    });
  }

  Future<void> fetchCarInfo() async {
    String plate = licensePlateNoController.text.trim().toUpperCase();

    if (plate.isEmpty) {
      print("Plaka boş olamaz");
      return;
    }

    ApiResponseDatabase<carInfo> response = await api.jobGetCarInfo(
      'license_plate',
      plate,
    );

    if (response.data != null) {
      carInfo car = response.data!;
      print("Araç bilgileri bulundu: ${car.license_plate}");
    } else if (response.dbo_error != null) {
      print("Hata: ${response.dbo_error!.message}");
    } else if (response.error != null) {
      print("Beklenmeyen hata: ${response.error!.message}");
    }
  }

  void searchByPlate() async {
    final ApiResponse<CarInfo> response = await backend_services()
        .getCarInfoByLicensePlate(searchController.text.trim());
    if (response.status == 'successful' && response.data != null) {
      final car = response.data!;

      setState(() {
        licensePlateNoController.text = car.licensePlate;
        chassisNoController.text = car.chassisNo;
        motorNoController.text = car.motorNo;
        brandController.text = car.brand;
        modelController.text = car.brandModel;
        yearController.text = car.modelYear?.toString() ?? '';
        fuelTypeController.text = car.fuelType;
        selectedPlate = licensePlateNoController.text;
      });
    } else {
      StringHelper.showErrorDialog(
        context,
        response.message ?? 'Araç bulunamadı veya sunucu hatası',
      );
    }
  }

  void showErrorDialog(
    BuildContext context,
    String errorMessage,
    String errorCode,
  ) {
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
      StringHelper.showErrorDialog(context, "$tag'nin kutusu boş");
      return false;
    }
    if (str.contains('  ')) {
      StringHelper.showErrorDialog(context, "$tag: boşluk kullanma");
      return false;
    }

    if (RegExp(r'[a-z]').hasMatch(str)) {
      StringHelper.showErrorDialog(context, "$tag: küçük harf kullanma");
      return false;
    }

    return true;
  }

  bool validateNumber(String tag, String str) {
    if (str.isEmpty) {
      StringHelper.showErrorDialog(context, "$tag'nin kutusu boş");
      return false;
    }
    if (str.contains('  ')) {
      StringHelper.showErrorDialog(context, "$tag: boşluk kullanma");
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(str)) {
      StringHelper.showErrorDialog(context, "$tag: Sadece numarayı yazın.");
      return false;
    }

    return true;
  }

  Future<void> saveEditCarInfo() async {
    if (validateString(tag_labelText[0], chassisNoController.text) == false)
      return;
    if (validateString(tag_labelText[1], motorNoController.text) == false)
      return;
    if (validateString(tag_labelText[2], licensePlateNoController.text) ==
        false)
      return;
    if (validateString(tag_labelText[3], brandController.text) == false) return;
    if (validateString(tag_labelText[4], modelController.text) == false) return;
    if (validateString(tag_labelText[6], fuelTypeController.text) == false)
      return;
    if (validateNumber(tag_labelText[5], yearController.text) == false) return;

    final carInfo = CarInfo(
      chassisNo: chassisNoController.text.toUpperCase(),
      motorNo: motorNoController.text.toUpperCase(),
      licensePlate: licensePlateNoController.text.toUpperCase(),
      brand: brandController.text.trim(),
      brandModel: modelController.text.toUpperCase(),
      modelYear: int.tryParse(yearController.text),
      fuelType: fuelTypeController.text.toUpperCase(),
      dateTime: DateTime.now().toIso8601String(),
    );

    print("isEditMode: $isEditMode");
    if (isEditMode) {
      final updatedCar = CarInfo(
        chassisNo: chassisNoController.text.trim(),
        motorNo: motorNoController.text.trim(),
        licensePlate: licensePlateNoController.text.trim(),
        brand: brandController.text.trim(),
        brandModel: modelController.text.trim(),
        modelYear: int.tryParse(yearController.text.trim()),
        fuelType: fuelTypeController.text,
        dateTime: DateTime.now().toIso8601String(),
      );

      final ApiResponse response = await backend_services()
          .updateCarInfoByLicensePlate(
            licensePlateNoController.text.trim(),
            updatedCar,
          );
      if (response.status != 'error') {
        StringHelper.showInfoDialog(context, 'Düzenleme yapıldı');
      } else {
        StringHelper.showErrorDialog(context, '${response.message}');
      }
    } else {
      final ApiResponse response = await backend_services().insertCarInfo(
        carInfo,
      );
      if (response.status != 'error') {
        StringHelper.showInfoDialog(context, 'başarılı');
      } else {
        StringHelper.showErrorDialog(context, '${response.message}');
      }
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

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
    fuelTypeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıtlı Araçlar')),
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
                            fuelTypeController.clear();
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
                            fuelTypeController.clear();
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
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            _onPlateSelected();
                            searchByPlate();
                          });
                        },
                      ),
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
                  controller: fuelTypeController,
                  decoration: InputDecoration(
                    labelText: tag_labelText[6],
                    border: OutlineInputBorder(),
                  ),
                  enabled: canEdit,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    saveEditCarInfo();
                  },
                  child: Text(
                    isEditMode ? 'Değişiklikleri Kaydet' : 'Yeni Araç Kaydet',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
