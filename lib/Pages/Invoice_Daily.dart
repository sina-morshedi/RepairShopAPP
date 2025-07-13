
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:intl/intl.dart';

import 'user_prefs.dart';
import '../backend_services/backend_services.dart';

import 'Components/CarRepairedLogCard.dart';
import 'Components/helpers/invoice_pdf_helper.dart';
import 'Components/helpers/app_helpers.dart';

import '../DTO/PaymentRecord.dart';
import '../DTO/CarRepairLogResponseDTO.dart';
import '../DTO/CarRepairLogRequestDTO.dart';
import '../DTO/PartUsed.dart';


class InvoiceDaily extends StatefulWidget {
  const InvoiceDaily({super.key});

  @override
  _InvoiceDailyState createState() => _InvoiceDailyState();
}

class _InvoiceDailyState extends State<InvoiceDaily> {
  pw.Font? customFont;
  pw.MemoryImage? logoImage;
  final TextEditingController _plateController = TextEditingController();
  CarRepairLogResponseDTO? log;

  List<PartUsed> parts = [];
  List<double> totalPice = [];

  // کنترلرهای متن برای هر ردیف
  final List<TextEditingController> nameControllers = [];
  final List<TextEditingController> quantityControllers = [];
  final List<TextEditingController> priceControllers = [];
  final List<TextEditingController> totalPriceControllers = [];
  final TextEditingController invoicePriceController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _amountDueController = TextEditingController();
  bool _isAmountPaidEnabled=true;


  double totalSum = 0;
  final ValueNotifier<String> totalPriceText = ValueNotifier<String>("Toplam: 0.00 TL");
  final ValueNotifier<String> amountDueText = ValueNotifier<String>("Kalan Tutar: 0.00 TL");


  @override
  void initState() {
    super.initState();
    loadAssets();
  }

  @override
  void dispose() {
    _plateController.dispose();
    for (var c in nameControllers) {
      c.dispose();
    }
    for (var c in quantityControllers) {
      c.dispose();
    }
    for (var c in priceControllers) {
      c.dispose();
    }
    for (var c in totalPriceControllers) c.dispose();
    super.dispose();
  }

  void _syncControllersWithParts() {
    // پاک کردن کنترلرهای قدیمی
    for (var c in nameControllers) {
      c.dispose();
    }
    for (var c in quantityControllers) {
      c.dispose();
    }
    for (var c in priceControllers) {
      c.dispose();
    }
    for (var c in totalPriceControllers) {
      c.dispose();
    }
    nameControllers.clear();
    quantityControllers.clear();
    priceControllers.clear();
    totalPriceControllers.clear();

    // ساخت کنترلر جدید بر اساس parts
    for (var part in parts) {
      nameControllers.add(TextEditingController(text: part.partName));
      quantityControllers.add(TextEditingController(text: part.quantity.toString()));
      priceControllers.add(TextEditingController(text: part.partPrice.toString()));
      totalPriceControllers.add(TextEditingController(text: (part.quantity * part.partPrice).toString()));

    }
  }

  Future<void> loadAssets() async {
    final fontData = await rootBundle.load("assets/fonts/Vazirmatn-Regular.ttf");
    final imageData = await rootBundle.load("assets/images/invoice-logo.png");

    if (!mounted) return;

    setState(() {
      customFont = pw.Font.ttf(fontData);
      logoImage = pw.MemoryImage(imageData.buffer.asUint8List());
    });
  }


  Future<void> _searchByPlate() async {
    _isAmountPaidEnabled = true;
    final plate = _plateController.text.trim().toUpperCase();
    if (plate.isEmpty) return;

    final response = await CarRepairLogApi().getLatestLogByLicensePlate(plate);

    if (!mounted) return;

    if (response.status == 'success') {
      setState(() {
        log = response.data;
      });

      if (!mounted) return;
      if (response.data!.taskStatus.taskStatusName == "GÖREV YOK") {
        StringHelper.showErrorDialog(context, 'Araç girişi kaydedilmemiştir.');
        return;
      }

      if (response.data!.taskStatus.taskStatusName != "İŞ BİTTİ" &&
          response.data!.taskStatus.taskStatusName != "FATURA") {
        StringHelper.showErrorDialog(context, "${plate} numaralı plakanın işi henüz bitmedi");
        return;
      }

      final partUsedList = response.data!.partsUsed;
      if (partUsedList != null && partUsedList.isNotEmpty) {
        parts = partUsedList.map((part) {
          final price = part.partPrice?.toDouble() ?? 0.0;
          final validPrice = (price < 0) ? 0.0 : price;
          return PartUsed(
            partName: part.partName ?? '',
            partPrice: validPrice,
            quantity: part.quantity ?? 1,
          );
        }).toList();
      } else {
        parts = [];
      }

      _syncControllersWithParts();
      _calcInvoicePrice();
    } else {
      if (!mounted) return;
      StringHelper.showErrorDialog(context, response.message!);
    }
  }

