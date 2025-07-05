class ApiEndpoints {
  static const String _baseUrl = "https://fastapi-java-backend-production.up.railway.app";

  static const String login = "$_baseUrl/users/login";
  static const String register = "$_baseUrl/register";
  static const String getProfile = "$_baseUrl/user/profile";
  static const String getAllProfile = "$_baseUrl/users/all";
  static const String countAllMembers = "$_baseUrl/users/count";
  static const String userUpdate = "$_baseUrl/users/update";
  static const String userDelete = "$_baseUrl/users/delete";

  static const String getAllRoles = "$_baseUrl/roles/all";
  static const String insertRole = "$_baseUrl/roles";
  static const String updateRole = "$_baseUrl/roles/updateRole";
  static const String deleteRole = "$_baseUrl/roles/deleteRole";

  static const String getAllPermissions = "$_baseUrl/permissions/all";
  static const String registerUser = "$_baseUrl/auth/register";
  static const String registerCar = "$_baseUrl/cars/insertCarInfo";
  static const String getCarInfo = "$_baseUrl/cars/getCarInfo";
  static const String updateCarInfo = "$_baseUrl/cars/updateCarInfo";
  static const String insertTaskStatus = "$_baseUrl/task_status";
  static const String getTaskStatusByName = "$_baseUrl/task_status/getByStatusName";
  static const String getAllTaskStatus = "$_baseUrl/task_status/all";
  static const String updateTaskStatus = "$_baseUrl/task_status/updateTaskStatus";
  static const String deleteTaskStatus = "$_baseUrl/task_status/deleteTaskStatus";

  static const String createCarProblemReport = "$_baseUrl/car-problem-report/create";
  static const String createCarProblemAll = "$_baseUrl/car-problem-report/all";
  static const String createCarProblemID = "$_baseUrl/car-problem-report";
  static const String createCarProblemByCarID = "$_baseUrl/car-problem-report/by-car";
  static const String createCarProblemByLicensePlate = "$_baseUrl/car-problem-report/by-license-plate";
  static const String createCarProblemByUser = "$_baseUrl/car-problem-report/by-user";
  static const String createCarProblemUpdate = "$_baseUrl/car-problem-report/update";
  static const String createCarProblemDelete = "$_baseUrl/car-problem-report/delete";

  static const String carRepairLogGetAll = "$_baseUrl/car-repair-log/all";
  static const String carRepairLogGetById = "$_baseUrl/car-repair-log/by-id";
  static const String carRepairLogGetByLicensePlate = "$_baseUrl/car-repair-log/by-license-plate";
  static const String carRepairLogGetByTaskStatusName = "$_baseUrl/car-repair-log/task-status-name";
  static const String carRepairLogLatestGetByLicensePlate = "$_baseUrl/car-repair-log/latest-by-license-plate";
  static const String carRepairLogLatestGetByTaskStatusName = "$_baseUrl/car-repair-log/latest-by-task-status-name";
  static const String carRepairLogLatestGetByTaskStatusNameAndAssignedToUserId = "$_baseUrl/car-repair-log/latest-by-tasks-status-name-and-userid";
  static const String carRepairLogLatestGetForEachCar = "$_baseUrl/car-repair-log/log-for-each-car";
  static const String carRepairLogLatestGetForEachCarAssignedToUserId = "$_baseUrl/car-repair-log/latest-assigned";
  static const String carRepairLogCreate = "$_baseUrl/car-repair-log/create";
  static const String carRepairLogUpdate = "$_baseUrl/car-repair-log/update";
  static const String carRepairLogDelete = "$_baseUrl/car-repair-log/delete";
}

class ApiResponse<T> {
  final String status;
  final T? data;
  final String? message;

  ApiResponse({
    required this.status,
    this.data,
    this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, [T Function(Object?)? fromJsonT]) {
    return ApiResponse<T>(
      status: json['status'] ?? 'error',
      data: fromJsonT != null && json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['idOrMessage'] ?? '',
    );
  }
}



class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
