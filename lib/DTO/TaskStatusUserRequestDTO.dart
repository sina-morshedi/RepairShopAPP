class TaskStatusUserRequestDTO {
  List<String> taskStatusNames;
  String assignedUserId;

  TaskStatusUserRequestDTO({
    required this.taskStatusNames,
    required this.assignedUserId,
  });

  factory TaskStatusUserRequestDTO.fromJson(Map<String, dynamic> json) {
    return TaskStatusUserRequestDTO(
      taskStatusNames: List<String>.from(json['taskStatusNames'] ?? []),
      assignedUserId: json['assignedUserId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskStatusNames': taskStatusNames,
      'assignedUserId': assignedUserId,
    };
  }
}