  void _updateLog()async{
    final double totalInvoice = parts.fold(0.0, (sum, part) => sum + part.partPrice * part.quantity);

    final previousPayments = (log?.paymentRecords ?? []).fold<double>(
      0.0,
          (sum, p) => sum + (p.amountPaid ?? 0.0),
    );

    final double newPayment = double.tryParse(_amountPaidController.text.trim()) ?? 0.0;

    final double totalPaid = previousPayments + newPayment;

    final user = await UserPrefs.getUserWithID();
    final responseFatura = await TaskStatusApi().getTaskStatusByName('FATURA');
    final responseFaturaOdeme = await TaskStatusApi().getTaskStatusByName('GÖREV YOK');

    _amountPaidController.text = '';

    if (responseFatura.status != 'success' || responseFaturaOdeme.status != 'success') {
      StringHelper.showErrorDialog(context, 'Görev durumu alınamadı.');
      return;
    }

    final selectedTaskStatusId = (totalPaid >= totalInvoice)
        ? responseFaturaOdeme.data!.id!
        : responseFatura.data!.id!;

    final updatedPayments = List<PaymentRecord>.from(log?.paymentRecords ?? []);
    if (newPayment > 0) {
      updatedPayments.add(
        PaymentRecord(
          paymentDate: DateTime.now(),
          amountPaid: newPayment,
        ),
      );
    }

    final request = CarRepairLogRequestDTO(
      carId: log!.carInfo.id,
      creatorUserId: user!.userId,
      assignedUserId: log!.assignedUser!.userId,
      description: log!.description,
      taskStatusId: selectedTaskStatusId,
      problemReportId: log!.problemReport!.id,
      partsUsed: parts,
      paymentRecords: updatedPayments,
      dateTime: DateTime.now(),
    );

    if(selectedTaskStatusId == responseFaturaOdeme.data!.id){
      final requestupdate = CarRepairLogRequestDTO(
        carId: log!.carInfo.id,
        creatorUserId: user!.userId,
        assignedUserId: log!.assignedUser!.userId,
        description: log!.description,
        taskStatusId: responseFatura.data!.id!,
        problemReportId: log!.problemReport!.id,
        partsUsed: parts,
        paymentRecords: updatedPayments,
        dateTime: DateTime.now(),
      );

      final responseUpdate = await CarRepairLogApi().updateLog(log!.id!, requestupdate);
      if (responseUpdate.status == 'success') {
        StringHelper.showInfoDialog(context, 'Bilgiler kaydedildi.');
        setState(() {
          log = responseUpdate.data;
        });
      } else {
        StringHelper.showErrorDialog(context, responseUpdate.message!);
        return;
      }

      final response = await CarRepairLogApi().createLog(request);
      if (response.status == 'success') {
        StringHelper.showInfoDialog(context, 'Bilgiler kaydedildi.');
        setState(() {
          log = response.data;
          _isAmountPaidEnabled = false;
        });
      } else {
        StringHelper.showErrorDialog(context, response.message!);
        return;
      }
    }
    else
    {
      if (log!.taskStatus.taskStatusName != 'FATURA') {
        final response = await CarRepairLogApi().createLog(request);
        if (response.status == 'success') {
          StringHelper.showInfoDialog(context, 'Bilgiler kaydedildi.');
          setState(() {
            log = response.data;
          });
        } else
          StringHelper.showErrorDialog(context, response.message!);
      } else {
        final response = await CarRepairLogApi().updateLog(log!.id!, request);
        if (response.status == 'success') {
          StringHelper.showInfoDialog(context, 'Bilgiler kaydedildi.');
          setState(() {
            log = response.data;
          });
        } else
          StringHelper.showErrorDialog(context, response.message!);
      }
    }
    _searchByPlate();
  }

  void _calcInvoicePrice() {
    double sum = 0;
    for (var controller in totalPriceControllers) {
      sum += double.tryParse(controller.text) ?? 0;
    }
    double totalPaid = 0.0;
    if (log!.paymentRecords != null) {
      for (var payment in log!.paymentRecords!) {
        totalPaid += payment.amountPaid;
      }
    }

    double remaining = sum - totalPaid;

    totalPriceText.value = "Toplam: ${sum.toStringAsFixed(2)} ₺";

    double amountDue = remaining - (double.tryParse(_amountPaidController.text) ?? 0.0);
    amountDueText.value = "Kalan: ${amountDue} ₺";

  }

