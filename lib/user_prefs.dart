import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'type.dart'; // import the User class from its file

class UserPrefs {
  static const String _generalConfig = 'general_Config';
  static const String _userKey = 'user';
  static const String _taskStatusKey = 'task_status';
  static const String _loginTimestampKey = 'loginTimestamp';

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


  static Future<void> saveUserWithID(UserWithID user) async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = jsonEncode(
        user.toJsonWithFields([
          UserField.UserID,
          UserField.FirstName,
          UserField.LastName,
          UserField.Role,
          UserField.Permission,
        ])
    );
    print('userJson Save: ${user.toJson()}');
    await prefs.setString(_userKey, userJson);
  }
  static Future<UserWithID?> getUserWithID() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    print('userJson Get: $userJson');
    if (userJson != null) {
      final Map<String, dynamic> json = jsonDecode(userJson);
      return UserWithID.fromJson(json);
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

}


