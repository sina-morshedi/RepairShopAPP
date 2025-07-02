class UpdateUserDTO {
  final String userId;
  final String username;
  final String firstName;
  final String lastName;
  final String roleId;
  final String permissionId;
  final String? password; // nullable password
  final bool updatePassword;

  UpdateUserDTO({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.roleId,
    required this.permissionId,
    this.password,
    required this.updatePassword,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'roleId': roleId,
      'permissionId': permissionId,
      'updatePassword': updatePassword,
    };

    // Only include password if updatePassword is true and password is not null
    if (updatePassword && password != null) {
      data['password'] = password;
    }

    return data;
  }

  factory UpdateUserDTO.fromJson(Map<String, dynamic> json) {
    return UpdateUserDTO(
      userId: json['userId'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      roleId: json['roleId'],
      permissionId: json['permissionId'],
      password: json['password'],
      updatePassword: json['updatePassword'],
    );
  }
}
