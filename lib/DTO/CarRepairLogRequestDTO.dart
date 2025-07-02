class CarRepairLogRequestDTO {
  final String carId;
  final String creatorUserId;
  final String? assignedUserId;  // فیلد جدید
  final String? description;
  final String taskStatusId;
  final DateTime dateTime;
  final String? problemReportId;

  CarRepairLogRequestDTO({
    required this.carId,
    required this.creatorUserId,
    this.assignedUserId,
    this.description,
    required this.taskStatusId,
    required this.dateTime,
    this.problemReportId,
  });

  factory CarRepairLogRequestDTO.fromJson(Map<String, dynamic> json) {
    return CarRepairLogRequestDTO(
      carId: json['carId'],
      creatorUserId: json['creatorUserId'],
      assignedUserId: json['assignedUserId'],  // اضافه شده
      description: json['description'],
      taskStatusId: json['taskStatusId'],
      dateTime: DateTime.parse(json['dateTime']),
      problemReportId: json['problemReportId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'creatorUserId': creatorUserId,
      if (assignedUserId != null) 'assignedUserId': assignedUserId, // اضافه شده
      if (description != null) 'description': description,
      'taskStatusId': taskStatusId,
      'dateTime': dateTime.toIso8601String(),
      if (problemReportId != null) 'problemReportId': problemReportId,
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
        'problemReportId: $problemReportId'
        ')';
  }

}
