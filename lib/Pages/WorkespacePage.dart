import 'package:autonetwork/DTO/CarRepairLogResponseDTO.dart';
import 'package:autonetwork/DTO/TaskStatusDTO.dart';
import 'package:autonetwork/Pages/Components/helpers/app_helpers.dart';
import 'package:autonetwork/Pages/user_prefs.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../backend_services/backend_services.dart';
import '../DTO/TaskStatusUserRequestDTO.dart';
import '../DTO/CarRepairLogRequestDTO.dart';
import '../DTO/PartUsed.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkespacePage extends StatefulWidget {
  @override
  State<WorkespacePage> createState() => _WorkespacePageState();
}

class _WorkespacePageState extends State<WorkespacePage> {
  final Map<String, String> statusSvgMap = const {
    'GÖREV YOK': 'assets/images/vector/stop.svg',
    'GİRMEK': 'assets/images/vector/entered-garage.svg',
    'SORUN GİDERME': 'assets/images/vector/note.svg',
    'USTA': 'assets/images/vector/repairman.svg',
    'BAŞLANGIÇ': 'assets/images/vector/play.svg',
    'DURAKLAT': 'assets/images/vector/pause.svg',
    'İŞ BİTTİ': 'assets/images/vector/finish-flag.svg',
    'FATURA': 'assets/images/vector/bill.svg',
  };

  List<Map<String, dynamic>> cars = [];
  final TextEditingController _pauseReasonController = TextEditingController();
  Map<int, List<TextEditingController>> partNameControllers = {};
  Map<int, List<TextEditingController>> quantityControllers = {};
  List<CarRepairLogResponseDTO>? logs;

  @override
  void initState() {
    super.initState();
    _loadCarsFromBackend();
  }

