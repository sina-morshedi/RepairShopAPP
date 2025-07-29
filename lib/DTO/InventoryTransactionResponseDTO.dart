import 'CarInfoDTO.dart';
import 'CustomerDTO.dart';
import 'UserProfileDTO.dart';
import 'InventoryItemDTO.dart';
import 'InventoryTransactionType.dart';

class InventoryTransactionResponseDTO {
  final String? id;
  final CarInfoDTO? carInfo;
  final CustomerDTO? customer;
  final UserProfileDTO? creatorUser;
  final InventoryItemDTO? inventoryItem;
  final int quantity;
  final TransactionType type;
  final String? description;
  final DateTime? dateTime;

InventoryTransactionResponseDTO({
    this.id,
    this.carInfo,
    this.customer,
    this.creatorUser,
    this.inventoryItem,
    required this.quantity,
    required this.type,
    this.description,
    this.dateTime,
  });

  factory InventoryTransactionResponseDTO.fromJson(Map<String, dynamic> json) {
    return InventoryTransactionResponseDTO(
      id: json['_id'] ?? json['id'],
      carInfo: json['carInfo'] != null ? CarInfoDTO.fromJson(json['carInfo']) : null,
      customer: json['customer'] != null ? CustomerDTO.fromJson(json['customer']) : null,
      creatorUser: json['creatorUser'] != null ? UserProfileDTO.fromJson(json['creatorUser']) : null,
      inventoryItem: json['inventoryItem'] != null ? InventoryItemDTO.fromJson(json['inventoryItem']) : null,
      quantity: json['quantity'] ?? 0,
      type: transactionTypeFromString(json['type']),
      description: json['description'],
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (carInfo != null) 'carInfo': carInfo!.toJson(),
      if (customer != null) 'customer': customer!.toJson(),
      if (creatorUser != null) 'creatorUser': creatorUser!.toJson(),
      if (inventoryItem != null) 'inventoryItem': inventoryItem!.toJson(),
      'quantity': quantity,
      'type': transactionTypeToString(type),
      if (description != null) 'description': description,
      if (dateTime != null) 'dateTime': dateTime!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'InventoryTransactionLogDTO('
        'id: $id, '
        'carInfo: $carInfo, '
        'customer: $customer, '
        'creatorUser: $creatorUser, '
        'inventoryItem: $inventoryItem, '
        'quantity: $quantity, '
        'type: ${transactionTypeToString(type)}, '
        'description: $description, '
        'dateTime: $dateTime'
        ')';
  }
}
