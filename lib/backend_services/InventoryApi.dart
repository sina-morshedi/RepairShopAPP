part of 'backend_services.dart';

  class InventoryApi {
  // گرفتن لیست کل قطعات
  Future<ApiResponse<List<InventoryItemDTO>>> getAllItems() async {
    final String backendUrl = ApiEndpoints.inventoryGetAllItems;

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<InventoryItemDTO> items =
        dataList.map((e) => InventoryItemDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: items,
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

  Future<ApiResponse<String>> getNextBarcode(String prefix) async {
    final String backendUrl = '${ApiEndpoints.inventoryNextBarcode}?prefix=$prefix';

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final String barcode = response.body;

        return ApiResponse(
          status: 'success',
          data: barcode,
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

  // گرفتن یک قطعه بر اساس id
  Future<ApiResponse<InventoryItemDTO>> getItemById(String id) async {
    final String backendUrl = '${ApiEndpoints.inventoryGetItemById}/$id';

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final InventoryItemDTO item = InventoryItemDTO.fromJson(data);

        return ApiResponse(
          status: 'success',
          data: item,
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

  // جستجو بر اساس بخش یا تمام نام قطعه
  Future<ApiResponse<List<InventoryItemDTO>>> getByPartName(String keyword) async {
    final String backendUrl = '${ApiEndpoints.inventorySearchByPartName}?keyword=$keyword';

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<InventoryItemDTO> items =
        dataList.map((e) => InventoryItemDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: items,
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

  Future<ApiResponse<InventoryItemDTO>> getItemByBarcode(String barcode) async {
    final String backendUrl = '${ApiEndpoints.inventorySearchByBarcode}?barcode=$barcode';

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final InventoryItemDTO item = InventoryItemDTO.fromJson(data);

        return ApiResponse(
          status: 'success',
          data: item,
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

  // اضافه کردن قطعه جدید
  Future<ApiResponse<InventoryItemDTO>> addItem(InventoryItemDTO dto) async {
    final String backendUrl = ApiEndpoints.inventoryAddItem;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final InventoryItemDTO item = InventoryItemDTO.fromJson(data);
        return ApiResponse(
          status: 'success',
          data: item,
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

  // آپدیت قطعه بر اساس id
  Future<ApiResponse<InventoryItemDTO>> updateItem(String id, InventoryItemDTO dto) async {
    final String backendUrl = '${ApiEndpoints.inventoryUpdateItem}/$id';

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

  // حذف منطقی (غیرفعال سازی)
  Future<ApiResponse<String>> deactivateItem(String id) async {
    final String backendUrl = '${ApiEndpoints.inventoryDeactivateItem}/$id';

    try {
      final response = await http.delete(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return ApiResponse(
          status: 'success',
          message: 'Parça başarıyla devre dışı bırakıldı.',
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

  // حذف کامل قطعه
  Future<ApiResponse<String>> deleteItem(String id) async {
    final String backendUrl = '${ApiEndpoints.inventoryDeleteItem}/$id';

    try {
      final response = await http.delete(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          status: 'success',
          message: 'Parça başarıyla silindi.',
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

  // کاهش تعداد موجودی (decrement)
  Future<ApiResponse<String>> decrementQuantity(InventoryChangeRequestDTO dto) async {
    final String backendUrl = ApiEndpoints.inventoryDecrementQuantity;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode == 200) {
        return ApiResponse(status: 'success', message: response.body);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'Exception occurred: $e');
    }
  }

  // افزایش تعداد موجودی (increment)
  Future<ApiResponse<String>> incrementQuantity(InventoryChangeRequestDTO dto) async {
    final String backendUrl = ApiEndpoints.inventoryIncrementQuantity;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode == 200) {
        return ApiResponse(status: 'success', message: response.body);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'Exception occurred: $e');
    }
  }

  Future<ApiResponse<PagedApiResponse<InventoryItemDTO>>> getPagedItems(int page, int size) async {
    final String backendUrl = '${ApiEndpoints.inventoryGetPagedItems}?page=$page&size=$size';

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final pagedResponse = PagedApiResponse<InventoryItemDTO>.fromJson(
          data,
              (item) => InventoryItemDTO.fromJson(item),
        );

        return ApiResponse(
          status: 'success',
          data: pagedResponse,
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
