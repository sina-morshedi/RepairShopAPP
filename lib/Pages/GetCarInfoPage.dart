import 'package:autonetwork/DTO/CarInfoDTO.dart';
import 'package:flutter/material.dart';
import '../dboAPI.dart';
import '../type.dart';
import 'package:autonetwork/utils/string_helper.dart';
import 'package:autonetwork/backend_services/backend_services.dart';
import 'package:autonetwork/DTO/CarInfo.dart';
import 'package:autonetwork/backend_services/ApiEndpoints.dart';

class GetCarInfoPage extends StatefulWidget {
  final void Function(String plate)? onSuccess;

  const GetCarInfoPage({Key? key, this.onSuccess}) : super(key: key);

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

  final FocusNode chassisFocus = FocusNode();
  final FocusNode motorFocus = FocusNode();
  final FocusNode plateFocus = FocusNode();
  final FocusNode brandFocus = FocusNode();
  final FocusNode modelFocus = FocusNode();
  final FocusNode yearFocus = FocusNode();

  String? selectedFuelType;

  bool isEditEnabled = false;
  bool searchCompleted = false;

  static const List<String> tag_labelText = [
    "PLAKA",
    "ŞASE NO",
    "MOTOR NO",
    "MARKASI",
    "TİCARİ ADI",
    "MODEL YILI",
    "YAKIT CİNSİ",
  ];

  static const List<String> fuelTypes = [
    "BENZİNLİ",
    "DİZEL",
    "LPG",
    "BENZİNLİ LPG",
    "ELEKTRİKLİ"
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
    selectedFuelType = null;
  }

  String? getClosestFuelType(String rawValue) {
    rawValue = rawValue.toUpperCase();

    // exact match
    if (fuelTypes.contains(rawValue)) return rawValue;

    // loose match (find first that contains input or vice versa)
    for (var type in fuelTypes) {
      if (type.contains(rawValue) || rawValue.contains(type)) {
        return type;
      }
    }

    // fallback to first item (optional)
    return null;
  }


  Future<void> searchByPlate() async {
    final response = await CarInfoApi()
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

        // 🔸 اصلاح مهم در این‌جا:
        selectedFuelType = getClosestFuelType(car.fuelType);
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
      fuelType: selectedFuelType ?? "",
      dateTime: DateTime.now().toIso8601String(),
    );

    ApiResponse response;

    if (isEditEnabled) {
      response = await CarInfoApi().updateCarInfoByLicensePlate(
        licensePlateNoController.text.trim().toUpperCase(),
        carInfo,
      );
    } else {
      response = await CarInfoApi().insertCarInfo(carInfo);
    }

    if (response.status != 'error') {
      StringHelper.showInfoDialog(context, 'Başarılı işlem');
      widget.onSuccess?.call(licensePlateNoController.text.trim().toUpperCase());
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
    chassisFocus.dispose();
    motorFocus.dispose();
    plateFocus.dispose();
    brandFocus.dispose();
    modelFocus.dispose();
    yearFocus.dispose();
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
          _buildTextField(licensePlateNoController, tag_labelText[0], focusNode: plateFocus, nextFocus: chassisFocus),
          const SizedBox(height: 10),
          _buildTextField(chassisNoController, tag_labelText[1], focusNode: chassisFocus, nextFocus: motorFocus),
          const SizedBox(height: 10),
          _buildTextField(motorNoController, tag_labelText[2], focusNode: motorFocus, nextFocus: brandFocus),
          const SizedBox(height: 10),
          _buildTextField(brandController, tag_labelText[3], focusNode: brandFocus, nextFocus: modelFocus),
          const SizedBox(height: 10),
          _buildTextField(modelController, tag_labelText[4], focusNode: modelFocus, nextFocus: yearFocus),
          const SizedBox(height: 10),
          _buildTextField(yearController, tag_labelText[5], isNumber: true, focusNode: yearFocus),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedFuelType,
            items: fuelTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: isInputEnabled
                ? (value) => setState(() {
              selectedFuelType = value!;
            })
                : null,
            decoration: InputDecoration(
              labelText: tag_labelText[6],
              border: const OutlineInputBorder(),
            ),
            onTap: () {
              FocusScope.of(context).unfocus();
            },
          ),
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
      {bool isNumber = false, FocusNode? focusNode, FocusNode? nextFocus}) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      enabled: isInputEnabled,
      textCapitalization: TextCapitalization.characters,
      onSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
    );
  }
}
