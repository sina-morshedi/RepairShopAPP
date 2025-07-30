import 'package:autonetwork/DTO/UserProfileDTO.dart';
import 'package:autonetwork/Pages/user_prefs.dart';
import 'package:flutter/material.dart';
import '../backend_services/backend_services.dart';
import '../DTO/InventoryItemDTO.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../DTO/InventoryTransactionType.dart';
import '../DTO/InventoryTransactionRequestDTO.dart';
import 'package:get_storage/get_storage.dart';
import '../utils/string_helper.dart';

class InventoryAddItem extends StatefulWidget {
  const InventoryAddItem({super.key});

  @override
  State<InventoryAddItem> createState() => _InventoryAddItemState();
}

class _InventoryAddItemState extends State<InventoryAddItem> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _partNameController;
  late TextEditingController _barcodeController;
  late TextEditingController _categoryController;
  late TextEditingController _quantityController;
  late TextEditingController _locationController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _salePriceController;

  final FocusNode _partNameFocus = FocusNode();
  final FocusNode _barcodeFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _quantityFocus = FocusNode();
  final FocusNode _unitFocus = FocusNode(); // اگر لازم شد
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _purchasePriceFocus = FocusNode();
  final FocusNode _salePriceFocus = FocusNode();


  String? _selectedUnit;
  bool _isActive = true;
  String? storName;
  bool _autoGenerateBarcode = false;
  UserProfileDTO? user;


  final List<String> _unitOptions = ['ADET', 'KİLO', 'LİTRE', 'METRE'];

  @override
  void initState() {
    super.initState();
    final box = GetStorage();
    _partNameController = TextEditingController();
    _barcodeController = TextEditingController();
    _categoryController = TextEditingController();
    _quantityController = TextEditingController();
    _locationController = TextEditingController();
    _purchasePriceController = TextEditingController();
    _salePriceController = TextEditingController();
    _selectedUnit = _unitOptions[0];
    _loadUserProfile();

  }

  void _loadUserProfile() async{
    user = await UserPrefs.getUserWithID();
    storName = await UserPrefs.getStoreName();
  }

  @override
  void dispose() {
    _partNameController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();

    _partNameFocus.dispose();
    _barcodeFocus.dispose();
    _categoryFocus.dispose();
    _quantityFocus.dispose();
    _locationFocus.dispose();
    _purchasePriceFocus.dispose();
    _salePriceFocus.dispose();

    super.dispose();
  }

  String getInitials(String storName) {
    final words = storName.trim().split(RegExp(r'\s+'));
    final initials = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase();
      }
      return '';
    }).join();
    return initials;
  }

  Future<String?> sendBarcodeRequest() async {
    final prefix = getInitials(storName!); // تابعی که حروف اول رو میگیره
    final apiResponse = await InventoryApi().getNextBarcode(prefix);

    if (apiResponse.status == 'success') {

      return apiResponse.data;  // بارکد به صورت String
    } else {
      StringHelper.showErrorDialog(context,apiResponse.message!);
      return null;
    }
  }


  void _submit() async{
    if (!_formKey.currentState!.validate()) return;
    await _sendToBackend();
    final newBarcode = await sendBarcodeRequest();
    if (newBarcode != null) {
      setState(() {
        _barcodeController.text = newBarcode;
      });
    }
  }

  Future<void> _sendToBackend() async {

    final barcode = _barcodeController.text.trim().toUpperCase();
    final partName = _partNameController.text.trim().toUpperCase();
    final category = _categoryController.text.trim().toUpperCase();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final location = _locationController.text.trim().toUpperCase();
    final purchasePrice = _purchasePriceController.text.trim();
    final salePrice = _salePriceController.text.trim();
    final unit = _selectedUnit ?? '';

    final newItemDto = InventoryItemDTO(
      partName: partName,
      barcode: barcode,
      category: category,
      quantity: quantity,
      unit: unit,
      location: location,
      purchasePrice: purchasePrice.isNotEmpty ? double.tryParse(purchasePrice) : null,
      salePrice: salePrice.isNotEmpty ? double.tryParse(salePrice) : null,
      isActive: _isActive,
    );

    final addItemResponse = await InventoryApi().addItem(newItemDto);

    if (addItemResponse.status == 'success' && addItemResponse.data != null) {
      final createdItem = addItemResponse.data!;

      // آماده‌سازی DTO تراکنش ورودی کالا
      final transactionDto = InventoryTransactionRequestDTO(
        creatorUserId: user!.userId,  // اینجا باید آیدی کاربر فعلی رو بذاری
        inventoryItemId: createdItem.id!,
        quantity: quantity,
        type: TransactionType.INCOMING,  // اگه enum TransactionType رو داری باید مقدارش رو هم درست بفرستی
        description: 'Yeni stok girişi',
        dateTime: DateTime.now(),
      );

      final transactionResponse = await InventoryTransactionApi().addTransaction(transactionDto);

      if (transactionResponse.status == 'success') {
        StringHelper.showInfoDialog(context, transactionResponse.message!);
        _formKey.currentState?.reset();
      } else {
        StringHelper.showErrorDialog(context,transactionResponse.message!);
      }

    } else {
      StringHelper.showErrorDialog(context, addItemResponse.message!);
    }
  }


  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      border: const OutlineInputBorder(),
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: constraints.maxHeight,
          maxWidth: constraints.maxWidth,
          minWidth: 200,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Wrap(
              runSpacing: 10,
              children: [
                TextFormField(
                  controller: _partNameController,
                  focusNode: _partNameFocus,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_barcodeFocus),
                  decoration: _inputDecoration('Parça Adı', MdiIcons.wrench),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Parça adı zorunludur' : null,
                ),
                TextFormField(
                  controller: _barcodeController,
                  focusNode: _barcodeFocus,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_categoryFocus),
                  decoration: _inputDecoration('Barkod', MdiIcons.qrcodeScan),
                ),
                TextFormField(
                  controller: _categoryController,
                  focusNode: _categoryFocus,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_quantityFocus),
                  decoration: _inputDecoration('Kategori', MdiIcons.formatListBulleted),
                ),
                TextFormField(
                  controller: _quantityController,
                  focusNode: _quantityFocus,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_locationFocus),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Miktar', MdiIcons.counter),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Miktar gerekli';
                    if (int.tryParse(v) == null) return 'Geçerli bir sayı girin';
                    return null;
                  },
                ),

                // Dropdown for Unit Selection
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: _inputDecoration('Birim', MdiIcons.scale),
                  items: _unitOptions.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedUnit = val!;
                    });
                  },
                ),

                TextFormField(
                  controller: _locationController,
                  focusNode: _locationFocus,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_purchasePriceFocus),
                  decoration: _inputDecoration('Konum', MdiIcons.mapMarker),
                ),
                TextFormField(
                  controller: _purchasePriceController,
                  focusNode: _purchasePriceFocus,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_salePriceFocus),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('Alış Fiyatı', MdiIcons.cashMultiple),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (double.tryParse(v) == null) return 'Geçerli bir sayı girin';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _salePriceController,
                  focusNode: _salePriceFocus,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('Satış Fiyatı', MdiIcons.cash),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (double.tryParse(v) == null) return 'Geçerli bir sayı girin';
                    return null;
                  },
                ),
                Row(
                  children: [
                    const Text('Aktif:'),
                    Switch(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    const SizedBox(width: 20),
                    const Text('Barkod Oluştur:'),
                    Switch(
                      value: _autoGenerateBarcode,
                      onChanged: (val) async {
                        setState(() {
                          _autoGenerateBarcode = val;
                        });

                        if (val) {
                          final newBarcode = await sendBarcodeRequest();
                          if (newBarcode != null) {
                            setState(() {
                              _barcodeController.text = newBarcode;
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: const Text('Kaydet'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
