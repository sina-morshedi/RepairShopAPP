part of 'backend_services.dart';

class RoleApi {
  // Get all roles
  Future<ApiResponse<List<RolesDTO>>> getAllRoles() async {
    final String url = ApiEndpoints.getAllRoles;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<RolesDTO> roles =
        dataList.map((e) => RolesDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: roles,
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

  // Insert new role
  Future<ApiResponse<RolesDTO>> insertRole(RolesDTO role) async {
    final String url = "${ApiEndpoints.insertRole}/";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
        body: jsonEncode(role.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          status: 'success',
          data: RolesDTO.fromJson(data),
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

  // Update existing role by id
  Future<ApiResponse<RolesDTO>> updateRole(RolesDTO role) async {
    if (role.id == null) {
      return ApiResponse(
        status: 'error',
        message: 'Missing ID for update',
      );
    }

    final String url = "${ApiEndpoints.updateRole}/${role.id}";

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
        body: jsonEncode(role.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          status: 'success',
          data: RolesDTO.fromJson(data),
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

  // Delete role
  Future<ApiResponse<void>> deleteRole(String id) async {
    final String url = "${ApiEndpoints.deleteRole}/$id";

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
      );

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
