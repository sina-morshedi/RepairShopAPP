part of 'backend_services.dart';

class CarInfoApi {

  Future<ApiResponse<CarInfoDTO>> getCarInfoByLicensePlate(String licensePlate) async {
    final uri = Uri.parse('${ApiEndpoints.getCarInfo}/$licensePlate');

    try {
      final response = await http.get(
        uri,
        headers: BackendUtils.buildHeader(),
      );

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<CarInfoDTO>(
          status: jsonData['status'] ?? 'success',
          data: CarInfoDTO.fromJson(jsonData),
          message: jsonData['idOrMessage'] ?? '',
        );
      } else {
        return ApiResponse(
          status: jsonData['status'] ?? 'error',
          message: jsonData['idOrMessage'] ?? 'Bilinmeyen hata',
        );
      }
    } catch (e) {
      return ApiResponse(status: "error", message: "Sunucuya erişilemedi: $e");
    }
  }

  Future<ApiResponse<List<CarInfoDTO>>> searchCarsByLicensePlateKeyword(String keyword) async {
    final uri = Uri.parse('${ApiEndpoints.searchCarInfo}?keyword=$keyword');

    try {
      final response = await http.get(
        uri,
        headers: BackendUtils.buildHeader(),
      );

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // فرض بر این است که پاسخ، لیستی از ماشین‌هاست
        final List<CarInfoDTO> carList = (jsonData as List)
            .map((item) => CarInfoDTO.fromJson(item))
            .toList();

        return ApiResponse<List<CarInfoDTO>>(
          status: "success",
          data: carList,
          message: "",
        );
      } else {
        return ApiResponse<List<CarInfoDTO>>(
          status: "error",
          message: response.body,
        );
      }
    } catch (e) {
      return ApiResponse<List<CarInfoDTO>>(
        status: "error",
        message: "Sunucuya erişilemedi: $e",
      );
    }
  }


  Future<ApiResponse<void>> updateCarInfoByLicensePlate(String licensePlate, CarInfo updatedCar) async {
    final response = await http.put(
      Uri.parse('${ApiEndpoints.updateCarInfo}/$licensePlate'),
      headers: BackendUtils.buildHeader(),
      body: jsonEncode(updatedCar.toJson()),
    );

    try {
      final jsonData = jsonDecode(response.body);

      return ApiResponse<void>(
        status: jsonData['status'] ?? (response.statusCode == 200 ? 'success' : 'error'),
        message: jsonData['idOrMessage'] ?? '',
      );
    } catch (e) {
      return ApiResponse<void>(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }

  Future<ApiResponse> insertCarInfo(CarInfo carInfo) async {
    final String url = ApiEndpoints.registerCar;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
        body: jsonEncode(carInfo.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.fromJson(data);
      } else {
        try {
          final data = jsonDecode(response.body);
          return ApiResponse(
            status: data['status'] ?? 'error',
            message: data['idOrMessage'] ?? 'Unknown error',
          );
        } catch (_) {
          return ApiResponse(
            status: 'error',
            message: 'Failed with status code ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'Exception occurred: $e');
    }
  }

}
