part of app_helpers;

class StringHelper {
  static void showMessage(String message, {BuildContext? context}) {
    if (kIsWeb && context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      Fluttertoast.showToast(msg: message);
    }
  }

  static Future<void> ShowDetailsLogDialog(BuildContext context, CarRepairLogResponseDTO log) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: SelectableText('Detaylar - Plaka: ${log.carInfo.licensePlate}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                    'Araç: ${log.carInfo?.brand ?? '-'} ${log.carInfo?.brandModel ?? '-'}'),
                SelectableText('Motor No: ${log.carInfo?.motorNo ?? '-'}'),
                SelectableText('Şasi No: ${log.carInfo?.chassisNo ?? '-'}'),
                const SizedBox(height: 8),
                SelectableText(
                    'Oluşturan: ${log.creatorUser.firstName} ${log.creatorUser.lastName}'),
                //Text('Kullanıcı ID: ${log.creatorUser?.id ?? '-'}'),
                const SizedBox(height: 8),
                SelectableText('Status: ${log.taskStatus.taskStatusName ?? '-'}'),
                const SizedBox(height: 8),
                SelectableText(
                    'Problem Özeti: ${log.problemReport?.problemSummary ?? '-'}'),
                SelectableText(
                    'Oluşturulma Tarihi: ${log.dateTime.toString().split('.')[0]}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showErrorDialog(BuildContext context, String errorMessage) async{
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(EvaIcons.alertTriangle, color: Colors.red), // Eva error icon
              SizedBox(width: 8),
              Text(
                'Hata:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('TAMAM'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showInfoDialog(BuildContext context, String errorMessage) async{
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(EvaIcons.info, color: Colors.blue), // Left info icon
              SizedBox(width: 8),
              Text('Bilgi:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.info, color: Colors.blue), // Right info icon
            ],
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('TAMAM'),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> showConfirmDialog(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(EvaIcons.alertTriangleOutline, color: Colors.orange), // آیکون هشدار چپ
              const SizedBox(width: 8),
              const Text('Onayla:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Icon(Icons.help_outline, color: Colors.orange), // آیکون هشدار راست
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // انصراف
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // تأیید
              child: const Text('Onayla'),
            ),
          ],
        );
      },
    );

    return result ?? false; // اگر دیالوگ بسته شد بدون انتخاب، false برگردون
  }

}
