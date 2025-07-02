
class RolesDTO {
  final String? id;
  final String roleName;

  const RolesDTO({
    this.id,
    required this.roleName,
  });

  factory RolesDTO.fromJson(Map<String, dynamic> json) {
    return RolesDTO(
      id: json['id'] ?? '',
      roleName: json['roleName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'roleName': roleName,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
  @override
  String toString() {
    return 'id: $id, roleName: $roleName';
  }
}
