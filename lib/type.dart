import 'dart:core';
enum UserField {
  UserID,
  FirstName,
  LastName,
  RoleID,
  PermissionID,
  UserPassID,
  Role,
  Permission,
  UserPass,
  MqttConnection,
}

enum TaskStatusField {
  id,
  task_status,
}

class UserPrefsKeys {
  static const String userId = 'UserID';
  static const String FirstName = 'FirstName';
  static const String LastName = 'LastName';
  static const String RoleID = 'RoleID';
  static const String PermissionID = 'PermissionID';
  static const String Role = 'Role';
  static const String Permission = 'Permission';
  static const String isLoggedIn = 'isLoggedIn';
  static const String MqttConnection = 'MqttConnection';
}

class GeneralConfig {
  bool MqttConnection;

  GeneralConfig({required this.MqttConnection});

  factory GeneralConfig.fromJson(Map<String, dynamic> json) {
    return GeneralConfig(MqttConnection: json['MqttConnection']);
  }

  Map<String, dynamic> toJson() => {'MqttConnection': MqttConnection};

  Map<String, dynamic> toJsonWithFields(List<UserField> fields) {
    final Map<String, dynamic> json = {};
    if (fields.contains(UserField.MqttConnection))
      json['MqttConnection'] = MqttConnection;

    return json;
  }
}

// class UserProfileDTO {
//   String userId;
//   String username;
//   String firstName;
//   String lastName;
//   String roleName;
//   String permissionName;
//
//
//   UserProfileDTO({
//     required this.userId,
//     required this.username,
//     required this.firstName,
//     required this.lastName,
//     required this.roleName,
//     required this.permissionName,
//   });
//
//   factory UserProfileDTO.fromJson(Map<String, dynamic> json) {
//     return UserProfileDTO(
//         userId: json['userId'],
//         username: json['username'],
//         firstName: json['firstName'],
//         lastName: json['lastName'],
//         roleName: json['roleName'],
//         permissionName: json['permissionName'],
//     );
//   }
//   Map<String, dynamic> toJson() => {
//     'userId': userId,
//     'username': username,
//     'firstName': firstName,
//     'lastName': lastName,
//     'roleName': roleName,
//     'permissionName': permissionName,
//   };
// }
class Role {
  final String RoleName;

  Role({required this.RoleName});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(RoleName: json['RoleName']);
  }

  Map<String, dynamic> toJson() => {'RoleName': RoleName};
}

class Permission {
  final String PermissionName;

  Permission({required this.PermissionName});

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      PermissionName: json['PermissionName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'PermissionName': PermissionName
  };
}

class Department {
  final String name;

  Department({required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(name: json['name']);
  }

  Map<String, dynamic> toJson() => {'name': name};
}

class DepartmentWithID {
  final int id;
  final String name;

  DepartmentWithID({
    required this.id,
    required this.name
  });

