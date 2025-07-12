part of 'backend_services.dart';

class CarRepairLogApi {
  // Fetch all logs: returns a list of ResponseDTO
  Future<ApiResponse<List<CarRepairLogResponseDTO>>> getAllLogs() async {
    final String backendUrl = ApiEndpoints.carRepairLogGetAll;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<CarRepairLogResponseDTO> logs =
        dataList.map((e) => CarRepairLogResponseDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: logs,
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

  // Fetch logs by license plate (assuming the response is a list of ResponseDTO)
  Future<ApiResponse<List<CarRepairLogResponseDTO>>> getLogsByLicensePlate(String plate) async {
    final String backendUrl = '${ApiEndpoints.carRepairLogGetByLicensePlate}/$plate';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<CarRepairLogResponseDTO> logs =
        dataList.map((e) => CarRepairLogResponseDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: logs,
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

  Future<ApiResponse<CarRepairLogResponseDTO>> getLatestLogByLicensePlate(String plate) async {
    final String backendUrl = '${ApiEndpoints.carRepairLogLatestGetByLicensePlate}/$plate';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        final log = CarRepairLogResponseDTO.fromJson(decoded);
        return ApiResponse(
          status: 'success',
          data: log,
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: response.body,
        );
      }
    } catch (e, stack) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }

  }
  Future<ApiResponse<CarRepairLogResponseDTO>> getLogByid(String id) async {
    final String backendUrl = '${ApiEndpoints.carRepairLogGetById}/$id';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        final log = CarRepairLogResponseDTO.fromJson(decoded);
        return ApiResponse(
          status: 'success',
          data: log,
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: response.body,
        );
      }
    } catch (e, stack) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }

  }

  Future<ApiResponse<List<CarRepairLogResponseDTO>>> getLatestLogByTaskStatusName(String taskStatusName) async {
    final encodedStatusName = Uri.encodeComponent(taskStatusName);
    final String backendUrl = '${ApiEndpoints.carRepairLogLatestGetByTaskStatusName}/$encodedStatusName';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> decodedList = jsonDecode(response.body);

        final List<CarRepairLogResponseDTO> logs = decodedList
            .map((jsonItem) => CarRepairLogResponseDTO.fromJson(jsonItem))
            .toList();

        return ApiResponse(
          status: 'success',
          data: logs,
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

  Future<ApiResponse<List<CarRepairLogResponseDTO>>> getLogsByTaskNameAndDateRange(FilterRequestDTO filter) async {
    final String backendUrl = ApiEndpoints.carRepairLogInvoiceFilterByDate;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(filter.toJson()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<CarRepairLogResponseDTO> logs =
        dataList.map((e) => CarRepairLogResponseDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: logs,
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

  Future<ApiResponse<List<CarRepairLogResponseDTO>>> getLogsByTaskNameAndLicensePlate(FilterRequestDTO filter) async {
    final String backendUrl = ApiEndpoints.carRepairLogInvoiceFilterByLicensePlate;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(filter.toJson()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<CarRepairLogResponseDTO> logs =
        dataList.map((e) => CarRepairLogResponseDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: logs,
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

  Future<ApiResponse<List<CarRepairLogResponseDTO>>> getLatestLogsByTaskStatusesAndUserId(
      TaskStatusUserRequestDTO request) async {
    final String backendUrl = ApiEndpoints.carRepairLogLatestGetByTaskStatusNameAndAssignedToUserId;

    final requestBody = request.toJson();

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> decodedList = jsonDecode(response.body);

        final List<CarRepairLogResponseDTO> logs = decodedList
            .map((jsonItem) => CarRepairLogResponseDTO.fromJson(jsonItem))
            .toList();

        return ApiResponse(
          status: 'success',
          data: logs,
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

  // Create a new log: sends RequestDTO, receives ResponseDTO
  Future<ApiResponse<CarRepairLogResponseDTO>> createLog(CarRepairLogRequestDTO request) async {
    final String backendUrl = ApiEndpoints.carRepairLogCreate;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final createdLog = CarRepairLogResponseDTO.fromJson(data);
        return ApiResponse(
          status: 'success',
          data: createdLog,
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

  // Update a log: sends RequestDTO, receives ResponseDTO
  Future<ApiResponse<CarRepairLogResponseDTO>> updateLog(String id, CarRepairLogRequestDTO request) async {
    final String backendUrl = '${ApiEndpoints.carRepairLogUpdate}/$id';

    try {
      final response = await http.put(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          status: 'success',
          message: response.body,
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

  // Delete a log by ID
  Future<ApiResponse<String>> deleteLog(String id) async {
    final String backendUrl = '${ApiEndpoints.carRepairLogDelete}/$id';

    try {
      final response = await http.delete(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          status: 'success',
          message: response.body,
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

  Future<ApiResponse<List<CarRepairLogResponseDTO>>> getLatestLogForEachCar() async {

    final String backendUrl = '${ApiEndpoints.carRepairLogLatestGetForEachCar}';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> decodedList = jsonDecode(response.body);

        final List<CarRepairLogResponseDTO> logs = decodedList
            .map((jsonItem) => CarRepairLogResponseDTO.fromJson(jsonItem))
            .toList();

        return ApiResponse(
          status: 'success',
          data: logs,
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
  Future<ApiResponse<List<CarRepairLogResponseDTO>>> getLatestLogForEachCarAssignedToUserId(String userId) async {

    final String backendUrl = '${ApiEndpoints.carRepairLogLatestGetForEachCarAssignedToUserId}/$userId';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> decodedList = jsonDecode(response.body);

        final List<CarRepairLogResponseDTO> logs = decodedList
            .map((jsonItem) => CarRepairLogResponseDTO.fromJson(jsonItem))
            .toList();

        return ApiResponse(
          status: 'success',
          data: logs,
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
}
