import 'package:autonetwork/Pages/user_prefs.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

import '../backend_services/backend_services.dart';
import '../DTO/CustomerDTO.dart';
import '../DTO/CarRepairLogRequestDTO.dart';
import '../DTO/CarRepairLogResponseDTO.dart';
import '../DTO/CarInfoDTO.dart';
import 'Components/CarRepairedLogCard.dart';
import 'Components/CarRepairLogListView.dart';
import 'CustomerInfoCard.dart';
import 'Components/helpers/app_helpers.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),  // بستن کیبورد با کلیک بیرون
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TypeAheadField<CarInfoDTO>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _licensePlateController,
                        decoration: InputDecoration(
                          labelText: 'Plaka Girin',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              String licensePlate = _licensePlateController.text.toUpperCase();
                              _searchLogsByLicensePlate(licensePlate);
                              FocusScope.of(context).unfocus();  // بستن کیبورد هنگام کلیک روی دکمه
                            },
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        onSubmitted: (value) {
                          _searchLogsByLicensePlate(value.toUpperCase());
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      suggestionsCallback: (pattern) async {
                        if (pattern.trim().isEmpty) return [];
                        final response = await CarInfoApi().searchCarsByLicensePlateKeyword(pattern);
                        if (response.status == 'success' && response.data != null) {
                          return response.data!;
                        }
                        return [];
                      },
                      itemBuilder: (context, CarInfoDTO suggestion) {
                        return ListTile(
                          title: Text(suggestion.licensePlate ?? ''),
                          subtitle: Text(suggestion.brandModel ?? ''),
                        );
                      },
                      onSuggestionSelected: (CarInfoDTO suggestion) {
                        _licensePlateController.text = suggestion.licensePlate ?? '';
                        _searchLogsByLicensePlate(_licensePlateController.text.toUpperCase());
                        FocusScope.of(context).unfocus();  // بستن کیبورد پس از انتخاب
                      },
                      noItemsFoundBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Eşleşen araç bulunamadı'),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (log != null) ...[
                CarRepairedLogCard(log: log!),
                const SizedBox(height: 20),

                if (log!.customer == null) ...[
                  TextField(
                    controller: _customerNameController,
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

              if (log == null && !isLoading) ...[
                const SizedBox(height: 16),
                Text("Araba bulunamadı ya da log bulunamadı."),
              ],

              const SizedBox(height: 20),

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

              if (isLoading) ...[
                const SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

