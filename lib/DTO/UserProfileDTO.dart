import 'RoleDTO.dart';
import 'PermissionDTO.dart';

class UserProfileDTO {
  String userId;
  String username;
  String firstName;
  String lastName;
  RoleDTO role;
  PermissionDTO permission;

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
      userId: json['userId'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: RoleDTO.fromJson(json['role']),
      permission: PermissionDTO.fromJson(json['permission']),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'firstName': firstName,
    'lastName': lastName,
    'role': role.toJson(),
    'permission': permission.toJson(),
  };

}
