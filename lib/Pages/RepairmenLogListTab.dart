import 'package:flutter/material.dart';
import '../backend_services/backend_services.dart';
import '../DTO/UserProfileDTO.dart';
import '../utils/string_helper.dart';
import 'RepairmanLogTask.dart';
import 'RepairmanWorkespace.dart';

class RepairmenLogListTab extends StatefulWidget {
  final String? plate; // پلاک دریافتی از بیرون
  final void Function(bool confirmed)? onConfirmed; // کال‌بک تأیید

  const RepairmenLogListTab({
    super.key,
    this.plate,
    this.onConfirmed,
  });

  @override
  State<RepairmenLogListTab> createState() => _RepairmenLogListTabState();
}

class _RepairmenLogListTabState extends State<RepairmenLogListTab> {
  List<UserProfileDTO> repairmen = [];
  UserProfileDTO? selectedRepairman;
  String? selectedTaskType;

  final List<String> taskOptions = [
    'Yapılacak işler', // کارهایی که باید انجام شود
    'Devam eden işler', // کارهای در حال انجام
  ];

  @override
  void initState() {
    super.initState();
    _loadRepairmen();
  }

  Future<void> _loadRepairmen() async {
    final response = await UserApi().getAllUsers();
    List<UserProfileDTO>? users;
    if (response.status == 'success') {
      users = response.data;
    } else {
      StringHelper.showErrorDialog(context, response.message!);
      return;
    }

    // فقط اونایی که نقش "Tamirci" دارن رو فیلتر کن
    List<UserProfileDTO> filtered = users
        ?.where((user) => user.permission?.permissionName == 'Tamirci')
        .toList() ??
        [];

    if (!mounted) return;
    setState(() {
      repairmen = filtered;
      selectedRepairman = filtered.isNotEmpty ? filtered.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(

      child: repairmen.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SizedBox( // اینجا ارتفاع محدود شد
        height: 600, // یا هر ارتفاع معقول برای محیط تو
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              "Tamirci Seçin:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserProfileDTO>(
              value: repairmen.contains(selectedRepairman)
                  ? selectedRepairman
                  : null,
              decoration: InputDecoration(
                labelText: 'Tamircilar',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: repairmen
                  .map((user) => DropdownMenuItem<UserProfileDTO>(
                value: user,
                child: Text('${user.firstName} ${user.lastName}'),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRepairman = value;
                  selectedTaskType = null;
                });
              },
            ),
            if (selectedRepairman != null) ...[
              const SizedBox(height: 24),
              const Text(
                "Görev Türünü Seçin:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedTaskType,
                decoration: InputDecoration(
                  labelText: 'Görevler',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: taskOptions
                    .map((task) => DropdownMenuItem<String>(
                  value: task,
                  child: Text(task),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTaskType = value;
                  });
                },
              ),
            ],
            if (selectedRepairman != null && selectedTaskType != null)
              Expanded(
                child: selectedTaskType == 'Yapılacak işler'
                    ? RepairmanLogTask(user: selectedRepairman!)
                    : RepairmanWorkespace(user: selectedRepairman!),
              ),
          ],
        ),
      ),
    );
  }


}
