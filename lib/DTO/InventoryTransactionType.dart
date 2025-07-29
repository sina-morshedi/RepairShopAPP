enum TransactionType {
  SALE,
  CONSUMPTION,
  RETURN_SALE,
  RETURN_CONSUMPTION,
  DAMAGE,
  INCOMING  // اضافه شده برای ورودی کالا
}


TransactionType transactionTypeFromString(String? type) {
  if (type == null) {
    throw Exception("TransactionType cannot be null");
  }
  return TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
    orElse: () => TransactionType.SALE,
  );
}

String transactionTypeToString(TransactionType type) {
  return type.toString().split('.').last;
}