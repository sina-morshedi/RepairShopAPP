import 'package:flutter/material.dart';
import 'Invoice_Daily.dart';
import 'Invoice_Filter.dart';

class InvoiceForm extends StatefulWidget {
  const InvoiceForm({super.key});

  @override
  _InvoiceFormState createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.blue,
              tabs: [
                Tab(text: "Fatura Oluştur"),
                Tab(text: "Fatura Ara"),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: const TabBarView(
                children: [
                  InvoiceDaily(),
                  InvoiceFilter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
