import 'package:autonetwork/DTO/CarInfoDTO.dart';
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
  late TabController _tabController;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController chassisNoController = TextEditingController();
  final TextEditingController motorNoController = TextEditingController();
  final TextEditingController licensePlateNoController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController fuelTypeController = TextEditingController();

  bool isEditEnabled = false;
  bool searchCompleted = false;

  static const List<String> tag_labelText = [
    "ŞASE NO",
    "MOTOR NO",
    "PLAKA",
    "MARKASI",
    "TİCARİ ADI",
    "MODEL YILI",
    "YAKIT CİNSİ",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _clearAllFields();
        setState(() {
          isEditEnabled = _tabController.index == 1;
          searchCompleted = false;
        });
      }
    });
  }

  void _clearAllFields() {
    searchController.clear();
    chassisNoController.clear();
    motorNoController.clear();
    licensePlateNoController.clear();
    brandController.clear();
    modelController.clear();
    yearController.clear();
    fuelTypeController.clear();
  }

  Future<void> searchByPlate() async {
    final response = await backend_services()
        .getCarInfoByLicensePlate(searchController.text.trim().toUpperCase());

    if (response.status == 'success' && response.data != null) {
      final car = response.data!;
      setState(() {
        licensePlateNoController.text = car.licensePlate;
        chassisNoController.text = car.chassisNo;
        motorNoController.text = car.motorNo;
        brandController.text = car.brand;
        modelController.text = car.brandModel;
        yearController.text = car.modelYear?.toString() ?? '';
        fuelTypeController.text = car.fuelType;
        searchCompleted = true;
      });
    } else {
      StringHelper.showErrorDialog(
        context,
        response.message ?? 'Araç bulunamadı veya sunucu hatası',
      );
    }
  }

  bool get isInputEnabled => !isEditEnabled || (isEditEnabled && searchCompleted);

  Future<void> saveCarInfo() async {
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

    ApiResponse response;

    if (isEditEnabled) {
      response = await backend_services().updateCarInfoByLicensePlate(
        licensePlateNoController.text.trim().toUpperCase(),
        carInfo,
      );
    } else {
      response = await backend_services().insertCarInfo(carInfo);
    }

    if (response.status != 'error') {
      StringHelper.showInfoDialog(context, 'Başarılı işlem');
    } else {
      StringHelper.showErrorDialog(context, response.message ?? 'Hata');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    chassisNoController.dispose();
    motorNoController.dispose();
    licensePlateNoController.dispose();
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();
    fuelTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Bilgileri'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Yeni Kayıt'),
            Tab(text: 'Düzenle'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForm(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Plaka ile Ara',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: searchByPlate,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => searchByPlate(),
                ),
              ),
              Expanded(child: _buildForm()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTextField(chassisNoController, tag_labelText[0]),
          const SizedBox(height: 10),
          _buildTextField(motorNoController, tag_labelText[1]),
          const SizedBox(height: 10),
          _buildTextField(licensePlateNoController, tag_labelText[2]),
          const SizedBox(height: 10),
          _buildTextField(brandController, tag_labelText[3]),
          const SizedBox(height: 10),
          _buildTextField(modelController, tag_labelText[4]),
          const SizedBox(height: 10),
          _buildTextField(yearController, tag_labelText[5], isNumber: true),
          const SizedBox(height: 10),
          _buildTextField(fuelTypeController, tag_labelText[6]),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isInputEnabled ? saveCarInfo : null,
            child: Text(isEditEnabled ? 'Güncelle' : 'Kaydet'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      enabled: isInputEnabled,
      textCapitalization: TextCapitalization.characters,
    );
  }
}
