class SettingStatusDTO {
  final bool inventoryEnabled;
  final bool customerEnabled;

  SettingStatusDTO({
    required this.inventoryEnabled,
    required this.customerEnabled,
  });

  factory SettingStatusDTO.fromJson(Map<String, dynamic> json) {
    return SettingStatusDTO(
      inventoryEnabled: json['inventoryEnabled'] as bool,
      customerEnabled: json['customerEnabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryEnabled': inventoryEnabled,
      'customerEnabled': customerEnabled,
    };
  }

  @override
  String toString() {
    return 'SettingStatusDTO(inventoryEnabled: $inventoryEnabled, customerEnabled: $customerEnabled)';
  }
}
