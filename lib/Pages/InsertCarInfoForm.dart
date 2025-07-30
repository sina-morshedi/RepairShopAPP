import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../backend_services/backend_services.dart';
import '../DTO/CarInfo.dart';
import '../utils/string_helper.dart';

class InsertCarInfoForm extends StatefulWidget {
  final void Function(String plate)? onSuccess;

  const InsertCarInfoForm({Key? key, this.onSuccess}) : super(key: key);

  @override
  State<InsertCarInfoForm> createState() => _InsertCarInfoFormState();
}

class _InsertCarInfoFormState extends State<InsertCarInfoForm> {
  final _formKeyInsertCarInfo = GlobalKey<FormState>();
  bool isSaving = false;

  final TextEditingController plateController = TextEditingController();
  final TextEditingController chassisController = TextEditingController();
  final TextEditingController motorController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  final FocusNode plateFocus = FocusNode();
  final FocusNode chassisFocus = FocusNode();
  final FocusNode motorFocus = FocusNode();
  final FocusNode brandFocus = FocusNode();
  final FocusNode modelFocus = FocusNode();
  final FocusNode yearFocus = FocusNode();

  String? _selectedFuelType;

  @override
  void dispose() {
    plateController.dispose();
    chassisController.dispose();
    motorController.dispose();
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();

    plateFocus.dispose();
    chassisFocus.dispose();
    motorFocus.dispose();
    brandFocus.dispose();
    modelFocus.dispose();
    yearFocus.dispose();

    super.dispose();
  }

  Future<void> saveCarInfo() async {
    setState(() => isSaving = true);

    try {
      final carInfo = CarInfo(
        chassisNo: chassisController.text.toUpperCase(),
        motorNo: motorController.text.toUpperCase(),
        licensePlate: plateController.text.toUpperCase(),
        brand: brandController.text.trim().toUpperCase(),
        brandModel: modelController.text.toUpperCase(),
        modelYear: int.tryParse(yearController.text),
        fuelType: _selectedFuelType ?? '',
        dateTime: DateTime.now().toIso8601String(),
      );

      final response = await CarInfoApi().insertCarInfo(carInfo);

      if (response.status != 'error') {
        StringHelper.showInfoDialog(context, 'BAŞARILI');
        widget.onSuccess?.call(plateController.text.trim().toUpperCase());
      } else {
        StringHelper.showErrorDialog(context, response.message ?? 'HATA');
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  void unfocusAll() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unfocusAll,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKeyInsertCarInfo,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text("YENİ ARAÇ BİLGİLERİ", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: plateController,
                      focusNode: plateFocus,
                      label: "PLAKA",
                      nextFocus: chassisFocus,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: chassisController,
                      focusNode: chassisFocus,
                      label: "ŞASE NO",
                      nextFocus: motorFocus,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: motorController,
                      focusNode: motorFocus,
                      label: "MOTOR NO",
                      nextFocus: brandFocus,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: brandController,
                      focusNode: brandFocus,
                      label: "MARKASI",
                      nextFocus: modelFocus,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: modelController,
                      focusNode: modelFocus,
                      label: "TİCARİ ADI",
                      nextFocus: yearFocus,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: yearController,
                      focusNode: yearFocus,
                      label: "MODEL YILI",
                      isNumber: true,
                      nextFocus: null, // آخرین فیلد -> آن‌فوکوس
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _selectedFuelType,
                      decoration: const InputDecoration(
                        labelText: "YAKIT CİNSİ",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'BENZİNLİ', child: Text('BENZİNLİ')),
                        DropdownMenuItem(value: 'MAZOTLU', child: Text('MAZOTLU')),
                        DropdownMenuItem(value: 'BENZİNLİ LPG', child: Text('BENZİNLİ LPG')),
                        DropdownMenuItem(value: 'LPG', child: Text('LPG')),
                        DropdownMenuItem(value: 'ELEKTRİKLİ', child: Text('ELEKTRİKLİ')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedFuelType = value);
                      },
                      validator: (value) =>
                      value == null || value.isEmpty ? 'ZORUNLU ALAN' : null,
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(EvaIcons.saveOutline),
                        label: const Text("KAYDET"),
                        onPressed: () {
                          if (_formKeyInsertCarInfo.currentState?.validate() ?? false) {
                            saveCarInfo();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isSaving) ...[
            Positioned.fill(
              child: ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.3)),
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    FocusNode? nextFocus,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          focusNode.unfocus(); // آخرین فیلد
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'ZORUNLU ALAN';
        if (isNumber && int.tryParse(value) == null) return 'GEÇERLİ SAYI GİRİN';
        return null;
      },
    );
  }
}
