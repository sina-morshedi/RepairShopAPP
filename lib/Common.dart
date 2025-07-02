import 'package:autonetwork/DTO/CarInfoDTO.dart';
import 'package:autonetwork/dboAPI.dart';
import 'package:flutter/material.dart';
import 'type.dart';
import 'dart:ui';
import 'package:autonetwork/DTO/CarInfo.dart';
import 'package:autonetwork/backend_services/backend_services.dart';
import 'package:autonetwork/backend_services/ApiEndpoints.dart';

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




