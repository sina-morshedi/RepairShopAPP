import 'package:flutter/material.dart';
import 'dboAPI.dart';
import 'type.dart';


class EditCarInfoApp extends StatefulWidget {
  const EditCarInfoApp({super.key});
  @override
  _EditCarInfoAppState createState() => _EditCarInfoAppState();
}

class _EditCarInfoAppState extends State<EditCarInfoApp> {
  // Controllers for car info fields
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _chassisNoController = TextEditingController();
  final TextEditingController _motorNoController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _brandModelController = TextEditingController();
  final TextEditingController _modelYearController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  int? _carId;

  final dboAPI api = dboAPI();

  final TextEditingController licensePlateController = TextEditingController();

  Future<ApiResponseDatabase<carInfoFromDb>> _fetchCarInfoByLicensePlate(String plate) async {
    return await api.jobGetCarInfoWithID('license_plate', plate);
  }

  Future<void> fetchCarInfo() async {
    String plate = licensePlateController.text.trim().toUpperCase();

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

  void _showSearchDialog() {
    final TextEditingController _searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Plaka numarasına göre arama'),
        content: TextField(
          controller: _searchController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'Plaka numarası',
            hintText: 'Örneğin, 12B34567',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              String plate = _searchController.text.trim().toUpperCase();
              if (plate.isEmpty) return;

              Navigator.of(ctx).pop();

              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });


              var response = await _fetchCarInfoByLicensePlate(plate);

              setState(() {
                _isLoading = false;
              });

              if (response.error != null) {
                setState(() {
                  _errorMessage = response.error!.message;
                });
              } else if (response.data != null) {
                var car = response.data!;

                setState(() {
                  _carId = car.car_id;
                  _licensePlateController.text = car.license_plate ?? '';
                  _chassisNoController.text = car.chassis_no ?? '';
                  _motorNoController.text = car.motor_no ?? '';
                  _brandController.text = car.brand ?? '';
                  _brandModelController.text = car.brand_model ?? '';
                  _modelYearController.text = car.model_year?.toString() ?? '';
                  _fuelTypeController.text = car.fuel_type ?? '';
                });

              } else {
                setState(() {
                  _errorMessage = 'Bu plakaya sahip araç bulunamadı.';
                });
              }
            },
            child: Text('Ara'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCarInfo() async {
    if (_carId == null) {
      setState(() {
        _errorMessage = "Araç bilgisi yüklü değil.";
      });
      return;
    }

    Map<String, dynamic> carData = {
      "chassis_no": _chassisNoController.text.toUpperCase(),
      "motor_no": _motorNoController.text.toUpperCase(),
      "license_plate": _licensePlateController.text.toUpperCase(),
      "brand": _brandController.text.toUpperCase(),
      "brand_model": _brandModelController.text.toUpperCase(),
      "model_year": int.tryParse(_modelYearController.text),
      "fuel_type": _fuelTypeController.text.toUpperCase(),
      "date_time": DateTime.now().toIso8601String()
    };

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    var response = await api.jobUpdateCarInfo(_carId!, carData);

    setState(() {
      _isLoading = false;
    });

    if (response.error != null) {
      setState(() {
        _errorMessage = response.error!.message;
      });
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
  void dispose() {
    _licensePlateController.dispose();
    _chassisNoController.dispose();
    _motorNoController.dispose();
    _brandController.dispose();
    _brandModelController.dispose();
    _modelYearController.dispose();
    _fuelTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                actions: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _showSearchDialog,
                    tooltip: 'Plaka ile arama',
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5F46AA),
                      foregroundColor: Colors.white,
                    ),
                  )
                ]
            ),
          ],
        ),
      ),
      // appBar: AppBar(
      //   title: Text('ویرایش اطلاعات خودرو'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.search),
      //       onPressed: _showSearchDialog,
      //       tooltip: 'جستجو بر اساس پلاک',
      //     )
      //   ],
      // ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              if (_errorMessage != null) ...[
                Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 10),
              ],
              TextField(
                controller: _licensePlateController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: 'ŞASE NO'),
              ),
              TextField(
                controller: _chassisNoController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: 'MOTOR NO'),
              ),
              TextField(
                controller: _motorNoController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: 'PLAKA'),
              ),
              TextField(
                controller: _brandController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: 'MARKASI'),
              ),
              TextField(
                controller: _brandModelController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: 'TİCARİ ADI'),
              ),
              TextField(
                controller: _modelYearController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: 'MODEL YILI'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _fuelTypeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: 'YAKIT CİNSİ'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveCarInfo();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5F46AA),
                  foregroundColor: Colors.white,
                ),
                child: Text('Kaydet'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
