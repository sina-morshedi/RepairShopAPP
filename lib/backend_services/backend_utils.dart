import 'package:get_storage/get_storage.dart';

class BackendUtils {
  static final GetStorage _box = GetStorage();

  static Map<String, String> buildHeader() {
    final token = _box.read('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
