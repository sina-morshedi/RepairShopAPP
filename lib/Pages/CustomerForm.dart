import 'package:flutter/material.dart';
import 'Customer_Add.dart';
import 'Customer_Editor.dart';

class CustomerForm extends StatefulWidget {
  const CustomerForm({super.key});

  @override
  _CustomerFormState createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
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
                Tab(text: "Müşteri bilgilerini ekle"),
                Tab(text: "Müşteri bilgilerini düzenle"),
              ],
            ),
            const SizedBox(height: 8),
            // اینجا Expanded گذاشتیم به جای SizedBox ثابت
            Expanded(
              child: const TabBarView(
                children: [
                  CustomerAdd(),
                  CustomerEditor(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

