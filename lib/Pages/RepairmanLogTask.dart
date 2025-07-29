import 'package:flutter/material.dart';
import '../backend_services/backend_services.dart';
import '../DTO/CarRepairLogResponseDTO.dart';
import '../DTO/TaskStatusUserRequestDTO.dart';
import '../DTO/CarRepairLogRequestDTO.dart';
import '../DTO/UserProfileDTO.dart';
import '../utils/string_helper.dart';
import 'CarRepairLogListView.dart';

class RepairmanLogTask extends StatefulWidget {
  final UserProfileDTO user;
  final String? plate; // شماره پلاک به صورت اختیاری
  final VoidCallback? onConfirmed; // برای فراخوانی پس از تأیید موفق

  const RepairmanLogTask({
    Key? key,
    required this.user,
    this.plate,
    this.onConfirmed,
  }) : super(key: key);

  @override
  State<RepairmanLogTask> createState() => _RepairmanLogTaskState();
}

class _RepairmanLogTaskState extends State<RepairmanLogTask> {
  bool isSaving = false;

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

      // ✅ اگر پلاک مشخص شده بود، فقط اون‌ها رو نگه داریم
      if (widget.plate != null && widget.plate!.isNotEmpty) {
        allLogs = allLogs.where((log) =>
        log.carInfo.licensePlate.toUpperCase() ==
            widget.plate!.toUpperCase()).toList();
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
    setState(() {
      isSaving = true;
    });

    final responseTask = await TaskStatusApi().getTaskStatusByName("BAŞLANGIÇ");
    if (responseTask.status == 'success' && responseTask.data != null) {
      // ادامه عملیات ذخیره
      final customerId = log.customer?.id ?? "";

      final request = CarRepairLogRequestDTO(
        carId: log.carInfo.id,
        creatorUserId: user.userId,
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
          setState(() {
            logs.removeWhere((element) => element == log);
          });
          widget.onConfirmed?.call();
          await _loadUserAndLogs();
        }
      } else {
        if (mounted) {
          StringHelper.showErrorDialog(context, response.message ?? "Hata oluştu");
        }
      }
    } else {
      if (mounted) {
        StringHelper.showErrorDialog(context, responseTask.message ?? "Hata oluştu");
      }
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Text('$firstName $lastName',
                    overflow: TextOverflow.ellipsis),
                const Spacer(),
                Text(roleName, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text("Çalışanın Görevleri"),
        const SizedBox(height: 12),
        Expanded(
          child: CarRepairLogListView(
            logs: logs,
            buttonBuilder: (log) {
              return {
                'text': isSaving ? 'Kaydediliyor...' : 'İşe başlıyorum.',
                'onPressed': isSaving
                    ? null // غیرفعال کردن دکمه
                    : () {
                  _handleLogButtonPressed(log);
                },
              };
            },

          ),
        ),
      ],
    );
  }
}

