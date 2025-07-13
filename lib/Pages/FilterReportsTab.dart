import 'package:autonetwork/DTO/UserProfileDTO.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../backend_services/backend_services.dart';
import 'user_prefs.dart';

import 'Components/CarRepairLogListView.dart';
import 'Components/helpers/app_helpers.dart';

import '../DTO/CarRepairLogResponseDTO.dart';
import '../DTO/TaskStatusDTO.dart';

class FilterReportsTab extends StatefulWidget {
  const FilterReportsTab({super.key});

  @override
  State<FilterReportsTab> createState() => _FilterReportsTabState();
}

class _FilterReportsTabState extends State<FilterReportsTab> {
  String? selectedFilter;
  final TextEditingController _plateController = TextEditingController();
  String? selectedStatus;
  List<CarRepairLogResponseDTO> filteredReports = [];

  final List<String> filterOptions = ['Plaka', 'Görev Durumu'];

  List<TaskStatusDTO> taskStatuses = [];
  UserProfileDTO? user;
  String? permissionName;

  @override
  void initState() {
    super.initState();
    fetchTaskStatuses();
    _loadUser();
  }

  void _loadUser() async {
    user = await UserPrefs.getUserWithID();
    setState(() {
      permissionName = user!.permission.permissionName ?? "";
    });
  }

  Future<void> fetchTaskStatuses() async {
    final response = await TaskStatusApi().getAllStatuses();
    if (response.status == 'success' && response.data != null) {
      setState(() {
        taskStatuses = List<TaskStatusDTO>.from(response.data!);
      });
    } else {
      StringHelper.showErrorDialog(
          context, "Görev durumları alınamadı: ${response.message}");
    }
  }

  void _filter_handler() async {
    FocusScope.of(context).unfocus();
    if (selectedFilter == 'Plaka') {
      if (_plateController.text.trim().isEmpty) {
        StringHelper.showErrorDialog(context, 'Lütfen bir plaka giriniz.');
        return;
      }

      final response = await CarRepairLogApi()
          .getLogsByLicensePlate(_plateController.text.trim().toUpperCase());

      if (response.status == 'success' && response.data!.isNotEmpty) {
        setState(() {
          filteredReports =
          List<CarRepairLogResponseDTO>.from(response.data!);
        });
      } else {
        setState(() {
          filteredReports = [];
        });
        StringHelper.showErrorDialog(context, 'Kayıt bulunamadı.');
      }
    } else if (selectedFilter == 'Görev Durumu') {
      if (selectedStatus == null) {
        StringHelper.showErrorDialog(context, 'Lütfen görev durumunu seçin.');
        return;
      } else {
        final response =
        await CarRepairLogApi().getLatestLogByTaskStatusName(selectedStatus!);
        if (response.status == 'success') {
          setState(() {
            filteredReports =
            List<CarRepairLogResponseDTO>.from(response.data!);
          });
        } else {
          setState(() {
            filteredReports = [];
          });
          StringHelper.showErrorDialog(context, response.message!);
        }
      }
    } else {
      StringHelper.showErrorDialog(context, 'Lütfen filtre türü seçin.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // --- بخش فیلتر داخل اسکرول‌بار ---
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Row برای "Filtre Türü" و Dropdown
                Row(
                  children: [
                    const Text('Filtre Türü:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedFilter,
                        decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                        hint: const Text('Filtre türü seçin'),
                        items: filterOptions
                            .map((filter) => DropdownMenuItem<String>(
                          value: filter,
                          child: Text(filter),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFilter = value;
                            _plateController.clear();
                            selectedStatus = null;
                            filteredReports.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // اگر فیلتر بر اساس پلاک باشه، Row مربوطه
                if (selectedFilter == 'Plaka') ...[
                  Row(
                    children: [
                      const Text('Araç Plakası:', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _plateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Örneğin 12ABC345',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // اگر فیلتر بر اساس وضعیت باشه
                if (selectedFilter == 'Görev Durumu') ...[
                  const SizedBox(height: 8),
                  if (taskStatuses.isEmpty)
                    const Text(
                      'Görev durumları yükleniyor...',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )
                  else
                    Row(
                      children: [
                        const Text('Görev Durumu:', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                            hint: const Text('Durum seçin'),
                            items: taskStatuses
                                .map((status) => DropdownMenuItem<String>(
                              value: status.taskStatusName,
                              child: Text(status.taskStatusName),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value;
                                filteredReports.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                ],

                const SizedBox(height: 24),

                // دکمه اعمال فیلتر
                Center(
                  child: ElevatedButton(
                    onPressed: _filter_handler,
                    child: const Text('Filtreyi Uygula'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- بخش نتایج ---
          Expanded(
            child: filteredReports.isEmpty
                ? const Center(
              child: Text('Kayıt bulunamadı veya filtre uygulanmadı.'),
            )
                : CarRepairLogListView(
              logs: filteredReports,
              buttonBuilder:
              permissionName != null && permissionName == 'Yönetici'
                  ? (log) {
                return {
                  'text': 'Sil',
                  'onPressed': () async {
                    final response = await CarRepairLogApi()
                        .deleteLog(log.id!);
                    if (response.status == 'success') {
                      StringHelper.showInfoDialog(
                          context, response.message!);
                    } else {
                      StringHelper.showErrorDialog(
                          context, response.message!);
                    }
                  },
                };
              }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

}
