import 'CarInfoDTO.dart';
import 'CarProblemReportResponseDTO.dart';
import 'UserProfileDTO.dart';
import 'TaskStatusDTO.dart';

class CarRepairLogResponseDTO {
  final String? id;
  final CarInfoDTO carInfo;
  final UserProfileDTO creatorUser;
  final UserProfileDTO? assignedUser;   // ← اضافه شده
  final String? description;
  final TaskStatusDTO taskStatus;
  final DateTime dateTime;
  final CarProblemReportResponseDTO? problemReport;

  CarRepairLogResponseDTO({
    this.id,
    required this.carInfo,
    required this.creatorUser,
    this.assignedUser,            // ← اضافه شده
    this.description,
    required this.taskStatus,
    required this.dateTime,
    this.problemReport,
  });

  factory CarRepairLogResponseDTO.fromJson(Map<String, dynamic> json) {
    return CarRepairLogResponseDTO(
      id: json['_id'] ?? json['id'],
      carInfo: CarInfoDTO.fromJson(json['carInfo']),
      creatorUser: UserProfileDTO.fromJson(json['creatorUser']),
      assignedUser: json['assignedUser'] != null
          ? UserProfileDTO.fromJson(json['assignedUser'])
          : null,                    // ← اضافه شده
      description: json['description'],
      taskStatus: TaskStatusDTO.fromJson(json['taskStatus']),
      dateTime: DateTime.parse(json['dateTime']),
      problemReport: json['problemReport'] != null
          ? CarProblemReportResponseDTO.fromJson(json['problemReport'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'carInfo': carInfo.toJson(),
      'creatorUser': creatorUser.toJson(),
      if (assignedUser != null) 'assignedUser': assignedUser!.toJson(),  // ← اضافه شده
      if (description != null) 'description': description,
      'taskStatus': taskStatus.toJson(),
      'dateTime': dateTime.toIso8601String(),
      if (problemReport != null) 'problemReport': problemReport!.toJson(),
    };
  }

  @override
  String toString() {
    return 'CarRepairLogResponseDTO('
        'id: $id, '
        'carInfo: $carInfo, '
        'creatorUser: $creatorUser, '
        'assignedUser: $assignedUser, '    // ← اضافه شده
        'description: $description, '
        'taskStatus: $taskStatus, '
        'dateTime: $dateTime, '
        'problemReport: $problemReport'
        ')';
  }
}
