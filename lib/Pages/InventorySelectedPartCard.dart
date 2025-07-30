import 'package:flutter/material.dart';
import '../DTO/InventoryItemDTO.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class InventorySelectedPartCard extends StatelessWidget {
  final InventoryItemDTO part;
  final VoidCallback onDelete;

  const InventorySelectedPartCard({
    Key? key,
    required this.part,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final unitPrice = part.purchasePrice ?? 0;
    final qty = part.quantity ?? 0;
    final totalPrice = unitPrice * qty;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(part.partName ?? 'Parça'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Miktar: $qty'),
            Text('Birim Fiyat: ${unitPrice.toStringAsFixed(2)}₺'),
            Text('Toplam: ${totalPrice.toStringAsFixed(2)}₺'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(MdiIcons.trashCan, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
