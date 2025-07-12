import 'dart:core';
import 'package:intl/intl.dart';
class CarInfoDTO {
  final String id;
  final String chassisNo;
  final String motorNo;
  final String licensePlate;
  final String brand;
  final String brandModel;
  final int? modelYear;
  final String fuelType;
  final DateTime? dateTime;

  CarInfoDTO({
    required this.id,
    required this.chassisNo,
    required this.motorNo,
    required this.licensePlate,
    required this.brand,
    required this.brandModel,
    this.modelYear,
    required this.fuelType,
    required this.dateTime,
  });

  factory CarInfoDTO.fromJson(Map<String, dynamic> json) {
    final cutoffDate = DateTime(2025, 7, 11, 17, 47, 00); // تاریخ شروع استفاده از UTC
    DateTime? adjustedDate;

    if (json['dateTime'] != null) {
      final rawDate = DateTime.parse(json['dateTime']);
      adjustedDate = rawDate.isBefore(cutoffDate) ? rawDate : rawDate.toLocal();
    } else {
      adjustedDate = null;
    }

    return CarInfoDTO(
      id: json['id'] ?? '',
      chassisNo: json['chassisNo'] ?? '',
      motorNo: json['motorNo'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      brand: json['brand'] ?? '',
      brandModel: json['brandModel'] ?? '',
      modelYear: json['modelYear'],
      fuelType: json['fuelType'] ?? '',
      dateTime: adjustedDate,
    );
  }



  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "chassisNo": chassisNo,
      "motorNo": motorNo,
      "licensePlate": licensePlate,
      "brand": brand,
      "brandModel": brandModel,
      "modelYear": modelYear,
      "fuelType": fuelType,
      "dateTime": dateTime?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CarInfoDTO('
        'id: $id, '
        'chassisNo: $chassisNo, '
        'motorNo: $motorNo, '
        'licensePlate: $licensePlate, '
        'brand: $brand, '
        'brandModel: $brandModel, '
        'modelYear: $modelYear, '
        'fuelType: $fuelType, '
        'dateTime: ${dateTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime!) : 'null'}'
        ')';
  }

}
