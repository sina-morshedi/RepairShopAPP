import 'package:flutter/material.dart';
// import 'StatusSvgProvider.dart';

import '../backend_services/backend_services.dart';
import 'user_prefs.dart';

import 'Components/CarRepairLogListView.dart';
import 'Components/helpers/app_helpers.dart';

import '../DTO/CarRepairLogResponseDTO.dart';
import '../DTO/TaskStatusDTO.dart';
import '../DTO/UserProfileDTO.dart';

class FinalReportForEachCarTab extends StatefulWidget {
  const FinalReportForEachCarTab({super.key});

  @override
  State<FinalReportForEachCarTab> createState() => _FinalReportForEachCarTabState();
}

class _FinalReportForEachCarTabState extends State<FinalReportForEachCarTab> with RouteAware {
  String? selectedFilter;
  final TextEditingController _plateController = TextEditingController();
  String? selectedStatus;
  List<CarRepairLogResponseDTO> _logs = [];

  final List<String> filterOptions = ['Plaka', 'Görev Durumu'];

  List<TaskStatusDTO> taskStatuses = [];
  List<CarRepairLogResponseDTO> filteredReports = [];
  String? permissionName;

  @override
  void initState() {
    super.initState();
    fetchLastLogForEachCar();
    loadUserProfile();
  }
  void loadUserProfile() async{
    final currentUser = await UserPrefs.getUserWithID();
    permissionName  = currentUser!.permission.permissionName ?? "";
  }

  Future<void> fetchLastLogForEachCar() async {
    final response = await CarRepairLogApi().getLatestLogForEachCar();

    if (response.status == 'success' && response.data != null) {

      setState(() {
        filteredReports = List<CarRepairLogResponseDTO>.from(response.data!);
      });
    } else {
      StringHelper.showErrorDialog(
          context, "Görev durumları alınamadı: ${response.message}");
    }
  }

  void ShowDetailsDialog(CarRepairLogResponseDTO log)async{
    StringHelper.ShowDetailsLogDialog(context, log);

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CarRepairLogListView(
        logs: filteredReports,
        buttonBuilder: permissionName != null && permissionName == 'Yönetici'
            ? (log) {
          return {
            'text': 'Sil',
            'onPressed': () async {
              final response = await CarRepairLogApi().deleteLog(log.id!);
              if (response.status == 'success') {
                StringHelper.showInfoDialog(context, response.message!);
              } else {
                StringHelper.showErrorDialog(context, response.message!);
              }
            },
          };
        }
            : null, // if user is not 'Yönetici', don't show the button
      ),
    );
  }


}
