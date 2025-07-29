class SaleItem {
  String? inventoryItemId;
  String? partName;
  int? quantitySold;
  double? unitSalePrice;

  SaleItem({
    this.inventoryItemId,
    this.partName,
    this.quantitySold,
    this.unitSalePrice,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      inventoryItemId: json['inventoryItemId'],
      partName: json['partName'],
      quantitySold: json['quantitySold'],
      unitSalePrice: (json['unitSalePrice'] != null)
          ? (json['unitSalePrice'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (inventoryItemId != null) 'inventoryItemId': inventoryItemId,
      if (partName != null) 'partName': partName,
      if (quantitySold != null) 'quantitySold': quantitySold,
      if (unitSalePrice != null) 'unitSalePrice': unitSalePrice,
    };
  }

  SaleItem copyWith({
    String? inventoryItemId,
    String? partName,
    int? quantitySold,
    double? unitSalePrice,
  }) {
    return SaleItem(
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      partName: partName ?? this.partName,
      quantitySold: quantitySold ?? this.quantitySold,
      unitSalePrice: unitSalePrice ?? this.unitSalePrice,
    );
  }

  @override
  String toString() {
    return 'SaleItem{inventoryItemId: $inventoryItemId, partName: $partName, quantitySold: $quantitySold, unitSalePrice: $unitSalePrice}';
  }
}
