import 'CarInfoDTO.dart';
import 'UserProfileDTO.dart';
class CarProblemReportResponseDTO {
  String? id;
  CarInfoDTO? carInfo;
  UserProfileDTO? creatorUser;
  String? problemSummary;
  DateTime? dateTime;

  CarProblemReportResponseDTO({
    this.id,
    this.carInfo,
    this.creatorUser,
    this.problemSummary,
    this.dateTime,
  });

  factory CarProblemReportResponseDTO.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CarProblemReportResponseDTO(
        id: '',
        carInfo: null,
        creatorUser: null,
        problemSummary: '',
        dateTime: DateTime.now(),
      );
    }

    DateTime adjustedDate;
    try {
      final rawDate = json['dateTime'] != null ? DateTime.parse(json['dateTime']) : DateTime.now();
      final cutoffDate = DateTime(2025, 7, 11, 17, 47, 00);
      adjustedDate = rawDate.isBefore(cutoffDate) ? rawDate : rawDate.toLocal();
    } catch (e) {
      adjustedDate = DateTime.now();
    }

    return CarProblemReportResponseDTO(
      id: json['id'] ?? '',
      carInfo: json['carInfo'] is Map<String, dynamic> ? CarInfoDTO.fromJson(json['carInfo']) : null,
      creatorUser: json['creatorUser'] is Map<String, dynamic> ? UserProfileDTO.fromJson(json['creatorUser']) : null,
      problemSummary: json['problemSummary'] ?? '',
      dateTime: adjustedDate,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (carInfo != null) 'carInfo': carInfo!.toJson(),
      if (creatorUser != null) 'creatorUser': creatorUser!.toJson(),
      'problemSummary': problemSummary,
      if (dateTime != null) 'dateTime': dateTime!.toIso8601String(),
    };
  }


  @override
  String toString() {
    return 'CarProblemReportResponseDTO('
        'id: $id, '
        'carInfo: $carInfo, '
        'creatorUser: $creatorUser, '
        'problemSummary: $problemSummary, '
        'dateTime: $dateTime'
        ')';
  }

}
