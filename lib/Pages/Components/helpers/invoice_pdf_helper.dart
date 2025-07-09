import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// فقط برای وب
import 'package:universal_html/html.dart' as html;

// فقط برای موبایل/دسکتاپ
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../../DTO/PartUsed.dart';
import '../../../DTO/CarRepairLogResponseDTO.dart';

class InvoicePdfHelper {
  static Future<void> generateAndDownloadInvoicePdf({
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Image(logoImage, width: 350, height: 350),
                ),
                pw.SizedBox(height: 16),
                pw.Text("Servis Faturası",
                    style: pw.TextStyle(fontSize: 24, font: customFont)),
                pw.SizedBox(height: 16),
                pw.Text("Fatura Numarası: $invoiceNumber",
                    style: pw.TextStyle(font: customFont)),
                pw.Text("Tarih: $formattedDate",
                    style: pw.TextStyle(font: customFont)),
                pw.Text("Plaka: $licensePlate",
                    style: pw.TextStyle(font: customFont)),
                pw.Text("Araç: $car",
                    style: pw.TextStyle(font: customFont)),
                pw.SizedBox(height: 24),
                pw.Text("Parça Listesi:",
                    style: pw.TextStyle(fontSize: 18, font: customFont)),
                pw.Table.fromTextArray(
                  headers: ['#', 'Parça Adı', 'Adet', 'Birim Fiyat', 'Toplam'],
                  data: List.generate(parts.length, (index) {
                    final part = parts[index];
                    return [
                      (index + 1).toString(),
                      part.partName,
                      part.quantity.toString(),
                      part.partPrice.toStringAsFixed(0),
                      part.total.toStringAsFixed(0),
                    ];
                  }),
                  cellStyle: pw.TextStyle(font: customFont),
                  headerStyle: pw.TextStyle(
                      font: customFont, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("Toplam: ${total.toStringAsFixed(0)} TL",
                      style: pw.TextStyle(fontSize: 16, font: customFont)),
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      // وب: دانلود با استفاده از HTML API
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "$invoiceNumber.pdf")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // موبایل و دسکتاپ: ذخیره و باز کردن فایل
      await _saveAndOpenPdf(bytes, "$invoiceNumber.pdf");
    }
  }

  // تابع کمکی برای ذخیره و بازکردن PDF در موبایل و دسکتاپ
  static Future<void> _saveAndOpenPdf(Uint8List bytes, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    } catch (e) {
      // در صورت خطا می‌توانید پیام خطا نشان دهید
      print("PDF save/open error: $e");
    }
  }
}
