import 'CarInfoDTO.dart';
import 'CarProblemReportResponseDTO.dart';
import 'UserProfileDTO.dart';
import 'TaskStatusDTO.dart';
import 'PartUsed.dart';
import 'PaymentRecord.dart';
import 'CustomerDTO.dart'; // ← اضافه شده

class CarRepairLogResponseDTO {
  final String? id;
  final CarInfoDTO carInfo;
  final UserProfileDTO creatorUser;
  final UserProfileDTO? assignedUser;
  final String? description;
  final TaskStatusDTO taskStatus;
  final DateTime dateTime;
  final CarProblemReportResponseDTO? problemReport;
  final List<PartUsed>? partsUsed;
  final List<PaymentRecord>? paymentRecords;

  final CustomerDTO? customer;  // ← اضافه شده

  CarRepairLogResponseDTO({
    this.id,
    required this.carInfo,
    required this.creatorUser,
    this.assignedUser,
    this.description,
    required this.taskStatus,
    required this.dateTime,
    this.problemReport,
    this.partsUsed,
    this.paymentRecords,
    this.customer,  // ← اضافه شده
  });

  factory CarRepairLogResponseDTO.fromJson(Map<String, dynamic> json) {
    DateTime adjustedDate;
    try {
      final rawDate = json['dateTime'] != null ? DateTime.parse(json['dateTime']) : DateTime.now();
      final cutoffDate = DateTime(2025, 7, 11, 17, 47, 00);
      adjustedDate = rawDate.isBefore(cutoffDate) ? rawDate : rawDate.toLocal();
    } catch (e) {
      adjustedDate = DateTime.now();
    }

    return CarRepairLogResponseDTO(
      id: json['_id'] ?? json['id'] ?? '',
      carInfo: CarInfoDTO.fromJson(json['carInfo']),
      creatorUser: UserProfileDTO.fromJson(json['creatorUser']),
      assignedUser: (json['assignedUser'] != null && json['assignedUser'] is Map<String, dynamic>)
          ? UserProfileDTO.fromJson(json['assignedUser'])
          : null,
      description: json['description'],
      taskStatus: TaskStatusDTO.fromJson(json['taskStatus']),
      dateTime: adjustedDate,
      problemReport: (json['problemReport'] != null && json['problemReport'] is Map<String, dynamic>)
          ? CarProblemReportResponseDTO.fromJson(json['problemReport'])
          : null,
      partsUsed: (json['partsUsed'] != null && json['partsUsed'] is List)
          ? (json['partsUsed'] as List).map((item) => PartUsed.fromJson(item)).toList()
          : null,
      paymentRecords: (json['paymentRecords'] != null && json['paymentRecords'] is List)
          ? (json['paymentRecords'] as List).map((item) => PaymentRecord.fromJson(item)).toList()
          : null,
      customer: (json['customer'] != null && json['customer'] is Map<String, dynamic>)
          ? CustomerDTO.fromJson(json['customer'])
          : null,  // ← اضافه شده
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
      if (paymentRecords != null)
        'paymentRecords': paymentRecords!.map((e) => e.toJson()).toList(),
      if (customer != null) 'customer': customer!.toJson(),  // ← اضافه شده
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
        'partsUsed: $partsUsed, '
        'paymentRecords: $paymentRecords, '
        'customer: $customer'  // ← اضافه شده
        ')';
  }
}
