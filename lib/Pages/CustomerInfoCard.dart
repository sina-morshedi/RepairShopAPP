import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../DTO/CustomerDTO.dart';

class CustomerInfoCard extends StatelessWidget {
  final CustomerDTO customer;
  final VoidCallback? onTap;
  final Widget? selectionWidget;

  const CustomerInfoCard({
    super.key,
    required this.customer,
    this.onTap,
    this.selectionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // متن سمت چپ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'Adı: ${customer.fullName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SelectableText('Telefon: ${customer.phone}'),
                    SelectableText('Adres: ${customer.address}'),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // آیکون ثابت مربوط به مشتری
              const Icon(
                EvaIcons.person,
                size: 40,
                color: Colors.blueGrey,
              ),

              // آیکون انتخابی، در صورت نیاز
              if (selectionWidget != null) ...[
                const SizedBox(width: 8),
                selectionWidget!,
              ]
            ],
          ),
        ),
      ),
    );
  }
}

/// کارت لیستی برای نمایش مجموعه‌ای از مشتری‌ها
class CustomerListCard extends StatelessWidget {
  final List<CustomerDTO> customers;
  final CustomerDTO? selectedCustomer;
  final Function(CustomerDTO)? onSelected;

  const CustomerListCard({
    super.key,
    required this.customers,
    this.selectedCustomer,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: customers.map((customer) {
        final isSelected = selectedCustomer != null && customer.id == selectedCustomer!.id;
        return CustomerInfoCard(
          customer: customer,
          onTap: onSelected != null ? () => onSelected!(customer) : null,
          selectionWidget: onSelected != null
              ? Icon(
            isSelected ? EvaIcons.checkmarkCircle2 : EvaIcons.radioButtonOff,
            color: isSelected ? Colors.green : Colors.grey,
            size: 28,
          )
              : null,
        );
      }).toList(),
    );
  }
}
