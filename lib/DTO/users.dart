import 'permissions.dart';
import 'roles.dart';

class users {
  final String username;
  final String firstName;
  final String lastName;
  final roles role;
  final permissions permission;

  const users({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.permission,
  });

  factory users.fromJson(Map<String, dynamic> json) {
    return users(
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: roles.fromJson(json['role'] ?? {}),
      permission: permissions.fromJson(json['permission'] ?? {}),
    );
  }
}
