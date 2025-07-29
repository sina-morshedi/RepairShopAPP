part of 'backend_services.dart';

class SettingStatusApi {
  // Get all customers
  Future<ApiResponse<SettingStatusDTO>> getSettingStatus(String storeName) async {
    final String url = "${ApiEndpoints.settingGetStatus}/${Uri.encodeComponent(storeName)}";


    print(url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          status: 'success',
          data: SettingStatusDTO.fromJson(data),
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
