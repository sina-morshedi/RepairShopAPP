class PartUsed {
  final String partName;
  final double partPrice;
  final int quantity;
  PartUsed({
    required this.partName,
    this.partPrice=0,
    this.quantity = 1,
  });

  factory PartUsed.fromJson(Map<String, dynamic> json) {
    return PartUsed(
      partName: json['partName'],
      partPrice: (json['partPrice'] as num).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partName': partName,
      'partPrice': partPrice,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return 'PartUsed(partName: $partName, partPrice: $partPrice, quantity: $quantity)';
  }

}
