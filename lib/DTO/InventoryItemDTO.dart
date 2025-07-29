import 'dart:core';
import 'package:intl/intl.dart';

class InventoryItemDTO {
  String id;
  String partName;
  String barcode;
  String category;
  int? quantity;
  String unit;
  String location;
  double? purchasePrice;
  double? salePrice;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  InventoryItemDTO({
    this.id = '',
    this.partName = '',
    this.barcode = '',
    this.category = '',
    this.quantity,
    this.unit = '',
    this.location = '',
    this.purchasePrice,
    this.salePrice,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryItemDTO.fromJson(Map<String, dynamic> json) {
    return InventoryItemDTO(
      id: json['id'] ?? '',
      partName: json['partName'] ?? '',
      barcode: json['barcode'] ?? '',
      category: json['category'] ?? '',
      quantity: json['quantity'] as int?,
      unit: json['unit'] ?? '',
      location: json['location'] ?? '',
      purchasePrice: (json['purchasePrice'] != null)
          ? (json['purchasePrice'] as num).toDouble()
          : null,
      salePrice: (json['salePrice'] != null)
          ? (json['salePrice'] as num).toDouble()
          : null,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partName': partName,
      'barcode': barcode,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'location': location,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'InventoryItemDTO('
        'id: $id, '
        'partName: $partName, '
        'barcode: $barcode, '
        'category: $category, '
        'quantity: $quantity, '
        'unit: $unit, '
        'location: $location, '
        'purchasePrice: $purchasePrice, '
        'salePrice: $salePrice, '
        'isActive: $isActive, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}

