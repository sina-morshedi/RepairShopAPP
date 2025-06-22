class permissions {
  final String id;
  final String permissionName;

  const permissions({
    required this.id,
    required this.permissionName,
  });

  factory permissions.fromJson(Map<String, dynamic> json) {
    return permissions(
      id: json['id'] ?? '',
      permissionName: json['permissionName'] ?? '',
    );
  }

  @override
  String toString() {
    return 'id: $id, permissionName: $permissionName';
  }
}
