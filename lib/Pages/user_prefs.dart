import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../type.dart';
import '../DTO/UserProfileDTO.dart';

class UserPrefs {
  static const String _generalConfig = 'general_Config';
  static const String _userKey = 'user';
  static const String _storeNameKey = 'storeName';
  static const String _tokeKey = 'token';
  static const String _taskStatusKey = 'task_status';
  static const String _loginTimestampKey = 'loginTimestamp';
  static const String _inventoryEnabledKey = 'inventoryEnabled';
  static const String _customerEnabledKey = 'customerEnabled';


  // ذخیره مقدار inventoryEnabled
  static Future<void> saveInventoryEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_inventoryEnabledKey, value);
  }

  // خواندن مقدار inventoryEnabled
  static Future<bool> getInventoryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_inventoryEnabledKey) ?? false;
  }

  // پاک کردن مقدار inventoryEnabled
  static Future<void> clearInventoryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_inventoryEnabledKey);
  }

  // ذخیره مقدار customerEnabled
  static Future<void> saveCustomerEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_customerEnabledKey, value);
  }

  // خواندن مقدار customerEnabled
  static Future<bool> getCustomerEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_customerEnabledKey) ?? false;
  }

  // پاک کردن مقدار customerEnabled
  static Future<void> clearCustomerEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customerEnabledKey);
  }

  static Future<void> saveTaskStatus(List<TaskStatus?> taskList) async {
    final prefs = await SharedPreferences.getInstance();

    final taskJsonList = taskList
        .whereType<TaskStatus>() // filters out nulls
        .map((task) => task.toJsonWithFields([
      TaskStatusField.id,
      TaskStatusField.task_status,
    ]))
        .toList();

    final taskJson = jsonEncode(taskJsonList);

    await prefs.setString(_taskStatusKey, taskJson);
  }
  static Future<List<TaskStatus?>> getTaskStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJson = prefs.getString(_taskStatusKey);

    if (taskJson != null) {
      final List<dynamic> jsonList = jsonDecode(taskJson);

      return jsonList
          .map((json) => TaskStatus.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
  static Future<void> clearTaskStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_taskStatusKey);
  }


  static Future<void> saveUserWithID(UserProfileDTO user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  static Future<UserProfileDTO?> getUserWithID() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final Map<String, dynamic> json = jsonDecode(userJson);
      return UserProfileDTO.fromJson(json);
    }

    return null;
  }
  static Future<void> clearUserWithID() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<void> saveGeneralConfig(GeneralConfig cfg) async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = jsonEncode(
        cfg.toJsonWithFields([
          UserField.MqttConnection
        ])
    );

    await prefs.setString(_generalConfig, userJson);
  }
  static Future<GeneralConfig?> getGeneralConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final cfgJson = prefs.getString(_generalConfig);

    if (cfgJson != null) {
      final Map<String, dynamic> json = jsonDecode(cfgJson);
      return GeneralConfig.fromJson(json);
    }

    return null;
  }
  static Future<void> clearGeneralConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_generalConfig);
  }

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = jsonEncode(
        user.toJsonWithFields([
          UserField.FirstName,
          UserField.LastName,
          UserField.Role,
          UserField.Permission,
        ])
    );

    await prefs.setString(_userKey, userJson);
  }
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      final Map<String, dynamic> json = jsonDecode(userJson);
      return User.fromJson(json);
    }

    return null;
  }
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null;
  }


  static Future<void> saveLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _loginTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
  static Future<DateTime?> getLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_loginTimestampKey);

    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
  static Future<void> clearLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginTimestampKey);
  }

  static Future<void> saveStoreName(String storeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeNameKey, storeName);
  }

  static Future<String?> getStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storeNameKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokeKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokeKey);
  }

}


