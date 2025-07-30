import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'InventoryItemsTable.dart';
import '../DTO/InventoryItemDTO.dart';
import '../DTO/UserProfileDTO.dart';
import '../backend_services/backend_services.dart';
import 'user_prefs.dart';
import '../Pages/Components/helpers/app_helpers.dart';

class InventorySearchItem extends StatefulWidget {
  const InventorySearchItem({super.key});

  @override
  State<InventorySearchItem> createState() => _InventorySearchItemState();
}

class _InventorySearchItemState extends State<InventorySearchItem> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _partNameController = TextEditingController();
  List<InventoryItemDTO> searchResults = [];
  String? permissionName;

  bool _showDeleteIcon = false;
  UserProfileDTO? user;
  String? storeName;

  void _loadUserProfile() async{
    user = await UserPrefs.getUserWithID();
    storeName = await UserPrefs.getStoreName();
  }
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    permissionName =
        user?.permission.permissionName ?? "";
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final barcode = _barcodeController.text.trim();
    final partName = _partNameController.text.trim();

    if (barcode.isEmpty && partName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir arama kriteri girin.')),
      );
      return;
    }

    _onSearch(barcode, partName);
  }

  void _deleteItem(InventoryItemDTO item) async {
    if (item == null) return;

    final confirmed =
    await StringHelper.showConfirmDialog(context, "Silmek istiyor musunuz?");
    if (!confirmed) return;

    final response = await InventoryApi().deleteItem(item.id);

    if (response.status == 'success') {
      StringHelper.showInfoDialog(context, response.message!);
    } else {
      StringHelper.showErrorDialog(context, response.message!);
    }
  }

  void _onSearch(String barcode, String partName) async {
    setState(() {
      searchResults = [];
    });

    if (barcode.isNotEmpty) {
      final response = await InventoryApi().getItemByBarcode(barcode);
      if (response.status == 'success') {
        final InventoryItemDTO item = response.data!;
        setState(() {
          searchResults = [item];
        });
        return;
      } else {
        StringHelper.showErrorDialog(context, response.message ?? 'Bir hata oluştu');
      }
    } else if (partName.isNotEmpty) {
      final response = await InventoryApi().getByPartName(partName);
      if (response.status == 'success') {
        final results = response.data ?? [];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              searchResults = results;
            });
          }
        });
      } else {
        StringHelper.showErrorDialog(context, response.message!);
      }
    } else {
      StringHelper.showErrorDialog(context, 'Hiçbir arama kriteri girilmedi');
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _partNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Wrap(
                runSpacing: 10,
                children: [
                  TextFormField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: 'Barkod ile Ara',
                      prefixIcon: Icon(MdiIcons.barcode),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  TextFormField(
                    controller: _partNameController,
                    decoration: const InputDecoration(
                      labelText: 'Parça Adı ile Ara',
                      prefixIcon: Icon(EvaIcons.search),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (permissionName == "Yönetici")
                        Row(
                          children: [
                            Checkbox(
                              value: _showDeleteIcon,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _showDeleteIcon = value;
                                  });
                                }
                              },
                            ),
                            const Text('Silme Modu'),
                          ],
                        ),
                      ElevatedButton.icon(
                        onPressed: _submit,

                        icon: const Icon(EvaIcons.search),
                        label: const Text('Ara'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (searchResults.isNotEmpty)
              InventoryItemsTable(
                items: searchResults,
                showDeleteIcon: _showDeleteIcon,
                onDelete: _deleteItem,
              )
            else
              const Center(child: Text('Arama sonucu yok')),
          ],
        ),
      ),
    );
  }

}
