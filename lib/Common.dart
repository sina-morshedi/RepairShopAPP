import 'package:autonetwork/dboAPI.dart';
import 'package:flutter/material.dart';
import 'type.dart';
import 'dart:ui';
import 'dart:ffi' as ffi;

enum tag_index {chassis_no,
  motor_no,
  license_plate,
  brand,
  brand_model,
  model_year,
  fuel_type,
  date_time,}

bool validateString(BuildContext context, String tag, String str) {
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

bool validateNumber(BuildContext context,String tag, String str) {
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

class CarInfoUtility{

  static final dboAPI api = dboAPI();


  static final List<String> tag_labelText = [
    "ŞASE NO",
    "MOTOR NO",
    "PLAKA",
    "MARKASI",
    "TİCARİ ADI",
    "MODEL YILI",
    "YAKIT CİNSİ",
  ];

  static Future<ApiResponseDatabase<carInfoFromDb>> _fetchCarInfoByLicensePlate(String plate) async {
    return await api.jobGetCarInfoWithID('license_plate', plate);
  }

  static Future<carInfoFromDb?> searchByPlate(BuildContext context, String tag, String plate) async {
    plate = plate.trim().toUpperCase();

    if (!validateString(context,tag, plate)) return null;

    final response = await _fetchCarInfoByLicensePlate(plate);

    if (response.hasError) {
      if (response.dbo_error != null) {
        showErrorDialog(context, response.dbo_error!.message, response.dbo_error!.error_code);
      }
      if (response.error != null) {
        showErrorDialog(context, response.error!.message, response.error!.statusCode.toString());
      }
      return null;
    } else if (response.data != null) {
      final car = response.data!;
      return carInfoFromDb(
        car_id: car.car_id,
        license_plate: car.license_plate,
        chassis_no: car.chassis_no,
        motor_no: car.motor_no,
        brand: car.brand,
        brand_model: car.brand_model,
        model_year: car.model_year,
        fuel_type: car.fuel_type,
        date_time: car.date_time,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bu plakaya sahip araç bulunamadı.", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  static void showCarInfoDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ruhsat Bilgi"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Tamam"),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> showRepairDialog(BuildContext context, String infoText) async {
    String enteredValue = "";

    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Onarım işlemlerinin başlaması"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(infoText),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel pressed
              },
              child: Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                print("Repair started by: $enteredValue");
                Navigator.of(context).pop(true); // Repair started
              },
              child: Text("Onarımı başlat"),
            ),
          ],
        );
      },
    );
  }

  static void showErrorDialog(BuildContext context, String errorMessage, String errorCode) async {
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

  static int GetTaskID(List<TaskStatus?> task, String keyword) {
    int? matchedId;

    try {
      matchedId = task
          .whereType<TaskStatus>() // filters out nulls
          .firstWhere((t) => t.task_status == keyword)
          .id;
      print("Matched ID: $matchedId");
    } catch (e) {
      print("No task status found matching '$keyword'");
    }

    return matchedId ?? -1; // ✅ Always return an int, even if not found
  }

}


