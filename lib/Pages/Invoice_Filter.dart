import 'package:autonetwork/DTO/UserProfileDTO.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

import '../backend_services/backend_services.dart';

import 'Components/helpers/invoice_pdf_helper.dart';
import 'Components/helpers/app_helpers.dart';
import 'Components/CarRepairLogListView.dart';

import '../DTO/FilterRequestDTO.dart';
import '../DTO/CarRepairLogResponseDTO.dart';
import 'user_prefs.dart';

class InvoiceFilter extends StatefulWidget {
  const InvoiceFilter({super.key});

  @override
  _InvoiceFilterState createState() => _InvoiceFilterState();
}

class _InvoiceFilterState extends State<InvoiceFilter> {
  pw.Font? customFont;
  pw.MemoryImage? logoImage;
  DateTime? _startDate;
  DateTime? _endDate;
  List<CarRepairLogResponseDTO> _logs = [];
  final TextEditingController _licensePlateController = TextEditingController();
  UserProfileDTO? user;
  String? permissionName;


  @override
  void initState() {
    super.initState();
    loadAssets();
    _loadUser();
  }

  Future<void> loadAssets() async {
    final fontData = await rootBundle.load("assets/fonts/Vazirmatn-Regular.ttf");
    final imageData = await rootBundle.load("assets/images/invoice-logo.png");

    setState(() {
      customFont = pw.Font.ttf(fontData);
      logoImage = pw.MemoryImage(imageData.buffer.asUint8List());
    });
  }

  void _search() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen başlangıç ve bitiş tarihlerini seçin')),
      );
      return;
    }

    List<String> _selectedTaskStatusNames = ["FATURA"];

    final localStartDate = DateTime(_startDate!.year, _startDate!.month, _startDate!.day, 0, 0, 0);
    final localEndDate = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);

    final utcStartDate = localStartDate.toUtc();
    final utcEndDate = localEndDate.toUtc();

    // ارسال مستقیم به DTO با فرمت ISO 8601 (UTC)
    FilterRequestDTO filterRequest = FilterRequestDTO(
      taskStatusNames: _selectedTaskStatusNames,
      startDate: utcStartDate,
      endDate: utcEndDate,
    );


    final response = await CarRepairLogApi().getLogsByTaskNameAndDateRange(filterRequest);

    if (response.status == 'success') {
      setState(() {
        _logs = response.data!;
      });
    } else {
      StringHelper.showErrorDialog(context, response.message!);
    }
  }

  void _searchByLicensePlate() async {
    final plate = _licensePlateController.text.trim().toUpperCase();
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen plaka girin')),
      );
      return;
    }

    FilterRequestDTO filterRequest = FilterRequestDTO(
      taskStatusNames: ["FATURA"], // فرضاً لیست انتخاب شده
      licensePlate: plate,
    );
    final response = await CarRepairLogApi().getLogsByTaskNameAndLicensePlate(filterRequest);

    if (response.status == 'success') {
      setState(() {
        _logs = response.data!;
      });
    } else {
      StringHelper.showErrorDialog(context, response.message!);
    }
  }


  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _endDate ?? DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _startDate!.isAfter(_endDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }


  void _loadUser() async{
    user = await UserPrefs.getUserWithID();
    setState(() {
      permissionName  = user!.permission.permissionName ?? "";
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // اینجا تاریخ‌های انتخاب شده رو بالای صفحه نشون می‌ده
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Seçilen Tarihler: ' +
                (_startDate != null
                    ? '${_startDate!.year}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.day.toString().padLeft(2, '0')}'
                    : '-') +
                ' - ' +
                (_endDate != null
                    ? '${_endDate!.year}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.day.toString().padLeft(2, '0')}'
                    : '-'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // ردیف انتخاب تاریخ و دکمه
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectStartDate(context),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _startDate == null
                        ? 'Başlangıç Tarihi'
                        : '${_startDate!.year}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectEndDate(context),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _endDate == null
                        ? 'Bitiş Tarihi'
                        : '${_endDate!.year}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _search,
              child: const Text('Ara'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'Plaka ile ara',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _searchByLicensePlate,
              child: const Text('Ara'),
            ),
          ],
        ),

        Expanded(
          child: CarRepairLogListView(
            logs: _logs,
            buttonBuilder: permissionName != null && permissionName == 'Yönetici'
                ? (log) {
              return {
                'text': 'Fatura',
                'onPressed': () async {
                  InvoicePdfHelper.generateAndSaveInvoicePdf(
                    customFont: customFont!,
                    logoImage: logoImage!,
                    parts: log.partsUsed!,
                    log: log,
                    licensePlate: log.carInfo.licensePlate,
                  );
                },
              };
            }
                : null,
          )

        ),

      ],
    );
  }

}
