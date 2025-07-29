import 'InventoryTransactionType.dart';

class InventoryTransactionRequestDTO {
  final String? id;
  final String? carInfoId;
  final String? customerId;
  final String creatorUserId;
  final String inventoryItemId;
  final int quantity;
  final TransactionType type;
  final String? description;
  final DateTime? dateTime;

  InventoryTransactionRequestDTO({
    this.id,
    this.carInfoId,
    this.customerId,
    required this.creatorUserId,
    required this.inventoryItemId,
    required this.quantity,
    required this.type,
    this.description,
    this.dateTime,
  });

  factory InventoryTransactionRequestDTO.fromJson(Map<String, dynamic> json) {
    return InventoryTransactionRequestDTO(
      id: json['id'],
      carInfoId: json['carInfoId'],
      customerId: json['customerId'],
      creatorUserId: json['creatorUserId'],
      inventoryItemId: json['inventoryItemId'],
      quantity: json['quantity'],
      type: transactionTypeFromString(json['type']),
      description: json['description'],
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (carInfoId != null) 'carInfoId': carInfoId,
      if (customerId != null) 'customerId': customerId,
      'creatorUserId': creatorUserId,
      'inventoryItemId': inventoryItemId,
      'quantity': quantity,
      'type': transactionTypeToString(type),
      if (description != null) 'description': description,
      if (dateTime != null) 'dateTime': dateTime!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'InventoryTransactionRequestDTO('
        'id: $id, '
        'carInfoId: $carInfoId, '
        'customerId: $customerId, '
        'creatorUserId: $creatorUserId, '
        'inventoryItemId: $inventoryItemId, '
        'quantity: $quantity, '
        'type: ${transactionTypeToString(type)}, '
        'description: $description, '
        'dateTime: $dateTime'
        ')';
  }
}