  Widget buildPaymentSection() {
    final payments = log?.paymentRecords ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // نمایش لیست پرداخت‌ها (اگه چیزی باشه)
        if (payments.isNotEmpty) ...[
          const Text(
            'Yapılan Ödemeler:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          ...payments.map((payment) {
            final date = DateFormat('yyyy/MM/dd').format(payment.paymentDate);
            final amount = payment.amountPaid.toStringAsFixed(2);
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $date — $amount ₺'),
            );
          }).toList(),
          const SizedBox(height: 12),
        ],

        // فیلد جدید برای ثبت پرداخت جدید
        SizedBox(
          width: 140,
          child: TextField(
            controller: _amountPaidController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Ödeme (₺)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
            enabled: _isAmountPaidEnabled,
            onChanged: (value) {
              _calcInvoicePrice();
            },
          ),
        ),
      ],
    );
  }



  Widget buildPartsInputList() {
    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ...parts.asMap().entries.map((entry) {
          final index = entry.key;
          final part = entry.value;

          return Padding(
            key: ValueKey(part),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Column(
                  children: [
                    if (index == parts.length - 1) ...[
                      IconButton(
                        icon: const Icon(EvaIcons.plusCircleOutline, color: Colors.green),
                        tooltip: "Yeni Parça Ekle",
                        onPressed: () {
                          parts.insert(index + 1, PartUsed(partName: '', partPrice: 0, quantity: 1));
                          _syncControllersWithParts();
                          _calcInvoicePrice();
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: const Icon(EvaIcons.closeCircleOutline, color: Colors.red),
                        tooltip: "Bu Parçayı Sil",
                        onPressed: () {
                          parts.removeAt(index);
                          _syncControllersWithParts();
                          _calcInvoicePrice();
                          setState(() {});
                        },
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(EvaIcons.closeCircleOutline, color: Colors.red),
                        tooltip: "Bu Parçayı Sil",
                        onPressed: () {
                          parts.removeAt(index);
                          _syncControllersWithParts();
                          _calcInvoicePrice();
                          setState(() {});
                        },
                      ),
                    ],
                  ],
                ),
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                controller: nameControllers[index],
                                decoration: const InputDecoration(
                                  labelText: 'Parça Adı',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val) {
                                  parts[index] = PartUsed(
                                    partName: val,
                                    partPrice: parts[index].partPrice,
                                    quantity: parts[index].quantity,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: quantityControllers[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  labelText: 'Adet',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  final newQty = int.tryParse(value) ?? 1;
                                  parts[index] = PartUsed(
                                    partName: parts[index].partName,
                                    partPrice: parts[index].partPrice,
                                    quantity: newQty,
                                  );
                                  totalPriceControllers[index].text = (newQty * parts[index].partPrice).toString();
                                  _calcInvoicePrice();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: priceControllers[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                decoration: const InputDecoration(
                                  labelText: 'Birim Fiyat',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val) {
                                  final newPrice = double.tryParse(val) ?? 0;
                                  parts[index] = PartUsed(
                                    partName: parts[index].partName,
                                    partPrice: newPrice,
                                    quantity: parts[index].quantity,
                                  );
                                  totalPriceControllers[index].text =
                                      (parts[index].quantity * newPrice).toString();
                                  _calcInvoicePrice();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Toplam: ${(parts[index].quantity * parts[index].partPrice).toStringAsFixed(2)} ₺',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 16),

        Divider(thickness: 2, color: Colors.grey.shade400),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder<String>(
              valueListenable: totalPriceText,
              builder: (context, value, _) => Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: buildPaymentSection(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder<String>(
              valueListenable: amountDueText,
              builder: (context, value, _) => Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _updateLog();
              },
              child: const Text('Faturayı Güncelle'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     _vehicleDelivery();
            //   },
            //   child: const Text('Araç teslim ediliyor'),
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _plateController,
              decoration: InputDecoration(
                labelText: "Plaka Numarası",
                suffixIcon: IconButton(
                  icon: const Icon(EvaIcons.search),
                  onPressed: _searchByPlate,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: (customFont == null || logoImage == null || parts.isEmpty)
                  ? null
                  :  () {
                InvoicePdfHelper.generateAndSaveInvoicePdf(
                  customFont: customFont!,
                  logoImage: logoImage!,
                  parts: parts,
                  log: log!,
                  licensePlate: log!.carInfo.licensePlate,
                );
              },
              icon: const Icon(EvaIcons.fileText),
              label: const Text("Faturayı Göster"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (log != null) ...[
              CarRepairedLogCard(log: log!),
              const SizedBox(height: 24),
            ],
            buildPartsInputList(),
          ],
        ),
      ),
    );
  }
}
