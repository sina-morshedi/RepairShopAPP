class PermissionDTO {
  String permissionId;
  String permissionName;

  PermissionDTO({required this.permissionId, required this.permissionName});

  factory PermissionDTO.fromJson(Map<String, dynamic> json) {
    return PermissionDTO(
      permissionId: json['permissionId'],
      permissionName: json['permissionName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'permissionId': permissionId,
    'permissionName': permissionName,
  };
}