
import 'package:flutter/material.dart';
import 'FinalReportForEachCarsTab.dart';
import 'FilterReportsTab.dart';

class ReportsForm extends StatefulWidget {
  @override
  _ReportsFormState createState() => _ReportsFormState();
}

class _ReportsFormState extends State<ReportsForm>{

  String? str;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // aynı dış boşluk
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.blue,
              tabs: [
                Tab(text: 'Tüm Raporlar'),
                Tab(text: 'Plakaya Göre Filtre'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: const TabBarView(
                children: [
                  FinalReportForEachCarTab(),
                  FilterReportsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





