class CarProblemReportRequestDTO {
  String? id;
  String carId;
  String creatorUserId;
  String problemSummary;
  DateTime dateTime;

  CarProblemReportRequestDTO({
    this.id,
    required this.carId,
    required this.creatorUserId,
    required this.problemSummary,
    required this.dateTime,
  });

  factory CarProblemReportRequestDTO.fromJson(Map<String, dynamic> json) {
    return CarProblemReportRequestDTO(
      id: json['id'] as String?,
      carId: json['carId']?.toString() ?? '',
      creatorUserId: json['creatorUserId']?.toString() ?? '',
      problemSummary: json['problemSummary']?.toString() ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'].toString())
          : DateTime.now(),  // یا مقدار پیش‌فرض مناسب دیگری
    );
  }


  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'carId': carId,
      'creatorUserId': creatorUserId,
      'problemSummary': problemSummary,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
