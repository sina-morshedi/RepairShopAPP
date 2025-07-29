class InventoryChangeRequestDTO {
  String? itemId;
  int? amount;
  DateTime? updatedAt;
  double? purchasePrice;
  double? salePrice;
  String? creatorUserId;

  InventoryChangeRequestDTO({
    this.itemId,
    this.amount,
    this.updatedAt,
    this.purchasePrice,
    this.salePrice,
    this.creatorUserId,
  });

  factory InventoryChangeRequestDTO.fromJson(Map<String, dynamic> json) {
    return InventoryChangeRequestDTO(
      itemId: json['itemId'] as String?,
      amount: json['amount'] as int?,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      purchasePrice: json['purchasePrice'] != null ? (json['purchasePrice'] as num).toDouble() : null,
      salePrice: json['salePrice'] != null ? (json['salePrice'] as num).toDouble() : null,
      creatorUserId: json['creatorUserId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'amount': amount,
      'updatedAt': updatedAt?.toIso8601String(),
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'creatorUserId': creatorUserId,
    };
  }

  @override
  String toString() {
    return 'InventoryChangeRequestDTO('
        'itemId: $itemId, '
        'amount: $amount, '
        'updatedAt: $updatedAt, '
        'purchasePrice: $purchasePrice, '
        'salePrice: $salePrice, '
        'creatorUserId: $creatorUserId'
        ')';
  }
}
