import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../backend_services/backend_services.dart';
import '../DTO/CarRepairLogRequestDTO.dart';
import '../DTO/CarRepairLogResponseDTO.dart';
import '../DTO/TaskStatusDTO.dart';
import '../DTO/UserProfileDTO.dart';
import 'Components/helpers/app_helpers.dart';

class ProjectmanageForm extends StatefulWidget {
  final String? plate;
  final void Function(bool assigned)? onAssignChanged;

  const ProjectmanageForm({
    Key? key,
    this.plate,
    this.onAssignChanged,
  }) : super(key: key);

  @override
  _ProjectmanageFormState createState() => _ProjectmanageFormState();
}

class _ProjectmanageFormState extends State<ProjectmanageForm> {
  List<CarRepairLogResponseDTO>? carRepairLogs;
  List<UserProfileDTO>? users;
  List<TaskStatusDTO>? taskStatus;
  List<String?> selectedUserIds = [];
  List<bool> approvedFlags = [];

  bool isLoading = true;
  String? errorMessage;

  final Map<String, String> statusSvgMap = const {
    'GÖREV YOK': 'assets/images/vector/stop.svg',
    'GİRMEK': 'assets/images/vector/entered-garage.svg',
    'SORUN GİDERME': 'assets/images/vector/note.svg',
    'USTA': 'assets/images/vector/repairman.svg',
    'BAŞLANGIÇ': 'assets/images/vector/play.svg',
    'DURAKLAT': 'assets/images/vector/pause.svg',
    'İŞ BİTTİ': 'assets/images/vector/finish-flag.svg',
  };

  @override
  void initState() {
    super.initState();
    fetchLatestLogs();
  }

  String? findTaskStatusIdByName(String name) {
    if (taskStatus == null) return null;
    final found = taskStatus!.firstWhere(
          (status) => status.taskStatusName == name,
      orElse: () => TaskStatusDTO(id: '', taskStatusName: ''),
    );
    return found.id!.isNotEmpty ? found.id : null;
  }

  void fetchLatestLogs() async {
    setState(() {
      isLoading = true;
    });

    final carLogs = await CarRepairLogApi().getLatestLogByTaskStatusName('SORUN GİDERME');
    final usersLogs = await backend_services().fetchAllProfile();
    final taskStatusLog = await TaskStatusApi().getAllStatuses();

    if (carLogs.status == 'success' && usersLogs.status == 'success' && taskStatusLog.status == 'success') {
      List<CarRepairLogResponseDTO> tempLogs = carLogs.data!;

      if (widget.plate != null && widget.plate!.isNotEmpty) {
        tempLogs = tempLogs.where((log) =>
        (log.carInfo?.licensePlate?.toUpperCase() ?? '') == widget.plate!.toUpperCase()
        ).toList();
      }
      setState(() {
        carRepairLogs = tempLogs;
        users = usersLogs.data!;
        taskStatus = taskStatusLog.data!;
        selectedUserIds = List.filled(carRepairLogs!.length, null);
        approvedFlags = List.filled(carRepairLogs!.length, false);
        isLoading = false;
      });
    } else {
      if (carLogs.status == 'error') StringHelper.showErrorDialog(context, carLogs.message!);
      if (usersLogs.status == 'error') StringHelper.showErrorDialog(context, usersLogs.message!);
      if (taskStatusLog.status == 'error') StringHelper.showErrorDialog(context, taskStatusLog.message!);

      setState(() {
        isLoading = false;
      });
    }
  }

  void _saveCarLog(int index) async {
    final log = carRepairLogs![index];
    final statusId = findTaskStatusIdByName('USTA') ?? log.taskStatus.id;

    final requestDTO = CarRepairLogRequestDTO(
      carId: log.carInfo.id,
      creatorUserId: log.creatorUser.userId,
      assignedUserId: selectedUserIds[index],
      description: log.description,
      taskStatusId: statusId!,
      dateTime: DateTime.now(),
      problemReportId: log.problemReport?.id,
      customerId: log.customer?.id ?? null,
    );

    final response = await CarRepairLogApi().createLog(requestDTO);
    if (response.status == 'success') {
      StringHelper.showInfoDialog(context, 'Bilgiler kaydedildi.');
      setState(() {
        approvedFlags[index] = true;
      });
      if (widget.onAssignChanged != null) {
        widget.onAssignChanged!(true);
      }
    } else
      StringHelper.showErrorDialog(context, response.message!);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (carRepairLogs == null || carRepairLogs!.isEmpty) {
      return const Center(child: Text("Hiçbir rapor bulunamadı."));
    }

    final displayLogs = widget.plate != null && widget.plate!.isNotEmpty
        ? carRepairLogs!.where((log) =>
    (log.carInfo?.licensePlate?.toUpperCase() ?? '') == widget.plate!.toUpperCase()).toList()
        : carRepairLogs!;

    if (displayLogs.isEmpty) {
      return const Center(child: Text("İlgili kayıt bulunamadı."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(displayLogs.length, (index) {
          final log = displayLogs[index];
          final carInfo = log.carInfo;
          final taskStatusName = log.taskStatus?.taskStatusName ?? '';
          final svgPath = statusSvgMap[taskStatusName];
          final originalIndex = carRepairLogs!.indexOf(log);
          final selectedUserId = selectedUserIds[originalIndex];
          final approved = approvedFlags[originalIndex];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(  // به جای Row کلی
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ردیف اول: اطلاعات ماشین + svg + تیک
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              'Plaka: ${carInfo?.licensePlate ?? "-"}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SelectableText('Marka: ${carInfo?.brand ?? ""} ${carInfo?.brandModel ?? ""}'),
                            SelectableText('Model Yılı: ${carInfo?.modelYear ?? ""}'),
                            SelectableText('Yakıt Tipi: ${carInfo?.fuelType ?? ""}'),
                          ],
                        ),
                      ),
                      if (svgPath != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SvgPicture.asset(
                            svgPath,
                            width: 50,
                            height: 50,
                            placeholderBuilder: (context) =>
                            const CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: selectedUserIds[originalIndex] != null && !approvedFlags[originalIndex]
                                ? () {
                              _saveCarLog(originalIndex);
                            }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectedUserIds[originalIndex] != null && !approvedFlags[originalIndex]
                                    ? Colors.green.shade100
                                    : Colors.grey.shade300,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.check,
                                color: selectedUserIds[originalIndex] != null && !approvedFlags[originalIndex]
                                    ? Colors.green
                                    : Colors.grey,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12), // فاصله بین دو ردیف

                  // ردیف دوم: دراپ‌داون باکس به صورت تمام عرض
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedUserId,
                        hint: const Text("Kullanıcı seçin"),
                        items: users!.map((user) {
                          return DropdownMenuItem<String>(
                            value: user.userId,
                            child: Text('${user.firstName} ${user.lastName}' ?? "No Username"),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUserIds[originalIndex] = value;
                            approvedFlags[originalIndex] = false;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

        }),
      ),
    );
  }
}
