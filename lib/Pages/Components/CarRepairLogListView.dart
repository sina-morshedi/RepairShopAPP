import 'package:flutter/material.dart';
import 'CarRepairedLogCard.dart';
import '../../DTO/CarRepairLogRequestDTO.dart';
import '../../DTO/CarRepairLogResponseDTO.dart';

class CarRepairLogListView extends StatelessWidget {
  final List<CarRepairLogResponseDTO> logs;

  const CarRepairLogListView({Key? key, required this.logs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(child: Text("Hiç kayıt bulunamadı."));
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: false,
      itemCount: logs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          child: CarRepairedLogCard(log: logs[index]),
        );
      },
    );
  }
}
