import 'package:autonetwork/Pages/user_prefs.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

import '../backend_services/backend_services.dart';
import '../DTO/CustomerDTO.dart';
import '../DTO/CarRepairLogRequestDTO.dart';
import '../DTO/CarRepairLogResponseDTO.dart';
import 'Components/CarRepairedLogCard.dart';
import 'Components/CarRepairLogListView.dart';
import 'CustomerInfoCard.dart';
import 'Components/helpers/app_helpers.dart';

class AssignedCustomerToCar extends StatefulWidget {
  const AssignedCustomerToCar({super.key});

  @override
  _AssignedCustomerToCarState createState() => _AssignedCustomerToCarState();
}

class _AssignedCustomerToCarState extends State<AssignedCustomerToCar> {
  TextEditingController _licensePlateController = TextEditingController();
  TextEditingController _customerNameController = TextEditingController(); // کنترلر جدید برای جستجوی مشتری
  CarRepairLogResponseDTO? log;
  List<CustomerDTO>? customerData;
  CustomerDTO? selectedCustomer;

  bool isLoading = false;
  bool foundLog = false;

  // جستجو برای پلاک
  void _searchLogsByLicensePlate(String licensePlate) async {
    try {
      setState(() {
        isLoading = true;
        log = null;
        selectedCustomer = null;
      });

      final response = await CarRepairLogApi().getLatestLogByLicensePlate(licensePlate);
      if (response.status == 'success') {
        setState(() {
          log = response.data;
          foundLog = true;
        });
      } else {
        foundLog = false;
        StringHelper.showErrorDialog(context, 'Log Response: ${response.message!}');
      }
    } catch (e) {
      StringHelper.showErrorDialog(context, '$e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // جستجو برای مشتری
  void _searchCustomer() async {
    final name = _customerNameController.text.trim();
    if (name.isEmpty) return;

    final response = await CustomerApi().searchCustomerByName(name);

    if (response.status == 'success') {
      setState(() {
        customerData = response.data!;
      });
    } else {
      StringHelper.showErrorDialog(context, response.message!);
    }
  }

  void _saveLog() async{
    if(log == null) {
      StringHelper.showErrorDialog(context, 'Log Is null.');
      return;
    }

    final user = await UserPrefs.getUserWithID();
    final userId = user!.userId;


    final assignedUserId = log!.assignedUser!.userId ?? "";
    final description = log!.description ?? "";
    final taskStatusId = log!.taskStatus.id! ?? "";
    final problemReportId = log!.problemReport!.id! ?? "";
    // final logRequest = CarRepairLogRequestDTO(
    //   carId: log!.carInfo.id,
    //   creatorUserId: userId,
    //   assignedUserId: assignedUserId,
    //   description: description,
    //   taskStatusId: taskStatusId,
    //   dateTime: DateTime.now(),
    //   problemReportId: problemReportId,
    //   partsUsed: log!.partsUsed,
    //   paymentRecords: log!.paymentRecords,
    //   customerId: selectedCustomer!.id,
    // );
    final logRequest = CarRepairLogRequestDTO(
      carId: log!.carInfo.id,
      creatorUserId: userId,
      assignedUserId: (log?.assignedUser?.userId?.isNotEmpty ?? false) ? log!.assignedUser!.userId : null,
      description: (log?.description?.isNotEmpty ?? false) ? log!.description! : null,
      taskStatusId: log!.taskStatus.id!,
      dateTime: DateTime.now(),
      problemReportId: (log?.problemReport?.id?.isNotEmpty ?? false) ? log!.problemReport!.id! : null,
      partsUsed: (log?.partsUsed?.isNotEmpty ?? false) ? log!.partsUsed : null,
      paymentRecords: (log?.paymentRecords?.isNotEmpty ?? false) ? log!.paymentRecords : null,
      customerId: selectedCustomer?.id,
    );

    final response = await CarRepairLogApi().updateLog(log!.id!,logRequest);
    if(response.status == 'success'){
      StringHelper.showInfoDialog(context, 'Bilgiler kaydedildi.');
    } else
      StringHelper.showErrorDialog(context, response.message!);

    print('Saved');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _licensePlateController,
                    decoration: InputDecoration(
                      labelText: 'Plaka Girin',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          String licensePlate = _licensePlateController.text.toUpperCase();
                          _searchLogsByLicensePlate(licensePlate);
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // اگر لاگ پیدا شد
            if (log != null) ...[
              CarRepairedLogCard(log: log!),
              const SizedBox(height: 20),

              // اگر مشتری نال باشد، جستجو برای مشتری را نمایش بده
              if (log!.customer == null) ...[
                TextField(
                  controller: _customerNameController, // کنترلر جدید برای جستجوی مشتری
                  decoration: InputDecoration(
                    labelText: 'Müşteri adı',
                    suffixIcon: IconButton(
                      icon: const Icon(EvaIcons.search),
                      onPressed: _searchCustomer,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                if (customerData != null && customerData!.isNotEmpty)
                  CustomerListCard(
                    customers: customerData!,
                    selectedCustomer: selectedCustomer,
                    onSelected: (c) => setState(() => selectedCustomer = c),
                  ),
              ],
            ],

            // اگر لاگ پیدا نشد
            if (log == null && !isLoading) ...[
              const SizedBox(height: 16),
              Text("Araba bulunamadı ya da log bulunamadı."),
            ],

            const SizedBox(height: 20),

            // اگر مشتری انتخاب شد
            if (selectedCustomer != null) ...[
              ElevatedButton(
                onPressed: () {
                  if (selectedCustomer != null) {
                    _saveLog();
                  }
                },
                child: const Text('Müşteri Seçildi'),
              ),
            ],

            // نشانگر بارگذاری در صورت بارگذاری داده‌ها
            if (isLoading) ...[
              const SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

