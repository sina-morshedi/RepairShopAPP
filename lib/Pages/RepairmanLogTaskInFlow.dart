import 'package:flutter/material.dart';
import '../backend_services/backend_services.dart';
import '../DTO/CarRepairLogResponseDTO.dart';
import '../DTO/TaskStatusUserRequestDTO.dart';
import '../DTO/CarRepairLogRequestDTO.dart';
import '../DTO/CarRepairLogResponseDTO.dart';
import '../DTO/UserProfileDTO.dart';
import 'Components/helpers/app_helpers.dart';
import 'CarRepairLogListView.dart';
import 'user_prefs.dart';

class RepairmanLogTaskInFlow extends StatefulWidget {
  final UserProfileDTO user;
  final String? plate;
  final VoidCallback? onConfirmed;

  const RepairmanLogTaskInFlow({
    Key? key,
    required this.user,
    this.plate,
    this.onConfirmed,
  }) : super(key: key);

  @override
  State<RepairmanLogTaskInFlow> createState() => _RepairmanLogTaskInFlowState();
}

class _RepairmanLogTaskInFlowState extends State<RepairmanLogTaskInFlow> {
  late UserProfileDTO user;
  List<CarRepairLogResponseDTO> logs = [];

  String firstName = '';
  String lastName = '';
  String roleName = '';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _loadUserAndLogs();
  }

  Future<void> _loadUserAndLogs() async {
    setState(() {
      _isLoading = true;
    });

    if (user.role != null && user.permission != null) {
      firstName = user.firstName;
      lastName = user.lastName;
      roleName = user.role!.roleName;
    }

    final request = TaskStatusUserRequestDTO(
      assignedUserId: user.userId,
      taskStatusNames: ["USTA"],
    );

    final response =
    await CarRepairLogApi().getLatestLogsByTaskStatusesAndUserId(request);

    if (response.status == 'success' && response.data != null) {
      List<CarRepairLogResponseDTO> allLogs = response.data!;

      if (widget.plate != null && widget.plate!.isNotEmpty) {
        allLogs = allLogs
            .where((log) =>
        log.carInfo.licensePlate.toUpperCase() ==
            widget.plate!.toUpperCase())
            .toList();
      }

      setState(() {
        logs = allLogs;
      });
    } else {
      if (mounted) {
        StringHelper.showErrorDialog(
            context, response.message ?? "Hata oluştu");
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogButtonPressed(CarRepairLogResponseDTO log) async {
    final responseTask = await TaskStatusApi().getTaskStatusByName("BAŞLANGIÇ");
    if (responseTask.status == 'success' && responseTask.data != null) {
      final customerId = log.customer?.id ?? "";
      final creatorUser = await UserPrefs.getUserWithID();

      if(creatorUser == null){
        StringHelper.showErrorDialog(context, 'Kullanıcı bilgileri bulunamadı.');
        return;
      }


      final request = CarRepairLogRequestDTO(
        carId: log.carInfo.id,
        creatorUserId: creatorUser!.userId,
        taskStatusId: responseTask.data!.id!,
        problemReportId: log.problemReport!.id,
        assignedUserId: log.assignedUser!.userId,
        description: log.description,
        dateTime: DateTime.now(),
        customerId: customerId,
      );

      final response = await CarRepairLogApi().createLog(request);

      if (response.status == 'success') {
        if (mounted) {
          StringHelper.showInfoDialog(context, 'Bilgiler kaydedildi.');
          widget.onConfirmed?.call();
          await _loadUserAndLogs();
        }
      } else {
        if (mounted) {
          StringHelper.showErrorDialog(
              context, response.message ?? "Hata oluştu");
        }
      }
    } else {
      if (mounted) {
        StringHelper.showErrorDialog(
            context, responseTask.message ?? "Hata oluştu");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 500,
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // کارت بالا: حتما Expanded یا SizedBox با width پر شده
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),// کارت پهن بشه روی کل عرض
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '$firstName $lastName',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          roleName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0), // یا مقدار دلخواه
              child: CarRepairLogListView(
                logs: logs,
                buttonBuilder: (log) {
                  return {
                    'text': 'İşe başlıyorum.',
                    'onPressed': () {
                      _handleLogButtonPressed(log);
                    },
                  };
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}
