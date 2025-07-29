part of 'backend_services.dart';

class UserApi {


  Future<ApiResponse<List<UserProfileDTO>>> getAllUsers() async {
    final String backendUrl = ApiEndpoints.getAllProfile;

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<UserProfileDTO> user =
        dataList.map((e) => UserProfileDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: user,
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

  Future<ApiResponse<String>> updateUser(UpdateUserDTO dto) async {
    final String backendUrl = '${ApiEndpoints.userUpdate}/${dto.userId}';

    try {
      final response = await http.put(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          status: 'success',
          message: response.body,
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

  Future<ApiResponse<String>> deleteUser(String userId) async {
    final String backendUrl = '${ApiEndpoints.userDelete}/$userId';

    try {
      final response = await http.delete(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          status: 'success',
          message: response.body,
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
}
