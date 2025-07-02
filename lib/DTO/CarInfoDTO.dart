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
    return CarInfoDTO(
      id: json['id'] ?? '',
      chassisNo: json['chassisNo'] ?? '',
      motorNo: json['motorNo'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      brand: json['brand'] ?? '',
      brandModel: json['brandModel'] ?? '',
      modelYear: json['modelYear'],
      fuelType: json['fuelType'] ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : null, // یا مقدار null در صورت اجازه
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
