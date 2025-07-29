import 'dart:convert';

import 'SaleItem.dart';
import 'PaymentRecord.dart';

class InventorySaleLogDTO {
  String? id;
  String? customerName;
  List<SaleItem>? soldItems;
  double? totalAmount;
  double? remainingAmount; // ✅ جدید
  DateTime? saleDate;
  List<PaymentRecord>? paymentRecords;

  InventorySaleLogDTO({
    this.id,
    this.customerName,
    this.soldItems,
    this.totalAmount,
    this.remainingAmount, // ✅ جدید
    this.saleDate,
    this.paymentRecords,
  });

  factory InventorySaleLogDTO.fromJson(Map<String, dynamic> json) {
    return InventorySaleLogDTO(
      id: json['_id'] ?? json['id'],
      customerName: json['customerName'],
      soldItems: json['soldItems'] != null
          ? (json['soldItems'] as List)
          .map((e) => SaleItem.fromJson(e))
          .toList()
          : null,
      totalAmount: (json['totalAmount'] != null)
          ? (json['totalAmount'] as num).toDouble()
          : null,
      remainingAmount: (json['remainingAmount'] != null)
          ? (json['remainingAmount'] as num).toDouble()
          : null, // ✅ جدید
      saleDate: json['saleDate'] != null
          ? DateTime.parse(json['saleDate'])
          : null,
      paymentRecords: json['paymentRecords'] != null
          ? (json['paymentRecords'] as List)
          .map((e) => PaymentRecord.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (customerName != null) 'customerName': customerName,
      if (soldItems != null)
        'soldItems': soldItems!.map((e) => e.toJson()).toList(),
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (remainingAmount != null) 'remainingAmount': remainingAmount, // ✅ جدید
      if (saleDate != null) 'saleDate': saleDate!.toIso8601String(),
      if (paymentRecords != null)
        'paymentRecords': paymentRecords!.map((e) => e.toJson()).toList(),
    };
  }

  InventorySaleLogDTO copyWith({
    String? id,
    String? customerName,
    List<SaleItem>? soldItems,
    double? totalAmount,
    double? remainingAmount,
    DateTime? saleDate,
    List<PaymentRecord>? paymentRecords,
  }) {
    return InventorySaleLogDTO(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      soldItems: soldItems ?? this.soldItems ?? [],
      totalAmount: totalAmount ?? this.totalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      saleDate: saleDate ?? this.saleDate,
      paymentRecords: paymentRecords ?? this.paymentRecords ?? [],
    );
  }


  @override
  String toString() {
    return 'InventorySaleLogDTO{'
        'id: $id, customerName: $customerName, '
        'totalAmount: $totalAmount, '
        'remainingAmount: $remainingAmount, '
        'saleDate: $saleDate, '
        'soldItems: $soldItems, '
        'paymentRecords: $paymentRecords}';
  }
}

