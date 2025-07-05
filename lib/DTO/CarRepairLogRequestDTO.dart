import 'PartUsed.dart'; // اگه PartUsed توی فایل جداست، اینو وارد کن

class CarRepairLogRequestDTO {
  final String carId;
  final String creatorUserId;
  final String? assignedUserId; // فیلد جدید
  final String? description;
  final String taskStatusId;
  final DateTime dateTime;
  final String? problemReportId;
  final List<PartUsed>? partsUsed; // ← اضافه شده

  CarRepairLogRequestDTO({
    required this.carId,
    required this.creatorUserId,
    this.assignedUserId,
    this.description,
    required this.taskStatusId,
    required this.dateTime,
    this.problemReportId,
    this.partsUsed, // ← اضافه شده
  });

  factory CarRepairLogRequestDTO.fromJson(Map<String, dynamic> json) {
    return CarRepairLogRequestDTO(
      carId: json['carId'],
      creatorUserId: json['creatorUserId'],
      assignedUserId: json['assignedUserId'],
      description: json['description'],
      taskStatusId: json['taskStatusId'],
      dateTime: DateTime.parse(json['dateTime']),
      problemReportId: json['problemReportId'],
      partsUsed: json['partsUsed'] != null
          ? (json['partsUsed'] as List)
          .map((item) => PartUsed.fromJson(item))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'creatorUserId': creatorUserId,
      if (assignedUserId != null) 'assignedUserId': assignedUserId,
      if (description != null) 'description': description,
      'taskStatusId': taskStatusId,
      'dateTime': dateTime.toIso8601String(),
      if (problemReportId != null) 'problemReportId': problemReportId,
      if (partsUsed != null)
        'partsUsed': partsUsed!.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CarRepairLogRequestDTO('
        'carId: $carId, '
        'creatorUserId: $creatorUserId, '
        'assignedUserId: $assignedUserId, '
        'description: $description, '
        'taskStatusId: $taskStatusId, '
        'dateTime: $dateTime, '
        'problemReportId: $problemReportId, '
        'partsUsed: $partsUsed'
        ')';
  }
}
