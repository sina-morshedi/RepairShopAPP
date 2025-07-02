part of 'backend_services.dart';

class CarProblemReportApi {

  Future<ApiResponse<List<CarProblemReportRequestDTO>>> getAllReports() async {
    final String backendUrl = ApiEndpoints.createCarProblemAll;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<CarProblemReportRequestDTO> reports =
        dataList.map((e) => CarProblemReportRequestDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: reports,
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

  Future<ApiResponse<CarProblemReportRequestDTO>> getReportById(String id) async {
    final String backendUrl = '${ApiEndpoints.createCarProblemID}/$id';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final report = CarProblemReportRequestDTO.fromJson(data);

        return ApiResponse(
          status: 'success',
          data: report,
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



  Future<ApiResponse<CarProblemReportRequestDTO>> createReport(CarProblemReportRequestDTO report) async {
    final String backendUrl = ApiEndpoints.createCarProblemReport;;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(report.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final createdReport = CarProblemReportRequestDTO.fromJson(json);

        return ApiResponse(
          status: 'success',
          data: createdReport,
        );
      } else {
        return ApiResponse(
          status: 'error',
          data: null,
          message: response.body,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        data: null,
        message: 'Exception occurred: $e',
      );
    }
  }



  Future<ApiResponse<String>> updateReport(CarProblemReportRequestDTO report) async {
    final String backendUrl = '${ApiEndpoints.createCarProblemUpdate}/${report.id}';

    try {
      final response = await http.put(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(report.toJson()),
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


  Future<ApiResponse<String>> deleteReport(String id) async {
    final String backendUrl = '${ApiEndpoints.createCarProblemDelete}/$id';

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
}
