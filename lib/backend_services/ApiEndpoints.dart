class ApiEndpoints {
  // static const String _baseUrl = "https://fastapi-java-backend-production.up.railway.app";
  static const String _baseUrl = "https://fastapi-java-backend-jwt-production.up.railway.app";
  //static const String _baseUrl = "http://localhost:8080";

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
  static const String searchCarInfo = "$_baseUrl/cars/searchCarInfo";
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

  static const String customerUrl = "$_baseUrl/customers";
  static const String customerSearchByName = "$_baseUrl/customers/search?name=";

  static const String carRepairLogGetAll = "$_baseUrl/car-repair-log/all";
  static const String carRepairLogGetById = "$_baseUrl/car-repair-log/by-id";
  static const String carRepairLogGetByLicensePlate = "$_baseUrl/car-repair-log/by-license-plate";
  static const String carRepairLogGetByTaskStatusName = "$_baseUrl/car-repair-log/task-status-name";
  static const String carRepairLogLatestGetByLicensePlate = "$_baseUrl/car-repair-log/latest-by-license-plate";
  static const String carRepairLogLatestGetByTaskStatusName = "$_baseUrl/car-repair-log/latest-by-task-status-name";
  static const String carRepairLogLatestGetForEachCar = "$_baseUrl/car-repair-log/log-for-each-car";
  static const String carRepairLogLatestGetForEachCarByCustomerAndTask = "$_baseUrl/car-repair-log/log-for-each-car-customer-task-filter";
  static const String carRepairLogLatestGetByTaskStatusNameAndAssignedToUserId = "$_baseUrl/car-repair-log/latest-by-tasks-status-name-and-userid";
  static const String carRepairLogTaskStatusCount = "$_baseUrl/car-repair-log/task-status-count";
  static const String carRepairLogInvoiceFilterByDate = "$_baseUrl/car-repair-log/invoice-filter-by-date";
  static const String carRepairLogInvoiceFilterByLicensePlate = "$_baseUrl/car-repair-log/invoice-filter-by-licens-plate";
  static const String carRepairLogCreate = "$_baseUrl/car-repair-log/create";
  static const String carRepairLogUpdate = "$_baseUrl/car-repair-log/update";
  static const String carRepairLogDelete = "$_baseUrl/car-repair-log/delete";

  static const String inventoryNextBarcode = "$_baseUrl/inventory/next-barcode";
  static const String inventoryAddItem = "$_baseUrl/inventory/add";
  static const String inventoryGetAllItems = "$_baseUrl/inventory/list";
  static const String inventoryGetItemById = "$_baseUrl/inventory";
  static const String inventorySearchByPartName = "$_baseUrl/inventory/search";
  static const String inventorySearchByBarcode = "$_baseUrl/inventory/barcode";
  static const String inventoryUpdateItem = "$_baseUrl/inventory/update";
  static const String inventoryDeactivateItem = "$_baseUrl/inventory/deactivate";
  static const String inventoryDeleteItem = "$_baseUrl/inventory/delete";
  static const String inventoryIncrementQuantity = "$_baseUrl/inventory/incrementQuantity";
  static const String inventoryDecrementQuantity = "$_baseUrl/inventory/decrementQuantity";
  static const String inventoryGetPagedItems = "$_baseUrl/inventory/inventory-items";

  static const String inventoryTransactionAdd = "$_baseUrl/inventoryTransaction/add";
  static const String inventoryTransactionGetByType = "$_baseUrl/inventoryTransaction/type";
  static const String inventoryTransactionGetByCustomer = "$_baseUrl/inventoryTransaction/customer";
  static const String inventoryTransactionGetLastByCustomer = "$_baseUrl/inventoryTransaction/customer/last";
  static const String inventoryTransactionList = "$_baseUrl/inventoryTransaction/list";
  static const String inventoryTransactionListCount = "$_baseUrl/inventoryTransaction/list/count";
  static const String inventoryTransactionPaged = "$_baseUrl/inventoryTransaction/list/paged";
  static const String inventoryTransactionGetById = "$_baseUrl/inventoryTransaction"; // باید در نهایت /{id} بهش اضافه بشه
  static const String inventoryTransactionDelete = "$_baseUrl/inventoryTransaction/delete"; // در نهایت /{id}
  static const String inventoryTransactionSearchByType = "$_baseUrl/inventoryTransaction/searchByType";
  static const String inventoryTransactionDateRange = "$_baseUrl/inventoryTransaction/date-range";
  static const String inventoryTransactionDateRangeCount = "$_baseUrl/inventoryTransaction/date-range/count";
  static const String inventoryTransactionDateRangePaginated = "$_baseUrl/inventoryTransaction/date-range/paged";

  static const String inventorySaleLogsGet = "$_baseUrl/inventorySaleLogs/get";
  static const String inventorySaleLogsSave = "$_baseUrl/inventorySaleLogs/saveLog";
  static const String inventorySaleLogsDelete = "$_baseUrl/inventorySaleLogs/delete";
  static const String inventorySaleLogsUpdate = "$_baseUrl/inventorySaleLogs/update";
  static const String inventorySaleLogsTotalRemainingAmount = "$_baseUrl/inventorySaleLogs/totalRemainingAmount";
  static const String inventorySaleLogsGetAll = "$_baseUrl/inventorySaleLogs/get-all";
  static const String inventorySaleLogsSearchByCustomer = "$_baseUrl/inventorySaleLogs/searchByCustomer";
  static const String inventorySaleLogsSearchByDate = "$_baseUrl/inventorySaleLogs/searchByDate";
  static const String inventorySaleLogsGetNonZeroRemaining= "$_baseUrl/inventorySaleLogs/get-nonzero-remaining";

  static const String settingGetStatus = "$_baseUrl/settings/status";

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

class PagedApiResponse<T> {
  final String status;
  final List<T>? content;
  final int? pageNumber;
  final int? pageSize;
  final int? totalPages;
  final int? totalElements;
  final String? message;

  PagedApiResponse({
    required this.status,
    this.content,
    this.pageNumber,
    this.pageSize,
    this.totalPages,
    this.totalElements,
    this.message,
  });

  factory PagedApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      )  {
    return PagedApiResponse<T>(
      status: json['status'] ?? 'success',
      content: json['content'] != null
          ? (json['content'] as List).map((e) => fromJsonT(e)).toList()
          : [],
      pageNumber: json['pageable']?['pageNumber'],
      pageSize: json['pageable']?['pageSize'],
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      message: json['message'],
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
