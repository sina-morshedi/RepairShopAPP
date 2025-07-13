class FilterRequestDTO {
  List<String>? taskStatusNames;
  DateTime? startDate; // حالا از DateTime استفاده می‌کنیم
  DateTime? endDate;
  String? licensePlate;

  FilterRequestDTO({this.taskStatusNames, this.startDate, this.endDate, this.licensePlate});

  factory FilterRequestDTO.fromJson(Map<String, dynamic> json) {
    return FilterRequestDTO(
      taskStatusNames: json['taskStatusNames'] != null
          ? List<String>.from(json['taskStatusNames'])
          : null,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      licensePlate: json['licensePlate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskStatusNames': taskStatusNames,
      'startDate': startDate?.toUtc().toIso8601String(),
      'endDate': endDate?.toUtc().toIso8601String(),
      'licensePlate': licensePlate,
    };
  }

  @override
  String toString() {
    return 'FilterRequestDTO(taskStatusNames: $taskStatusNames, startDate: $startDate, endDate: $endDate, licensePlate: $licensePlate)';
  }
}
