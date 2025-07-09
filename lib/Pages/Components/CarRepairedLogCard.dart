import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../DTO/CarRepairLogRequestDTO.dart';
import '../../DTO/CarRepairLogResponseDTO.dart';

class CarRepairedLogCard extends StatelessWidget {
  final CarRepairLogResponseDTO log;
  final String? extraButtonText;
  final VoidCallback? onExtraButtonPressed;

  const CarRepairedLogCard({
    Key? key,
    required this.log,
    this.extraButtonText,
    this.onExtraButtonPressed,
  }) : super(key: key);

  static const Map<String, String> statusSvgMap = {
    'GÖREV YOK': 'assets/images/vector/stop.svg',
    'GİRMEK': 'assets/images/vector/entered-garage.svg',
    'SORUN GİDERME': 'assets/images/vector/note.svg',
    'USTA': 'assets/images/vector/repairman.svg',
    'BAŞLANGIÇ': 'assets/images/vector/play.svg',
    'DURAKLAT': 'assets/images/vector/pause.svg',
    'İŞ BİTTİ': 'assets/images/vector/finish-flag.svg',
    'FATURA': 'assets/images/vector/bill.svg',
  };

  void _showLogDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rapor Detayları'),
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
                        : '-'),
              ),
              SelectableText(
                  'Sorumlu çalışan: ${log.assignedUser?.firstName ?? "-"} ${log.assignedUser?.lastName ?? "-"}'),
              SelectableText('Tarih: ${log.dateTime?.toString() ?? "-"}'),
              SelectableText('\nAraç şikayeti: ${log.problemReport?.problemSummary ?? "-"}'),

              const SizedBox(height: 12),
              if (log.description != null && log.description!.isNotEmpty && log.taskStatus.taskStatusName == 'DURAKLAT') ...[
                const Text('Görev duraklama sebebi:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('- ${log.description}'),
              ],
              const SizedBox(height: 12),
              if (log.partsUsed != null && log.partsUsed!.isNotEmpty) ...[
                const Text('Kullanılan Parçalar:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...log.partsUsed!.map((part) => Text('- ${part.partName} (${part.quantity})')).toList(),
              ]
            ],
          ),
        ),
        actions: [
          if (extraButtonText != null && onExtraButtonPressed != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onExtraButtonPressed!();
              },
              child: Text(extraButtonText!),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final carInfo = log.carInfo;
    final statusName = log.taskStatus?.taskStatusName;
    final svgPath = (statusName != null && statusSvgMap.containsKey(statusName))
        ? statusSvgMap[statusName]
        : null;

    return Card(
      child: InkWell(
        onTap: () {
          _showLogDetails(context);
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
              if (svgPath != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SvgPicture.asset(
                    svgPath,
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
