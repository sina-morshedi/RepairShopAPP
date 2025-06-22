class RoleDTO {
  String roleId;
  String roleName;

  RoleDTO({required this.roleId, required this.roleName});

  factory RoleDTO.fromJson(Map<String, dynamic> json) {
    return RoleDTO(
      roleId: json['roleId'],
      roleName: json['roleName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'roleId': roleId,
    'roleName': roleName,
  };
}