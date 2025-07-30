import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'InventorySearchItem.dart';
import 'InventoryItemsTable.dart';
import 'InventorySaleLogsForm.dart';
import '../DTO/InventoryItemDTO.dart';

import 'InventoryItemEntry.dart';
import 'InventoryItemExit.dart';

class InventoryManageItems extends StatefulWidget {
  const InventoryManageItems({super.key});

  @override
  State<InventoryManageItems> createState() => _InventoryManageItemsState();
}

class _InventoryManageItemsState extends State<InventoryManageItems> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown و هر ویجت ثابتی که داری...
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(border: InputBorder.none),
            value: selectedOption,
            hint: const Text("Bir işlem seçin"),
            items: const [
              DropdownMenuItem(value: 'parçalar', child: Text("Parçalar")),
              DropdownMenuItem(value: 'giris', child: Text("Giriş Ürünleri")),
              DropdownMenuItem(value: 'cikis', child: Text("Çıkış Ürünleri")),
              DropdownMenuItem(value: 'arama', child: Text("Ürün Arama")),
              DropdownMenuItem(value: 'satilan', child: Text("Satılan Parçalar")),
            ],
            onChanged: (value) {
              setState(() {
                selectedOption = value;
              });
            },
          ),
        ),

        const SizedBox(height: 24),

        // فضای باقی‌مانده را بگیر و محتوای متغیر را داخل Expanded قرار بده
        Expanded(
          child: Builder(
            builder: (context) {
              switch (selectedOption) {
                case 'parçalar':
                  return InventoryItemsTable();
                case 'giris':
                  return InventoryItemEntry();
                case 'cikis':
                  return InventoryItemExit();
                case 'arama':
                  return InventorySearchItem();
                case 'satilan':
                  return InventorySaleLogsForm();
                default:
                  return const Center(child: Text("Lütfen bir işlem seçin"));
              }
            },
          ),
        ),
      ],
    );
  }

}
