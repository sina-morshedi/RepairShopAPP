class CustomerDTO{
  String? id;
  String fullName;
  String phone; // حالا اجباری شده
  String? nationalId;
  String? address;
  DateTime? createdAt;

  CustomerDTO({
    this.id,
    required this.fullName,
    required this.phone,
    this.nationalId,
    this.address,
    this.createdAt,
  });

  factory CustomerDTO.fromJson(Map<String, dynamic> json) {
    return CustomerDTO(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      nationalId: json['nationalId'],
      address: json['address'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'phone': phone,
      if (nationalId != null) 'nationalId': nationalId,
      if (address != null) 'address': address,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CustomerDTO('
        'id: ${id ?? "null"}, '
        'fullName: $fullName, '
        'phone: $phone, '
        'nationalId: ${nationalId ?? "null"}, '
        'address: ${address ?? "null"}, '
        'createdAt: ${createdAt?.toIso8601String() ?? "null"}'
        ')';
  }

}
