
import 'package:flutter/material.dart';

import 'CarEntry.dart';
import 'GetCarProblem.dart';
import 'AssignedCustomerToCar.dart';

class TroubleshootingForm extends StatefulWidget {
  const TroubleshootingForm({super.key});
  @override
  _TroubleshootingFormState createState() => _TroubleshootingFormState();
}

class _TroubleshootingFormState extends State<TroubleshootingForm>{



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16), // aynı dış boşluk
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.blue,
              tabs: [
                Tab(text: 'Araç giriş'),
                Tab(text: 'Araç şikayetli'),
                Tab(text: 'Araç sahibini'),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 500,  // istediğiniz yükseklik
              child: const TabBarView(
                children: [
                  CarEntry(),
                  GetCarProblem(),
                  AssignedCustomerToCar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

