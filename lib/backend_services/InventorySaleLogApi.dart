
part of 'backend_services.dart';

class InventorySaleLogApi {
  // گرفتن همه لاگ‌های فروش
  Future<ApiResponse<List<InventorySaleLogDTO>>> getAllSaleLogs() async {
    final String backendUrl = ApiEndpoints.inventorySaleLogsGetAll;

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<InventorySaleLogDTO> logs =
        dataList.map((e) => InventorySaleLogDTO.fromJson(e)).toList();

        return ApiResponse(status: 'success', data: logs);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'İstisna oluştu: $e');
    }
  }

  // گرفتن لاگ فروش بر اساس id
  Future<ApiResponse<InventorySaleLogDTO>> getSaleLogById(String id) async {
    final String backendUrl = '${ApiEndpoints.inventorySaleLogsGet}?id=$id';

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final log = InventorySaleLogDTO.fromJson(data);
        return ApiResponse(status: 'success', data: log);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'İstisna oluştu: $e');
    }
  }

  // ثبت یا به‌روزرسانی لاگ فروش
  Future<ApiResponse<InventorySaleLogDTO>> saveSaleLog(InventorySaleLogDTO dto) async {
    final String backendUrl = ApiEndpoints.inventorySaleLogsSave; // فرض میکنیم همین url برای save استفاده میشه

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final log = InventorySaleLogDTO.fromJson(data);
        return ApiResponse(status: 'success', data: log);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'İstisna oluştu: $e');
    }
  }

  // به‌روزرسانی لاگ فروش بر اساس id
  Future<ApiResponse<InventorySaleLogDTO>> updateSaleLog(String id, InventorySaleLogDTO dto) async {
    final String backendUrl = '${ApiEndpoints.inventorySaleLogsUpdate}/$id'; // فرض می‌کنیم مسیر کنترلر به شکل /update/{id} هست

    try {
      final response = await http.put(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final log = InventorySaleLogDTO.fromJson(data);
        return ApiResponse(status: 'success', data: log);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'İstisna oluştu: $e');
    }
  }


  // حذف لاگ فروش بر اساس id
  Future<ApiResponse<String>> deleteSaleLog(String id) async {
    final String backendUrl = '${ApiEndpoints.inventorySaleLogsDelete}/$id';

    try {
      final response = await http.delete(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse(status: 'success', message: 'Satış kaydı başarıyla silindi.');
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'İstisna oluştu: $e');
    }
  }

  // جستجو بر اساس نام مشتری
  Future<ApiResponse<List<InventorySaleLogDTO>>> searchByCustomerName(String customerName) async {
    final String backendUrl =
        '${ApiEndpoints.inventorySaleLogsSearchByCustomer}?customerName=$customerName';

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final logs =
        dataList.map((e) => InventorySaleLogDTO.fromJson(e)).toList();

        return ApiResponse(status: 'success', data: logs);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'İstisna oluştu: $e');
    }
  }

  // جستجو بر اساس بازه تاریخ
  Future<ApiResponse<List<InventorySaleLogDTO>>> searchByDateRange(
      String startDate, String endDate) async {
    final String backendUrl =
        '${ApiEndpoints.inventorySaleLogsSearchByDate}?startDate=$startDate&endDate=$endDate';

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final logs =
        dataList.map((e) => InventorySaleLogDTO.fromJson(e)).toList();

        return ApiResponse(status: 'success', data: logs);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'İstisna oluştu: $e');
    }
  }

  // گرفتن مجموع RemainingAmount کل لاگ‌ها
  Future<ApiResponse<double>> getTotalRemainingAmount() async {
    final String backendUrl = ApiEndpoints.inventorySaleLogsTotalRemainingAmount;

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // اگر API فقط عدد رو توی فیلد 'data' برمی‌گردونه:
        final double total = (body as num?)?.toDouble() ?? 0.0;

        return ApiResponse(status: 'success', data: total);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'İstisna oluştu: $e');
    }
  }
  // گرفتن لاگ‌های فروش که remainingAmount آنها مخالف صفر است
  Future<ApiResponse<List<InventorySaleLogDTO>>> getSaleLogsWithNonZeroRemaining() async {
    final String backendUrl = ApiEndpoints.inventorySaleLogsGetNonZeroRemaining;

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<InventorySaleLogDTO> logs =
        dataList.map((e) => InventorySaleLogDTO.fromJson(e)).toList();

        return ApiResponse(status: 'success', data: logs);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'İstisna oluştu: $e');
    }
  }



}
