part of 'backend_services.dart';

class TaskStatusApi {
  // Get all task statuses
  Future<ApiResponse<List<TaskStatusDTO>>> getAllStatuses() async {
    final String url = ApiEndpoints.getAllTaskStatus;

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<TaskStatusDTO> statuses =
        dataList.map((e) => TaskStatusDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: statuses,
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: '${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }

  Future<ApiResponse<TaskStatusDTO>> getTaskStatusByName(String taskStatusName) async {
    final uri = Uri.parse(ApiEndpoints.getTaskStatusByName);

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'taskName': taskStatusName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          status: 'success',
          data: TaskStatusDTO.fromJson(data),
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: response.body,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }

  // Insert new task status
  Future<ApiResponse<TaskStatusDTO>> insertStatus(TaskStatusDTO status) async {
    final String url = "${ApiEndpoints.insertTaskStatus}/";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(status.toJson()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          status: 'success',
          data: TaskStatusDTO.fromJson(data),
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: '${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }

  // Update existing task status by id
  Future<ApiResponse<TaskStatusDTO>> updateStatus(TaskStatusDTO status) async {
    if (status.id == null) {
      return ApiResponse(
        status: 'error',
        message: 'Missing ID for update',
      );
    }

    final String url = "${ApiEndpoints.updateTaskStatus}/${status.id}";
    print(url);
    print(status.toJson());
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(status.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          status: 'success',
          data: TaskStatusDTO.fromJson(data),
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }
  Future<ApiResponse<void>> deleteStatus(String id) async {
    final String url = "${ApiEndpoints.deleteTaskStatus}/$id"; // یا آدرس صحیح

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        return ApiResponse(
          status: 'success',
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }
}