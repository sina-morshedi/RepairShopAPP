import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// فقط برای موبایل/دسکتاپ
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../../DTO/PartUsed.dart';
import '../../../DTO/CarRepairLogResponseDTO.dart';


class InvoicePdfHelper {
  static Future<void> generateAndSaveInvoicePdf({
    required pw.Font customFont,
    required pw.MemoryImage logoImage,
    required List<PartUsed> parts,
    required CarRepairLogResponseDTO log,
    required String licensePlate,
  }) async {
    final pdf = pw.Document();

    final now = log.dateTime;
    final formattedDate =
        "${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";
    final invoiceNumber =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${log.carInfo.licensePlate}";

    final car = "${log.carInfo.brand} ${log.carInfo.brandModel}";
    final total = parts.fold<double>(0, (sum, part) => sum + part.total);

    final totalPaid = log.paymentRecords?.fold<double>(
      0.0,
          (sum, p) => sum + (p.amountPaid ?? 0.0),
    ) ??
        0.0;

    final remaining = total - totalPaid;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(child: pw.Image(logoImage, width: 250, height: 250)),
          pw.SizedBox(height: 16),
          pw.Text("Servis Faturası", style: pw.TextStyle(fontSize: 24, font: customFont)),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Fatura Numarası: $invoiceNumber", style: pw.TextStyle(font: customFont)),
              pw.Text("Tarih: $formattedDate", style: pw.TextStyle(font: customFont)),
            ],
          ),
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text("Plaka: $licensePlate", style: pw.TextStyle(font: customFont)),
              pw.SizedBox(width: 20),
              pw.Text("Araç: $car", style: pw.TextStyle(font: customFont)),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text("Parça Listesi:", style: pw.TextStyle(fontSize: 18, font: customFont)),
          pw.Table.fromTextArray(
            headers: ['#', 'Parça Adı', 'Adet', 'Birim Fiyat', 'Toplam'],
            data: List.generate(parts.length, (index) {
              final part = parts[index];
              return [
                (index + 1).toString(),
                part.partName,
                part.quantity.toString(),
                "${part.partPrice.toStringAsFixed(2)} ₺",
                "${part.total.toStringAsFixed(2)} ₺",
              ];
            }),
            cellStyle: pw.TextStyle(font: customFont),
            headerStyle: pw.TextStyle(font: customFont, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text("Toplam: ${total.toStringAsFixed(2)} ₺", style: pw.TextStyle(fontSize: 16, font: customFont)),
          ),
          pw.SizedBox(height: 24),
          if (log.paymentRecords != null && log.paymentRecords!.isNotEmpty) ...[
            pw.Text("Ödeme Kayıtları:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: customFont)),
            pw.SizedBox(height: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: log.paymentRecords!.map((payment) {
                final date = payment.paymentDate != null
                    ? "${payment.paymentDate!.year}/${payment.paymentDate!.month.toString().padLeft(2, '0')}/${payment.paymentDate!.day.toString().padLeft(2, '0')}"
                    : "";
                final amount = payment.amountPaid?.toStringAsFixed(2) ?? "0.00";
                return pw.Text("• $date — $amount ₺", style: pw.TextStyle(font: customFont));
              }).toList(),
            ),
            pw.SizedBox(height: 16),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Ödenen Toplam: ${totalPaid.toStringAsFixed(2)} ₺",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: customFont)),
            ),
            pw.SizedBox(height: 4),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Kalan Tutar: ${remaining.toStringAsFixed(2)} ₺",
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red, font: customFont),
              ),
            ),
          ],
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
              borderRadius: pw.BorderRadius.circular(6),
              color: PdfColors.grey200,
            ),
            child: pw.Text(
              '''Not: 
FARUK KARABACAK
GARANTİ BANKASI
IBAN  : TR87 0006 2001 2010 0006 6536 55''',
              style: pw.TextStyle(font: customFont),
            ),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    // مسیر ذخیره فایل در موبایل
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/$invoiceNumber.pdf";
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // باز کردن فایل با اپ پیش‌فرض
    await OpenFile.open(filePath);
  }
}
