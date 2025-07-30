import 'package:flutter/material.dart';
import '../DTO/InventoryItemDTO.dart';
import '../backend_services/backend_services.dart';
import '../utils/string_helper.dart';

class PartSearchWidget extends StatefulWidget {
  final Function(InventoryItemDTO selectedPart) onPartSelected;

  const PartSearchWidget({Key? key, required this.onPartSelected}) : super(key: key);

  @override
  State<PartSearchWidget> createState() => _PartSearchWidgetState();
}

class _PartSearchWidgetState extends State<PartSearchWidget> {
  final TextEditingController _partSearchController = TextEditingController();
  late VoidCallback _partListener;
  List<InventoryItemDTO> partSearchResults = [];
  InventoryItemDTO? selectedPart;

  @override
  void initState() {
    super.initState();

    _partListener = () {
      final keyword = _partSearchController.text.trim();
      if (keyword.length < 2) {
        setState(() {
          partSearchResults = [];
          selectedPart = null;
        });
        return;
      }
      _searchParts(keyword);
    };

    _partSearchController.addListener(_partListener);
  }

  Future<void> _searchParts(String keyword) async {
    final response = await InventoryApi().getByPartName(keyword.toUpperCase());
    if (response.status == 'success') {
      setState(() {
        partSearchResults = response.data!;
      });
    } else {
      setState(() {
        partSearchResults = [];
      });
      StringHelper.showErrorDialog(context, response.message ?? "Parça bulunamadı");
    }
  }

  @override
  void dispose() {
    _partSearchController.removeListener(_partListener);
    _partSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _partSearchController,
          decoration: InputDecoration(
            labelText: 'Parça Adı Ara',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
        ),
        const SizedBox(height: 8),
        if (partSearchResults.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: partSearchResults.length,
            itemBuilder: (context, index) {
              final part = partSearchResults[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                child: ListTile(
                  title: Text(part.partName ?? 'İsimsiz Parça'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Barkod: ${part.barcode ?? '---'}'),
                      Text('Stok Miktarı: ${part.quantity ?? 0}'),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      selectedPart = part;
                      _partSearchController.text = part.partName ?? '';
                      partSearchResults.clear();
                    });
                    widget.onPartSelected(part);
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
