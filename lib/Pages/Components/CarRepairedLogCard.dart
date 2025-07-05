import 'package:autonetwork/DTO/TaskStatusDTO.dart';
import 'package:autonetwork/Pages/Components/helpers/app_helpers.dart';
import 'package:autonetwork/Pages/user_prefs.dart';
import 'package:autonetwork/backend_services/backend_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../DTO/CarRepairLogRequestDTO.dart';
import '../../DTO/CarRepairLogResponseDTO.dart';

class CarRepairedLogCard extends StatelessWidget {
  final CarRepairLogResponseDTO log;

  const CarRepairedLogCard({Key? key, required this.log}) : super(key: key);

  final Map<String, String> statusSvgMap = const {
    'GÖREV YOK': 'assets/images/vector/stop.svg',
    'GİRMEK': 'assets/images/vector/entered-garage.svg',
    'SORUN GİDERME': 'assets/images/vector/note.svg',
    'ÜSTA': 'assets/images/vector/repairman.svg',
    'BAŞLANGIÇ': 'assets/images/vector/play.svg',
    'DURAKLAT': 'assets/images/vector/pause.svg',
    'İŞ BİTTİ': 'assets/images/vector/finish-flag.svg',
  };

  void _showLogDetails(BuildContext context, CarRepairLogResponseDTO log) async{
    bool showAcceptButton = log.taskStatus.taskStatusName == "ÜSTA";
    final user = await UserPrefs.getUserWithID();

    final taskStatusLog = await TaskStatusApi().getTaskStatusByName('BAŞLANGIÇ');
    TaskStatusDTO? taskStatus;
    if(taskStatusLog.status == 'success')
      taskStatus = taskStatusLog.data;
    else{
      StringHelper.showErrorDialog(context, taskStatusLog.message!);

      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rapor Detayları'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              SelectableText('Plaka: ${log.carInfo?.licensePlate ?? "-"}'),
              SelectableText('Araç: ${log.carInfo?.brand ?? "-"} ${log.carInfo?.brandModel ?? "-"}'),
              SelectableText('Görev Durumu: ${log.taskStatus?.taskStatusName ?? "-"}'),
              SelectableText(
                  'Bilgileri kaydeden çalışan: ' +
                      ((log.creatorUser.firstName != null && log.creatorUser.firstName!.isNotEmpty) &&
                          (log.creatorUser.lastName != null && log.creatorUser.lastName!.isNotEmpty)
                          ? '${log.creatorUser.firstName} ${log.creatorUser.lastName}'
                          : '-')
              ),
              SelectableText('Sorumlu çalışan: ${log.assignedUser?.firstName ?? "-"} ${log.assignedUser?.lastName ?? "-"}'),
              SelectableText('Tarih: ${log.dateTime?.toString() ?? "-"}'),
              SelectableText('\nAraç şikayeti: ${log.problemReport?.problemSummary ?? "-"}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: (){

              Navigator.of(context).pop();
              },
            child: const Text('Kapat'),
          ),
          if (showAcceptButton)
            TextButton(
              onPressed: () async{
                CarRepairLogRequestDTO request = CarRepairLogRequestDTO(
                  carId: log.carInfo.id,
                  creatorUserId: user!.userId,
                  assignedUserId: log.assignedUser!.userId,
                  description: '',
                  taskStatusId: taskStatus!.id!,
                  dateTime: DateTime.now(),
                  problemReportId: log.problemReport!.id,
                );

                final requestLog = await CarRepairLogApi().createLog(request);
                if(requestLog.status != 'success')
                  StringHelper.showErrorDialog(context, requestLog.message!);

                Navigator.of(context).pop();
              },
              child: const Text('işe başlıyorum'),
            ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final carInfo = log.carInfo;

    return Card(
      child: InkWell(
        onTap: () {

          _showLogDetails(context, log);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
              if (log.taskStatus?.taskStatusName != null &&
                  statusSvgMap.containsKey(log.taskStatus!.taskStatusName))
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SvgPicture.asset(
                    statusSvgMap[log.taskStatus!.taskStatusName]!,
                    width: 48,
                    height: 48,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
