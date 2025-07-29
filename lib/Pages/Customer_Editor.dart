import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../DTO/CustomerDTO.dart';
import '../backend_services/backend_services.dart';
import 'Components/helpers/app_helpers.dart';

class CustomerEditor extends StatefulWidget {
  const CustomerEditor({super.key});

  @override
  State<CustomerEditor> createState() => _CustomerEditorState();
}

class _CustomerEditorState extends State<CustomerEditor> {
  List<CustomerDTO> customerList = [];

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    final response = await CustomerApi().getAllCustomers();
    if (response.status == 'success' && response.data != null) {
      setState(() => customerList = response.data!);
    } else {
      StringHelper.showErrorDialog(context, "Müşteri listesi alınamadı: ${response.message}");
    }
  }

  Future<void> deleteCustomer(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Silme Onayı'),
        content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hayır')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Evet')),
        ],
      ),
    );
    if (confirm == true) {
      final response = await CustomerApi().deleteCustomer(id);
      if (response.status == 'success') {
        StringHelper.showInfoDialog(context, "${response.message}");
        fetchCustomers();
      } else {
        StringHelper.showErrorDialog(context, "Silme hatası: ${response.message}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: customerList.length,
      itemBuilder: (context, index) {
        final customer = customerList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const Icon(EvaIcons.personOutline, color: Colors.blueAccent),
            title: Text(customer.fullName),
            subtitle: Text(customer.address ?? '-'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(customer.phone ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(EvaIcons.edit2Outline, color: Colors.blue),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => EditCustomerDialog(customer: customer, onUpdated: fetchCustomers),
                  ),
                ),
                IconButton(
                  icon: const Icon(EvaIcons.trash2Outline, color: Colors.red),
                  onPressed: () => deleteCustomer(customer.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EditCustomerDialog extends StatefulWidget {
  final CustomerDTO customer;
  final VoidCallback onUpdated;

  const EditCustomerDialog({Key? key, required this.customer, required this.onUpdated}) : super(key: key);

  @override
  State<EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<EditCustomerDialog> {
  bool isSaving = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _nationalIdController;
  late TextEditingController _addressController;

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.fullName);
    _phoneController = TextEditingController(text: widget.customer.phone);
    _nationalIdController = TextEditingController(text: widget.customer.nationalId);
    _addressController = TextEditingController(text: widget.customer.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    final updatedCustomer = CustomerDTO(
      id: widget.customer.id,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      address: _addressController.text.trim(),
    );

    final response = await CustomerApi().updateCustomer(updatedCustomer);

    if (mounted) {
      setState(() {
        isSaving = false;
      });

      if (response.status == 'success') {
        StringHelper.showInfoDialog(context, "Müşteri güncellendi");
        widget.onUpdated();
        Navigator.pop(context);
      } else {
        StringHelper.showErrorDialog(context, "Güncelleme hatası: ${response.message}");
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 500, // یا هر ارتفاع مناسب برای دیالوگ شما
            maxWidth: 600,
          ),
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                // محتوای اصلی فرم
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Müşteri Bilgilerini Güncelle",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("İptal"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: isSaving ? null : _updateCustomer,
                            child: const Text("Güncelle"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // اگر در حالت ذخیره‌سازی است، روی بقیه ویجت‌ها لایه می‌اندازد
                if (isSaving) ...[
                  ModalBarrier(
                    dismissible: false,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

}
