part of 'backend_services.dart';

class CustomerApi {
  // Get all customers
  Future<ApiResponse<List<CustomerDTO>>> getAllCustomers() async {
    final String url = "${ApiEndpoints.customerUrl}/";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<CustomerDTO> customers =
        dataList.map((e) => CustomerDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: customers,
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

  // Search customers by name
  Future<ApiResponse<List<CustomerDTO>>> searchCustomerByName(String name) async {
    final String url = "${ApiEndpoints.customerSearchByName}$name";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<CustomerDTO> customers =
        dataList.map((e) => CustomerDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: customers,
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

  // Insert new customer
  Future<ApiResponse<CustomerDTO>> insertCustomer(CustomerDTO customer) async {
    final String url = "${ApiEndpoints.customerUrl}/";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
        body: jsonEncode(customer.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          status: 'success',
          data: CustomerDTO.fromJson(data),
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

  // Update customer
  Future<ApiResponse<CustomerDTO>> updateCustomer(CustomerDTO customer) async {
    if (customer.id == null) {
      return ApiResponse(
        status: 'error',
        message: 'Missing ID for update',
      );
    }

    final String url = "${ApiEndpoints.customerUrl}/${customer.id}";

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
        body: jsonEncode(customer.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          status: 'success',
          data: CustomerDTO.fromJson(data),
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

  // Delete customer
  Future<ApiResponse<void>> deleteCustomer(String id) async {
    final String url = "${ApiEndpoints.customerUrl}/$id";

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        return ApiResponse(status: 'success');
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

  // Get single customer by ID
  Future<ApiResponse<CustomerDTO>> getCustomerById(String id) async {
    final String url = "${ApiEndpoints.customerUrl}/$id";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          status: 'success',
          data: CustomerDTO.fromJson(data),
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
