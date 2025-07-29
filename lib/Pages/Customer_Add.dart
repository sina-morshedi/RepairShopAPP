import 'package:flutter/material.dart';
import '../DTO/CustomerDTO.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../backend_services/backend_services.dart';
import 'Components/helpers/app_helpers.dart';

class CustomerAdd extends StatefulWidget {
  const CustomerAdd({super.key});

  @override
  _CustomerAddState createState() => _CustomerAddState();
}

class _CustomerAddState extends State<CustomerAdd> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool isSaving = false;

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _saveCustomer() async {
    setState(() {
      isSaving = true;
    });

    final customer = CustomerDTO(
      fullName: _nameController.text.trim().toUpperCase(),
      phone: _phoneController.text.trim().toUpperCase(),
      nationalId: _nationalIdController.text.trim().toUpperCase(),
      address: _addressController.text.trim().toUpperCase(),
    );

    final response = await CustomerApi().insertCustomer(customer);

    setState(() {
      isSaving = false;
    });

    if (response.status == 'success') {
      StringHelper.showInfoDialog(context, "Müşteri bilgileri kaydedildi.");
    } else {
      StringHelper.showErrorDialog(context, response.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration("Ad Soyad", EvaIcons.personOutline),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Lütfen ad girin" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration("Telefon Numarası", EvaIcons.phoneOutline),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nationalIdController,
                    decoration: _inputDecoration("T.C. Kimlik No", EvaIcons.creditCardOutline),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: _inputDecoration("Adres", EvaIcons.homeOutline),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        _saveCustomer();
                      }
                    },
                    icon: const Icon(EvaIcons.saveOutline),
                    label: const Text("Müşteriyi Kaydet"),
                  ),
                ],
              ),
            ),
          ),
          if (isSaving) ...[
            ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.3)),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

