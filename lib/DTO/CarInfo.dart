class CarInfo {
  final String chassisNo;
  final String motorNo;
  final String licensePlate;
  final String brand;
  final String brandModel;
  final int? modelYear;
  final String fuelType;
  final String dateTime;  // ISO8601 string

  CarInfo({
    required this.chassisNo,
    required this.motorNo,
    required this.licensePlate,
    required this.brand,
    required this.brandModel,
    required this.modelYear,
    required this.fuelType,
    required this.dateTime,
  });

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      chassisNo: json['chassisNo'],
      motorNo: json['motorNo'],
      licensePlate: json['licensePlate'],
      brand: json['brand'],
      brandModel: json['brandModel'],
      modelYear: json['modelYear'],
      fuelType: json['fuelType'],
      dateTime: json['dateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "chassisNo": chassisNo,
      "motorNo": motorNo,
      "licensePlate": licensePlate,
      "brand": brand,
      "brandModel": brandModel,
      "modelYear": modelYear,
      "fuelType": fuelType,
      "dateTime": dateTime,
    };
  }
}