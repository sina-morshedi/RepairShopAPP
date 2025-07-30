import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../backend_services/backend_services.dart';
import '../DTO/UserProfileDTO.dart';
import '../utils/string_helper.dart';
import 'InsertCarInfoForm.dart';
import 'RepairmanWorkespaceInFlow.dart';
import 'CarEntry.dart';
import 'GetCarInfoPage.dart';
import 'GetCarProblem.dart';
import 'ProjectManageForm.dart';
import 'RepairmanLogTaskInFlow.dart';
import 'Invoice_Daily.dart';
import 'GetCarInfoPage.dart';

class TaskFlowManager extends StatefulWidget {

  const TaskFlowManager({super.key});

  @override
  TaskFlowManagerState createState() => TaskFlowManagerState();
}

class TaskFlowManagerState extends State<TaskFlowManager> {
  final RxString currentTaskStatusName = ''.obs;

  final RxBool showCarEntry = false.obs;
  final RxBool showCustomerAdd = false.obs;
  final RxBool showInsertCarForm = false.obs;
  final RxBool showGetCarProblem = false.obs;
  final RxBool showProjectManager = false.obs;
  final RxBool showRepairmanLogTask = false.obs;
  final RxBool showRepairmanWorkespace = false.obs;
  final RxBool showInvoiceDaily = false.obs;
  final Rx<UserProfileDTO?> selectedRepairman = Rx<UserProfileDTO?>(null);
  bool hasLoadedRepairmanInProject = true;


  final RxBool isLoading = true.obs;
  static String? licensePlate;

  // این متد برای صدا زدن از بیرون با GlobalKey استفاده میشه
  void triggerSearch(String plate, BuildContext context) {
    processFlowWithPlate(plate);
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = false;
    showInsertCarForm.value = false;
    showCarEntry.value = false;
    showCustomerAdd.value = false;
    showGetCarProblem.value = false;
    showProjectManager.value = false;
    showRepairmanLogTask.value = false;
    showRepairmanWorkespace.value = false;
    showInvoiceDaily.value = false;
  }

  void onInsertCarSuccess(String plate) {
    licensePlate = plate;
    showInsertCarForm.value = false;
    showCarEntry.value = true;
  }

  Future<void> loadSelectedRepairman(String plate) async {
    final response = await CarRepairLogApi().getLatestLogByLicensePlate(plate);
    if (response.status == 'success' && response.data != null) {

      final assigned = response.data!.assignedUser;
      if (assigned != null) {
        selectedRepairman.value = assigned;
      } else {
        StringHelper.showErrorDialog(context, response.message!);
      }
    } else {
      StringHelper.showErrorDialog(context, response.message!);
    }
  }

  Future<void> processFlowWithPlate(String plateInput) async {
    showInsertCarForm.value = false;
    showCarEntry.value = false;
    showCustomerAdd.value = false;
    showGetCarProblem.value = false;
    showProjectManager.value = false;
    showRepairmanLogTask.value = false;
    showRepairmanWorkespace.value = false;
    showInvoiceDaily.value = false;
    isLoading.value = true;

    final plate = plateInput.trim().toUpperCase();
    if (plate.isEmpty) {
      currentTaskStatusName.value = '';
      isLoading.value = false;
      return;
    }

    final carResponse = await CarInfoApi().getCarInfoByLicensePlate(plate);
    if (carResponse.status != 'success') {
      showInsertCarForm.value = true;
      isLoading.value = false;
      return;
    }

    final response = await CarRepairLogApi().getLatestLogByLicensePlate(plate);
    if (response.status != 'success') {

      setState(() {
        licensePlate = plate;
        showCustomerAdd.value = true; // ✅ دکمه رو فعال کن
      });
    } else{
      if(response.data!.taskStatus.taskStatusName == 'GÖREV YOK'){
        setState(() {
          licensePlate = plate;
          showCarEntry.value = true;
          isLoading.value = false;
        });
      }
      if(response.data!.taskStatus.taskStatusName == 'GİRMEK'){
        setState(() {
          licensePlate = plate;
          showGetCarProblem.value = true;
        });
      }
      if(response.data!.taskStatus.taskStatusName == 'SORUN GİDERME'){
        setState(() {
          licensePlate = plate;
          showProjectManager.value = true;
        });
      }
      if (response.data!.taskStatus.taskStatusName == 'USTA') {
        await loadSelectedRepairman(plate);
        setState(() {
          licensePlate = plate;
          showRepairmanLogTask.value = true;
        });
      }
      if (response.data!.taskStatus.taskStatusName == 'BAŞLANGIÇ'
      ||  response.data!.taskStatus.taskStatusName == 'DURAKLAT') {
        await loadSelectedRepairman(plate);
        setState(() {
          licensePlate = plate;
          showRepairmanWorkespace.value = true;
        });
      }

      if(response.data!.taskStatus.taskStatusName == 'İŞ BİTTİ'
      || response.data!.taskStatus.taskStatusName == 'FATURA'){
        setState(() {
          licensePlate = plate;
          showInvoiceDaily.value = true;
        });

      }
    }

    isLoading.value = false;
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showInsertCarForm.value)
              InsertCarInfoForm(
                onSuccess: onInsertCarSuccess,
              ),

            if (showCustomerAdd.value) ...[
              ElevatedButton(
                onPressed: () {
                  showCarEntry.value = false;
                },
                child: const Text("Müşteri eklemeden devam et"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  showCustomerAdd.value = false;
                  showCarEntry.value = true;
                },
                child: const Text("Sonraki"),
              ),
            ],

            if (showCarEntry.value)
              CarEntry(
                initialPlate: licensePlate,
                onEntrySuccess: () {
                  showCarEntry.value = false;
                  showGetCarProblem.value = true;
                },
              ),

            if (showGetCarProblem.value)
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: GetCarProblem(
                  plate: licensePlate!,
                  onProblemSaved: () {
                    processFlowWithPlate(licensePlate!);
                    showGetCarProblem.value = false;
                    showProjectManager.value = true;
                  },

                ),
              ),


            if (showProjectManager.value) ...[
              ProjectmanageForm(
                plate: licensePlate!,
                onAssignChanged: (assigned) {
                  if (assigned) {
                    _loadInitialData();
                    showProjectManager.value = false;
                    hasLoadedRepairmanInProject = false;
                  }
                },
              ),
            ],

            if (!hasLoadedRepairmanInProject)
              FutureBuilder(
                future: Future.delayed(Duration.zero, () async {
                  await loadSelectedRepairman(licensePlate!);
                  hasLoadedRepairmanInProject = true;
                  showRepairmanLogTask.value = true;
                }),
                builder: (_, __) => const SizedBox(),
              ),

            if (showRepairmanLogTask.value && selectedRepairman.value != null)
              RepairmanLogTaskInFlow(
                user: selectedRepairman.value!,
                plate: licensePlate,
                onConfirmed: () {
                  showRepairmanLogTask.value = false;
                  showRepairmanWorkespace.value = true;
                },
              ),

            if (showRepairmanWorkespace.value && selectedRepairman.value != null)
              RepairmanWorkespaceInFlow(
                user: selectedRepairman.value!,
                plate: licensePlate,
                onConfirmed: () {
                  showRepairmanWorkespace.value = false;
                  showInvoiceDaily.value = true;
                },
              ),

            if (showInvoiceDaily.value)
              InvoiceDaily(
                plate: licensePlate,
              ),
          ],
        ),
      );
    });
  }

}
