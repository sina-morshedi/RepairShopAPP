import 'dart:ui';
import 'package:autonetwork/DTO/CarInfoDTO.dart';
import 'package:flutter/material.dart';
import '../../dboAPI.dart';
import '../../type.dart';
import '../../backend_services/backend_services.dart';

class Sharecomponents{

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


  static Future<CarInfoDTO?> searchByPlate(BuildContext context, String plate) async {
    final response = await backend_services()
        .getCarInfoByLicensePlate(plate.toUpperCase());
    if (response.status == 'success' && response.data != null) {
      return response.data;

    } else {
      showErrorDialog(context, response.status, response.message!);
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

  static Future<bool?> showRepairDialog(BuildContext context, CarInfoDTO car) async {
    String enteredValue = "";

    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Onarım işlemlerinin başlaması"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // چپ‌چین کردن محتوا
            children: [
              Text('${tag_labelText[0]}: ${car.chassisNo}', textAlign: TextAlign.left),
              Text('${tag_labelText[1]}: ${car.motorNo}', textAlign: TextAlign.left),
              Text('${tag_labelText[2]}: ${car.licensePlate}', textAlign: TextAlign.left),
              Text('${tag_labelText[3]}: ${car.brand}', textAlign: TextAlign.left),
              Text('${tag_labelText[4]}: ${car.brandModel}', textAlign: TextAlign.left),
              Text('${tag_labelText[5]}: ${car.modelYear}', textAlign: TextAlign.left),
              Text('${tag_labelText[6]}: ${car.fuelType}', textAlign: TextAlign.left),
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