class FilterRequestDTO {
  List<String>? taskStatusNames;
  String? startDate; // فرمت yyyy-MM-dd
  String? endDate;
  String? licensePlate;

  FilterRequestDTO({this.taskStatusNames, this.startDate, this.endDate, this.licensePlate});

  // تبدیل از JSON به مدل
  factory FilterRequestDTO.fromJson(Map<String, dynamic> json) {
    return FilterRequestDTO(
      taskStatusNames: json['taskStatusNames'] != null
          ? List<String>.from(json['taskStatusNames'])
          : null,
      startDate: json['startDate'],
      endDate: json['endDate'],
      licensePlate: json['licensePlate'],
    );
  }

  // تبدیل از مدل به JSON
  Map<String, dynamic> toJson() {
    return {
      'taskStatusNames': taskStatusNames,
      'startDate': startDate,
      'endDate': endDate,
      'licensePlate': licensePlate,
    };
  }
}
