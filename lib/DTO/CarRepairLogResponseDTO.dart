import 'CarInfoDTO.dart';
import 'CarProblemReportResponseDTO.dart';
import 'UserProfileDTO.dart';
import 'TaskStatusDTO.dart';
import 'PartUsed.dart';

class CarRepairLogResponseDTO {
  final String? id;
  final CarInfoDTO carInfo;
  final UserProfileDTO creatorUser;
  final UserProfileDTO? assignedUser;   // ← اضافه شده
  final String? description;
  final TaskStatusDTO taskStatus;
  final DateTime dateTime;
  final CarProblemReportResponseDTO? problemReport;
  final List<PartUsed>? partsUsed;       // ← اضافه شده

  CarRepairLogResponseDTO({
    this.id,
    required this.carInfo,
    required this.creatorUser,
    this.assignedUser,
    this.description,
    required this.taskStatus,
    required this.dateTime,
    this.problemReport,
    this.partsUsed,   // ← اضافه شده
  });

  factory CarRepairLogResponseDTO.fromJson(Map<String, dynamic> json) {
    return CarRepairLogResponseDTO(
      id: json['_id'] ?? json['id'],
      carInfo: CarInfoDTO.fromJson(json['carInfo']),
      creatorUser: UserProfileDTO.fromJson(json['creatorUser']),
      assignedUser: json['assignedUser'] != null
          ? UserProfileDTO.fromJson(json['assignedUser'])
          : null,
      description: json['description'],
      taskStatus: TaskStatusDTO.fromJson(json['taskStatus']),
      dateTime: DateTime.parse(json['dateTime']),
      problemReport: json['problemReport'] != null
          ? CarProblemReportResponseDTO.fromJson(json['problemReport'])
          : null,
      partsUsed: json['partsUsed'] != null
          ? (json['partsUsed'] as List)
          .map((item) => PartUsed.fromJson(item))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'carInfo': carInfo.toJson(),
      'creatorUser': creatorUser.toJson(),
      if (assignedUser != null) 'assignedUser': assignedUser!.toJson(),
      if (description != null) 'description': description,
      'taskStatus': taskStatus.toJson(),
      'dateTime': dateTime.toIso8601String(),
      if (problemReport != null) 'problemReport': problemReport!.toJson(),
      if (partsUsed != null)
        'partsUsed': partsUsed!.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CarRepairLogResponseDTO('
        'id: $id, '
        'carInfo: $carInfo, '
        'creatorUser: $creatorUser, '
        'assignedUser: $assignedUser, '
        'description: $description, '
        'taskStatus: $taskStatus, '
        'dateTime: $dateTime, '
        'problemReport: $problemReport, '
        'partsUsed: $partsUsed'
        ')';
  }
}
