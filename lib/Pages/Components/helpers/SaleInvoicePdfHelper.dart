import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// فقط برای موبایل/دسکتاپ
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../../DTO/PartUsed.dart';
import '../../../DTO/CarRepairLogResponseDTO.dart';
import '../../../DTO/InventorySaleLogDTO.dart';
import '../../../DTO/SaleItem.dart';

class SaleInvoicePdfHelper {
  static Future<void> generateAndDownloadSaleInvoicePdf({
    required pw.Font customFont,
    required pw.MemoryImage logoImage,
    required InventorySaleLogDTO saleLog,
  }) async {
    final pdf = pw.Document();
    final double titleFontSize = 20;
    final double fontSize = 10;

    final now = saleLog.saleDate ?? DateTime.now();
    final formattedDate =
        "${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";
    final invoiceNumber =
        "S-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${saleLog.customerName ?? 'Musteri'}";

    final total = saleLog.totalAmount ?? 0.0;
    final totalPaid = saleLog.paymentRecords?.fold<double>(
      0.0,
          (sum, p) => sum + (p.amountPaid),
    ) ??
        0.0;
    final remaining = saleLog.remainingAmount ?? (total - totalPaid);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(child: pw.Image(logoImage, width: 200, height: 200)),
          pw.SizedBox(height: 16),
          pw.Text("Parça Satış Faturası",
              style: pw.TextStyle(fontSize: titleFontSize, font: customFont)),

          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Fatura No: $invoiceNumber",
                  style: pw.TextStyle(fontSize: fontSize, font: customFont)),
              pw.Text("Tarih: $formattedDate",
                  style: pw.TextStyle(fontSize: fontSize, font: customFont)),
            ],
          ),

          pw.SizedBox(height: 8),
          pw.Text("Müşteri: ${saleLog.customerName ?? '-'}",
              style: pw.TextStyle(fontSize: fontSize, font: customFont)),

          pw.SizedBox(height: 24),

          pw.Text("Satılan Parçalar:",
              style: pw.TextStyle(fontSize: titleFontSize - 4, font: customFont)),
          pw.Table.fromTextArray(
            headers: ['#', 'Parça Adı', 'Adet', 'Birim Fiyat', 'Toplam'],
            data: List.generate(saleLog.soldItems?.length ?? 0, (index) {
              final item = saleLog.soldItems![index];
              final unit = item.unitSalePrice ?? 0.0;
              final qty = item.quantitySold ?? 0;
              final total = unit * qty;
              return [
                (index + 1).toString(),
                item.partName ?? '',
                qty.toString(),
                "${unit.toStringAsFixed(2)} ₺",
                "${total.toStringAsFixed(2)} ₺",
              ];
            }),
            cellStyle: pw.TextStyle(fontSize: fontSize, font: customFont),
            headerStyle:
            pw.TextStyle(font: customFont, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text("Toplam: ${total.toStringAsFixed(2)} ₺",
                style: pw.TextStyle(fontSize: titleFontSize - 6, font: customFont)),
          ),

          // بخش پرداخت‌ها با چک null و isEmpty
          if (saleLog.paymentRecords != null && saleLog.paymentRecords!.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            pw.Text("Ödeme Kayıtları:",
                style: pw.TextStyle(
                    fontSize: titleFontSize - 4,
                    fontWeight: pw.FontWeight.bold,
                    font: customFont)),
            pw.SizedBox(height: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: saleLog.paymentRecords!.map((payment) {
                final date =
                    "${payment.paymentDate.year}/${payment.paymentDate.month.toString().padLeft(2, '0')}/${payment.paymentDate.day.toString().padLeft(2, '0')}";
                final amount = payment.amountPaid.toStringAsFixed(2);
                return pw.Text("• $date — $amount ₺",
                    style: pw.TextStyle(fontSize: fontSize, font: customFont));
              }).toList(),
            ),
            pw.SizedBox(height: 16),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Ödenen Toplam: ${totalPaid.toStringAsFixed(2)} ₺",
                style: pw.TextStyle(
                    fontSize: titleFontSize - 8,
                    fontWeight: pw.FontWeight.bold,
                    font: customFont),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Kalan Tutar: ${remaining.toStringAsFixed(2)} ₺",
                style: pw.TextStyle(
                    fontSize: titleFontSize - 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                    font: customFont),
              ),
            ),
            pw.SizedBox(height: 24),
          ] else ...[
            pw.SizedBox(height: 24),
            pw.Text('Ödeme kaydı bulunamadı.',
                style: pw.TextStyle(
                    fontSize: fontSize,
                    fontStyle: pw.FontStyle.italic,
                    font: customFont)),
            pw.SizedBox(height: 24),
          ],

          // باکس یادداشت (Note) همیشه نمایش داده می‌شود
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
              style: pw.TextStyle(fontSize: fontSize, font: customFont),
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
