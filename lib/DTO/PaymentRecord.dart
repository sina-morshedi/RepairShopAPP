class PaymentRecord {
  final DateTime paymentDate;
  final double amountPaid;

  PaymentRecord({
    required this.paymentDate,
    required this.amountPaid,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      paymentDate: DateTime.parse(json['paymentDate']),
      amountPaid: (json['amountPaid'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentDate': paymentDate.toIso8601String(),
      'amountPaid': amountPaid,
    };
  }

  @override
  String toString() {
    return 'PaymentRecord(paymentDate: ${paymentDate.toIso8601String()}, amountPaid: $amountPaid)';
  }
}
