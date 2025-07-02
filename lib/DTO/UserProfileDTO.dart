import 'roles.dart';
import 'permissions.dart';

class UserProfileDTO {
  final String userId;
  final String username;
  final String firstName;
  final String lastName;
  final roles role;
  final permissions permission;

  UserProfileDTO({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.permission,
  });

  factory UserProfileDTO.fromJson(Map<String, dynamic> json) {
    return UserProfileDTO(
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      role: json['role'] != null ? roles.fromJson(json['role']) : roles(id: 'unkown', roleName: 'unkown'),  // roles() با مقادیر پیش‌فرض باید داشته باشی
      permission: json['permission'] != null ? permissions.fromJson(json['permission']) : permissions(id: 'unkown',permissionName: 'unkown'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toJson(),
      'permission': permission.toJson(),
    };
  }
  @override
  String toString() {
    return 'UserProfile(userId: $userId,'
        'username: $username, '
        'firstName: $firstName, '
        'lastName: $lastName, '
        'role: ${role.toString()}, '
        'permission: ${permission.toString()})';
  }

}
