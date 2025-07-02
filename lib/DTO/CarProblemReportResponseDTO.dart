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

  factory CarProblemReportResponseDTO.fromJson(Map<String, dynamic> json) {
    return CarProblemReportResponseDTO(
      id: json['id'],
      carInfo: json['carInfo'] != null ? CarInfoDTO.fromJson(json['carInfo']) : null,
      creatorUser: json['creatorUser'] != null ? UserProfileDTO.fromJson(json['creatorUser']) : null,
      problemSummary: json['problemSummary'],
      dateTime: json['dateTime'] != null ? DateTime.tryParse(json['dateTime']) : null,
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