  factory DepartmentWithID.fromJson(Map<String, dynamic> json) {
    return DepartmentWithID(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class TaskStatus {
  final int id;
  final String task_status;

  TaskStatus({required this.id,required this.task_status});

  factory TaskStatus.fromJson(Map<String, dynamic> json) {
    return TaskStatus(id: json['id'],task_status: json['task_status']);
  }

  Map<String, dynamic> toJson() => {'id': id,'task_status': task_status};

  Map<String, dynamic> toJsonWithFields(List<TaskStatusField> fields) {
    final Map<String, dynamic> json = {};

    if (fields.contains(TaskStatusField.id)) json['id'] = id;
    if (fields.contains(TaskStatusField.task_status)) json['task_status'] = task_status;

    return json;
  }
}

class UserPass {
  final String user_name;
  final String password;

  UserPass({required this.user_name, required this.password});

  factory UserPass.fromJson(Map<String, dynamic> json) {
    return UserPass(user_name: json['user_name'], password: json['password']);
  }

  Map<String, dynamic> toJson() => {'user_name': user_name, 'password': password};
}

class carInfo {
  final String chassis_no;
  final String motor_no;
  final String license_plate;
  final String brand;
  final String brand_model;
  final int model_year;
  final String fuel_type;
  final DateTime date_time;

  carInfo({
    required this.chassis_no,
    required this.motor_no,
    required this.license_plate,
    required this.brand,
    required this.brand_model,
    required this.model_year,
    required this.fuel_type,
    required this.date_time
  });

  factory carInfo.fromJson(Map<String, dynamic> json) {
    return carInfo(
        chassis_no: json['chassis_no'],
        motor_no: json['motor_no'],
        license_plate: json['license_plate'],
        brand: json['brand'],
        brand_model: json['brand_model'],
        model_year: json['model_year'],
        fuel_type: json['fuel_type'],
        date_time: DateTime.parse(json['date_time'])
    );
  }
  Map<String, dynamic> toJson() => {
    'chassis_no': chassis_no,
    'motor_no': motor_no,
    'license_plate': license_plate,
    'brand': brand,
    'brand_model': brand_model,
    'model_year': model_year,
    'fuel_type': fuel_type,
    'date_time': date_time.toIso8601String()
  };

  String toPrettyString() {
    return '''
    Chassis No: $chassis_no
    motor_no No: $motor_no
    license_plate No: $license_plate
    brand: $brand
    brand_model: $brand_model
    model_year: $model_year
    fuel_type: $fuel_type
    date_time: ${date_time.toLocal().toString()}
    ''';
  }
}

class carInfoFromDb {
  final int car_id;
  final String chassis_no;
  final String motor_no;
  final String license_plate;
  final String brand;
  final String brand_model;
  final int model_year;
  final String fuel_type;
  final DateTime date_time;

  carInfoFromDb({
    required this.car_id,
    required this.chassis_no,
    required this.motor_no,
    required this.license_plate,
    required this.brand,
    required this.brand_model,
    required this.model_year,
    required this.fuel_type,
    required this.date_time
  });

  factory carInfoFromDb.fromJson(Map<String, dynamic> json) {
    return carInfoFromDb(
        car_id: json['car_id'],
        chassis_no: json['chassis_no'],
        motor_no: json['motor_no'],
        license_plate: json['license_plate'],
        brand: json['brand'],
        brand_model: json['brand_model'],
        model_year: json['model_year'],
        fuel_type: json['fuel_type'],
        date_time: DateTime.parse(json['date_time'])
    );
  }
  Map<String, dynamic> toJson() => {
    'car_id': car_id,
    'chassis_no': chassis_no,
    'motor_no': motor_no,
    'license_plate': license_plate,
    'brand': brand,
    'brand_model': brand_model,
    'model_year': model_year,
    'fuel_type': fuel_type,
    'date_time': date_time.toIso8601String()
  };

  String toPrettyString() {
    return '''
    car_id: $car_id,
    Chassis No: $chassis_no,
    motor_no No: $motor_no,
    license_plate No: $license_plate,
    brand No: $brand,
    brand_model No: $brand_model,
    model_year No: $model_year,
    fuel_type No: $fuel_type,
    date_time No: ${date_time.toLocal().toString()},
    ''';
  }
}

class UserWithID {
  final int UserID;
  final String FirstName;
  final String LastName;

  final Role? role;
  final Permission? permission;
  final UserPass? userPass;

  UserWithID({
    required this.UserID,
    required this.FirstName,
    required this.LastName,
    this.role,
    this.permission,
    this.userPass,
  });

  factory UserWithID.fromJson(Map<String, dynamic> json) => UserWithID(
    UserID: json['UserID'] != null ? int.tryParse(json['UserID'].toString()) ?? 0 : 0,
    FirstName: json['FirstName'] ?? '',
    LastName: json['LastName'] ?? '',
    role: json['Role'] != null ? Role.fromJson(json['Role']) : null,
    permission: json['Permission'] != null ? Permission.fromJson(json['Permission']) : null,
    userPass: json['UserPass'] != null ? UserPass.fromJson(json['UserPass']) : null,
  );


  Map<String, dynamic> toJson() => {
    'UserID': UserID,
    'FirstName': FirstName,
    'LastName': LastName,
    'Role': role,
    'Permission': permission,
    'UserPass' : userPass
  };

  Map<String, dynamic> toJsonWithFields(List<UserField> fields) {
    final Map<String, dynamic> json = {};
    if (fields.contains(UserField.UserID)) json['UserID'] = UserID;
    if (fields.contains(UserField.FirstName)) json['FirstName'] = FirstName;
    if (fields.contains(UserField.LastName)) json['LastName'] = LastName;
    if (fields.contains(UserField.Role) && role != null) json['Role'] = role!.toJson();
    if (fields.contains(UserField.Permission) && permission != null) json['Permission'] = permission!.toJson();
    if (fields.contains(UserField.UserPass) && userPass != null) json['UserPass'] = userPass!.toJson();

    return json;
  }

}

class User {
  final String FirstName;
  final String LastName;

  final Role? role;
  final Permission? permission;
  final UserPass? userPass;

  User({
    required this.FirstName,
    required this.LastName,
    this.role,
    this.permission,
    this.userPass
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    FirstName: json['FirstName'] ?? '',
    LastName: json['LastName'] ?? '',
    role: json['Role'] != null ? Role.fromJson(json['Role']) : null,
    permission: json['Permission'] != null ? Permission.fromJson(json['Permission']) : null,
    userPass: json['UserPass'] != null ? UserPass.fromJson(json['UserPass']) : null,
  );


  Map<String, dynamic> toJson() => {
    'FirstName': FirstName,
    'LastName': LastName,
  };

  Map<String, dynamic> toJsonWithFields(List<UserField> fields) {
    final Map<String, dynamic> json = {};

    if (fields.contains(UserField.FirstName)) json['FirstName'] = FirstName;
    if (fields.contains(UserField.LastName)) json['LastName'] = LastName;
    if (fields.contains(UserField.Role) && role != null) json['Role'] = role!.toJson();
    if (fields.contains(UserField.Permission) && permission != null) json['Permission'] = permission!.toJson();
    if (fields.contains(UserField.UserPass) && userPass != null) json['UserPass'] = userPass!.toJson();

    return json;
  }

}

class UserDepartment {
  final int id;
  final int user_id;
  final int department_id;
  final User? user;
  final Department? department;

  UserDepartment({required this.id,
    required this.user_id,
    required this.department_id,
    this.user,
    this.department});

  factory UserDepartment.fromJson(Map<String, dynamic> json) =>  UserDepartment(
      id: json['id'],
      user_id: json['user_id'],
      department_id: json['department_id'],
      user: json['User'] != null ? User.fromJson(json['User']) : null,
      department: json['Department'] != null ? Department.fromJson(json['Department']) : null
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': user_id,
    'department_id': department_id
  };
}

class CarRepairLogWithID {
  final int id;
  final int car_id;
  final int creator_user_id;
  final int department_id;
  final int problem_report_id;
  final int car_required_departments_id;
  final String description;
  final int task_status_id;
  final String date_time;

  final carInfo? car_info;
  final User? user;
  final Department? department;
  final TaskStatus? task_status;
  // final ProblemReportFromDb? problem_report;
  // final CarRequiredDepartmentsFromDb? car_required_departments;

  CarRepairLogWithID({
    required this.id,
    required this.car_id,
    required this.creator_user_id,
    required this.department_id,
    required this.problem_report_id,
    required this.car_required_departments_id,
    required this.description,
    required this.task_status_id,
    required this.date_time,
    this.car_info,
    this.user,
    this.department,
    // this.problem_report,
    // this.car_required_departments,
    this.task_status,

  });

  factory CarRepairLogWithID.fromJson(Map<String, dynamic> json) =>  CarRepairLogWithID(
    id: json['id'],
    car_id: json['car_id'],
    creator_user_id: json['creator_user_id'],
    department_id: json['department_id'],
    problem_report_id: json['problem_report_id'],
    car_required_departments_id: json['car_required_departments_id'],
    description: json['description'],
    task_status_id: json['task_status_id'],
    date_time: json['date_time'],
    // car_info: json['carInfo'] != null ? carInfoFromDb.fromJson(json['carInfo']) : null,
    user: json['User'] != null ? User.fromJson(json['User']) : null,
    department: json['Department'] != null ? Department.fromJson(json['Department']) : null,
    // problem_report: json['ProblemReport'] != null ? ProblemReportFromDb.fromJson(json['ProblemReport']) : null,
    // car_required_departments: json['CarRequiredDepartments'] != null ? CarRequiredDepartmentsFromDb.fromJson(json['CarRequiredDepartments']) : null,
    task_status: json['TaskStatus'] != null ? TaskStatus.fromJson(json['TaskStatus']) : null,

  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'car_id': car_id,
    'creator_user_id': creator_user_id,
    'department_id': department_id,
    'problem_report_id': problem_report_id,
    'car_required_departments_id': car_required_departments_id,
    'description': description,
    'task_status_id': task_status_id,
    'date_time': date_time
  };
}

class CarRepairLog {
  final String car_id;
  final String creator_user_id;
  final String? department_id;
  final String? problem_report_id;
  final String? car_required_departments_id;
  final String? description;
  final String task_status_id;
  final String date_time;

  final carInfo? car_info;
  final User? user;
  final Department? department;
  final TaskStatus? task_status;
  // final ProblemReportFromDb? problem_report;
  // final CarRequiredDepartmentsFromDb? car_required_departments;

  CarRepairLog({
    required this.car_id,
    required this.creator_user_id,
    required this.department_id,
    required this.problem_report_id,
    required this.car_required_departments_id,
    required this.description,
    required this.task_status_id,
    required this.date_time,
    this.car_info,
    this.user,
    this.department,
    // this.problem_report,
    // this.car_required_departments,
    this.task_status,

  });

  factory CarRepairLog.fromJson(Map<String, dynamic> json) =>  CarRepairLog(
    car_id: json['car_id'],
    creator_user_id: json['creator_user_id'],
    department_id: json['department_id'],
    problem_report_id: json['problem_report_id'],
    car_required_departments_id: json['car_required_departments_id'],
    description: json['description'],
    task_status_id: json['task_status_id'],
    date_time: json['date_time'],
    // car_info: json['carInfo'] != null ? carInfoFromDb.fromJson(json['carInfo']) : null,
    user: json['User'] != null ? User.fromJson(json['User']) : null,
    department: json['Department'] != null ? Department.fromJson(json['Department']) : null,
    // problem_report: json['ProblemReport'] != null ? ProblemReportFromDb.fromJson(json['ProblemReport']) : null,
    // car_required_departments: json['CarRequiredDepartments'] != null ? CarRequiredDepartmentsFromDb.fromJson(json['CarRequiredDepartments']) : null,
    task_status: json['TaskStatus'] != null ? TaskStatus.fromJson(json['TaskStatus']) : null,

  );

  Map<String, dynamic> toJson() => {
    'car_id': car_id,
    'creator_user_id': creator_user_id,
    'department_id': department_id,
    'description': description,
    'task_status_id': task_status_id,
    'date_time': date_time,
    'problem_report_id': problem_report_id,
    'car_required_departments_id': car_required_departments_id,
  };
}



class ApiResponseDatabase<T> {
  final T? data;
  final databaseError? dbo_error;
  final objApiError? error;
  final objApiSuccess? success;

  ApiResponseDatabase({this.data,this.success, this.dbo_error, this.error});

  bool get hasError => error != null || dbo_error != null;
}

class databaseError {
  final String error_code;
  final String message;

  databaseError({required this.error_code, required this.message});

  factory databaseError.fromJson(Map<String, dynamic> json) {
    return databaseError(
      error_code: json['error_code'],
      message: json['message'],
    );
  }
  Map<String, dynamic> toJson() => {
    'error_code': error_code,
    'message': message,
  };
}

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  UserSession._internal();

  User? currentUser;
}

class objApiError {
  final String message;
  final int statusCode;

  objApiError({
    required this.message,
    required this.statusCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'statusCode': statusCode,
    };
  }
}

class objApiSuccess {
  final String message;
  final int statusCode;

  objApiSuccess({
    required this.message,
    required this.statusCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'statusCode': statusCode,
    };
  }
}