  @override
  void dispose() {
    for (var list in partNameControllers.values) {
      for (var c in list) {
        c.dispose();
      }
    }
    for (var list in quantityControllers.values) {
      for (var c in list) {
        c.dispose();
      }
    }
    _pauseReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadCarsFromBackend() async {
    final user = await UserPrefs.getUserWithID();
    final request = TaskStatusUserRequestDTO(
      assignedUserId: user!.userId,
      taskStatusNames: ["BAŞLANGIÇ", "DURAKLAT"],
    );

    final response = await CarRepairLogApi().getLatestLogsByTaskStatusesAndUserId(request);

    if (response.status == 'success') {
      logs = response.data!;

      final loadedCars = logs!.map<Map<String, dynamic>>((log) {
        final car = log.carInfo;
        return {
          "licensePlate": car.licensePlate,
          "brand": car.brand,
          "model": car.brandModel,
          "year": car.modelYear.toString(),
          "taskStatusName": log.taskStatus.taskStatusName,
          "isExpanded": false,
        };
      }).toList();

      setState(() {
        cars = loadedCars;
        partNameControllers.clear();
        quantityControllers.clear();

        for (int i = 0; i < cars.length; i++) {
          final log = logs![i];
          final partsUsed = log.partsUsed;

          // اگر پارت داشت، تکس‌فیلدها رو به تعدادش بساز
          if (partsUsed != null && partsUsed.isNotEmpty) {
            partNameControllers[i] = partsUsed
                .map((p) => TextEditingController(text: p.partName))
                .toList();

            quantityControllers[i] = partsUsed
                .map((p) => TextEditingController(text: p.quantity.toString()))
                .toList();
          } else {
            // اگر پارت نداشت، فقط یکی بساز
            partNameControllers[i] = [TextEditingController()];
            quantityControllers[i] = [TextEditingController(text: "1")];
          }
        }
      });

    } else {
      StringHelper.showErrorDialog(context, response.message!);
    }
  }

  void addPartField(int index) {
    setState(() {
      partNameControllers[index]!.add(TextEditingController());
      quantityControllers[index]!.add(TextEditingController(text: "1"));
    });
  }

  void removePartField(int index, int partIndex) {
    setState(() {
      if (partNameControllers[index]!.length > 1) {
        partNameControllers[index]![partIndex].dispose();
        quantityControllers[index]![partIndex].dispose();
        partNameControllers[index]!.removeAt(partIndex);
        quantityControllers[index]!.removeAt(partIndex);
      }
    });
  }

  void _showPauseDialog(BuildContext context, int index) {
    // final respo
    _pauseReasonController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Görev Duraklaması Sebebi"),
        content: TextField(
          controller: _pauseReasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Lütfen duraklama sebebini yazınız",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              final reason = _pauseReasonController.text.trim();
              Navigator.of(ctx).pop();
              saveRepairLog(index,'DURAKLAT',pauseReason: reason);
              print("Görev duraklama sebebi: $reason, araç indeksi: $index");
            },
            child: Text("Onayla"),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, int index, String action) {
    String actionLabel = action;
    switch (action) {
      case "Save":
        actionLabel = "Kaydet";
        break;
      case "Load":
        actionLabel = "Yükle";
        break;
      case "Finish Job":
        actionLabel = "İş Bitir";
        break;
      case "Approve Job":
        actionLabel = "Görev Duraklaması";
        break;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("$actionLabel Onayı"),
        content: Text("Araç için $actionLabel işlemini yapmak istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text("İptal")),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (action == "Save") {
                saveRepairLog(index,'BAŞLANGIÇ');
              } else if (action == "Load") {
                loadRepairLog(index);
                print("Loading repair log for index $index");
              } else if (action == "Finish Job") {
                saveRepairLog(index,'İŞ BİTTİ');
              }else {
                print("Confirmed action: $action for index $index");
              }
            },
            child: Text("Onayla"),
          ),
        ],
      ),
    );
  }

  Future<void> loadRepairLog(int index) async {
    final currentLog = logs?[index];
    if (currentLog == null || currentLog.id == null) return;

    final response = await CarRepairLogApi().getLogByid(currentLog.id!);
    if (response.status == 'success' && response.data != null) {
      final updatedLog = response.data!;
      logs![index] = updatedLog;

      setState(() {
        cars[index] = {
          "licensePlate": updatedLog.carInfo.licensePlate,
          "brand": updatedLog.carInfo.brand,
          "model": updatedLog.carInfo.brandModel,
          "year": updatedLog.carInfo.modelYear.toString(),
          "taskStatusName": updatedLog.taskStatus.taskStatusName,
          "isExpanded": true,
        };

        partNameControllers[index] = updatedLog.partsUsed?.map(
              (p) => TextEditingController(text: p.partName),
        ).toList() ?? [TextEditingController()];

        quantityControllers[index] = updatedLog.partsUsed?.map(
              (p) => TextEditingController(text: p.quantity.toString()),
        ).toList() ?? [TextEditingController(text: "1")];
      });
    } else {
      StringHelper.showErrorDialog(context, response.message ?? "Sunucu hatası");
    }
  }

  void saveRepairLog(int index, String newTaskStatusName, {String? pauseReason}) async {
    if (logs == null || index >= logs!.length) return;

    final log = logs![index];
    final partsUsed = <PartUsed>[];
    final isPause = newTaskStatusName.toUpperCase() == 'DURAKLAT';

    for (int i = 0; i < partNameControllers[index]!.length; i++) {
      final name = partNameControllers[index]![i].text.trim();
      final qtyStr = quantityControllers[index]![i].text.trim();

      if (name.isEmpty && qtyStr.isEmpty) {
        if (isPause) continue;
        continue;
      }

      if (name.isEmpty) {
        if (!isPause) {
          StringHelper.showErrorDialog(context, "Parça adı boş olamaz (satır ${i + 1})");
          return;
        }
        continue;
      }

      if (qtyStr.isEmpty) {
        if (!isPause) {
          StringHelper.showErrorDialog(context, "Adet bilgisi boş olamaz (satır ${i + 1})");
          return;
        }
        continue;
      }

      final qty = int.tryParse(qtyStr);
      if (qty == null || qty <= 0) {
        if (!isPause) {
          StringHelper.showErrorDialog(context, "Adet değeri geçersiz (satır ${i + 1})");
          return;
        }
        continue;
      }

      partsUsed.add(PartUsed(partName: name, quantity: qty));
    }

    TaskStatusDTO? matchingStatus;
    final responseTask = await TaskStatusApi().getTaskStatusByName(newTaskStatusName);
    if (responseTask.status == 'success') {
      matchingStatus = responseTask.data;
    } else {
      StringHelper.showErrorDialog(context, responseTask.message!);
      return;
    }

    final customerId = log?.customer?.id ?? "";
    final dto = CarRepairLogRequestDTO(
      carId: log.carInfo.id,
      creatorUserId: log.creatorUser.userId,
      assignedUserId: log.assignedUser?.userId,
      description: pauseReason,
      taskStatusId: matchingStatus!.id!,
      dateTime: DateTime.now(),
      problemReportId: log.problemReport?.id,
      partsUsed: partsUsed.isEmpty ? null : partsUsed,
      customerId: customerId,
    );

    final response = await CarRepairLogApi().updateLog(log.id!, dto);

    if (response.status == 'success') {
      StringHelper.showInfoDialog(context, "Faturayı güncelledi.");
    } else {
      StringHelper.showErrorDialog(context, response.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Araç Çalışma Alanı")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: cars.length,
          itemBuilder: (context, index) {
            final car = cars[index];
            final isExpanded = car["isExpanded"] as bool;

            return GestureDetector(
              onTap: () => setState(() => car["isExpanded"] = !isExpanded),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade400, blurRadius: 5, offset: Offset(0, 2))
                  ],
                ),
                child: isExpanded
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Plaka: ${car['licensePlate']}", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Marka: ${car['brand']}"),
                    Text("Model: ${car['model']}"),
                    Text("Yıl: ${car['year']}"),
                    SizedBox(height: 8),
                    ...List.generate(partNameControllers[index]!.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: partNameControllers[index]![i],
                                decoration: InputDecoration(
                                  hintText: "Parça adı",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            SizedBox(
                              width: 50,

                              child: TextField(
                                controller: quantityControllers[index]![i],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Adet",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(EvaIcons.plusCircleOutline),
                              onPressed: () => addPartField(index),
                            ),
                            if (partNameControllers[index]!.length > 1)
                              IconButton(
                                icon: Icon(EvaIcons.minusCircleOutline, color: Colors.red),
                                onPressed: () => removePartField(index, i),
                              ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _showConfirmDialog(context, index, "Save"),
                            child: Text("Kaydet"),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _showConfirmDialog(context, index, "Load"),
                            child: Text("Yükle"),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _showConfirmDialog(context, index, "Finish Job"),
                            child: Text("İş Bitir"),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _showPauseDialog(context, index),
                            child: Text("Görev Duraklaması"),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Plaka: ${car['licensePlate']}", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Marka: ${car['brand']}"),
                          Text("Model: ${car['model']}"),
                          Text("Yıl: ${car['year']}"),
                        ],
                      ),
                    ),
                    if (car["taskStatusName"] != null &&
                        statusSvgMap.containsKey(car["taskStatusName"]))
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: SvgPicture.asset(
                          statusSvgMap[car["taskStatusName"]]!,
                          width: 48,
                          height: 48,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
