class TaskStatusCountDTO {
  final String taskStatusId;
  final String taskStatusName;
  final int count;

  TaskStatusCountDTO({
    required this.taskStatusId,
    required this.taskStatusName,
    required this.count,
  });

  // ساخت از JSON (دریافت از سرور)
  factory TaskStatusCountDTO.fromJson(Map<String, dynamic> json) {
    return TaskStatusCountDTO(
      taskStatusId: json['taskStatusId'] as String,
      taskStatusName: json['taskStatusName'] as String,
      count: json['count'] as int,
    );
  }

  // تبدیل به JSON (ارسال به سرور اگر نیاز بود)
  Map<String, dynamic> toJson() {
    return {
      'taskStatusId': taskStatusId,
      'taskStatusName': taskStatusName,
      'count': count,
    };
  }
}
