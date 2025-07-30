import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../DTO/InventoryItemDTO.dart';
import '../backend_services/backend_services.dart';
import '../utils/string_helper.dart';

class InventoryItemsTable extends StatefulWidget {
  final List<InventoryItemDTO>? items;
  final bool showDeleteIcon; // اضافه شد
  final void Function(InventoryItemDTO)? onDelete; // کال‌بک حذف اختیاری

  const InventoryItemsTable({
    super.key,
    this.items,
    this.showDeleteIcon = false, // مقدار پیش‌فرض false
    this.onDelete,
  });

  @override
  _InventoryItemsTableState createState() => _InventoryItemsTableState();
}

class _InventoryItemsTableState extends State<InventoryItemsTable> {
  late List<InventoryItemDTO> items;
  bool _loading = false;

  int _currentPage = 0;
  int _pageSize = 9;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    if (widget.items != null) {
      items = widget.items!;
      _totalPages = 1; // اگر از بیرون آمد، فرض کنیم 1 صفحه است
    } else {
      items = [];
      fetchItems(page: 0);
    }
  }

  Future<void> fetchItems({required int page}) async {
    setState(() => _loading = true);
    final response = await InventoryApi().getPagedItems(page, _pageSize);

    if (response.status == 'success') {
      setState(() {
        items = response.data?.content ?? [];
        _currentPage = page;
        _totalPages = response.data?.totalPages ?? 1;
      });
    } else {
      StringHelper.showErrorDialog(
          context, response.message ?? 'Bilinmeyen hata');
    }

    setState(() => _loading = false);
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      fetchItems(page: _currentPage - 1);
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      fetchItems(page: _currentPage + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return const Center(child: Text("Hiç parça bulunamadı."));
    }

    return SingleChildScrollView(   // اضافه شده: اسکرول عمودی کل جدول
      child: Column(
        children: [
          SizedBox(
            height: 500,

              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    if (widget.showDeleteIcon)
                      const DataColumn(label: Text('')),
                    const DataColumn(label: Text('Parça Adı')),
                    const DataColumn(label: Text('Barkod')),
                    const DataColumn(label: Text('Kategori')),
                    const DataColumn(label: Text('Miktar')),
                    const DataColumn(label: Text('Birim')),
                    const DataColumn(label: Text('Konum')),
                    const DataColumn(label: Text('Aktif')),
                  ],
                  rows: items.map((item) {
                    final cells = <DataCell>[];

                    if (widget.showDeleteIcon) {
                      cells.add(
                        DataCell(
                          IconButton(
                            icon: Icon(MdiIcons.delete, color: Colors.red),
                            onPressed: () {
                              if (widget.onDelete != null) {
                                widget.onDelete!(item);
                              }
                            },
                          ),
                        ),
                      );
                    }

                    cells.addAll([
                      DataCell(Row(
                        children: [
                          Icon(MdiIcons.cogOutline, size: 16),
                          const SizedBox(width: 6),
                          SelectableText(item.partName),
                        ],
                      )),
                      DataCell(Row(
                        children: [
                          Icon(MdiIcons.barcode, size: 16),
                          const SizedBox(width: 6),
                          SelectableText(item.barcode),
                        ],
                      )),
                      DataCell(Row(
                        children: [
                          Icon(MdiIcons.shapeOutline, size: 16),
                          const SizedBox(width: 6),
                          SelectableText(item.category),
                        ],
                      )),
                      DataCell(SelectableText(item.quantity?.toString() ?? '-')),
                      DataCell(SelectableText(item.unit)),
                      DataCell(Row(
                        children: [
                          Icon(MdiIcons.mapMarker, size: 16),
                          const SizedBox(width: 6),
                          SelectableText(item.location),
                        ],
                      )),
                      DataCell(
                        Icon(
                          item.isActive == true
                              ? MdiIcons.checkCircleOutline
                              : MdiIcons.closeCircleOutline,
                          color: item.isActive == true ? Colors.green : Colors.red,
                        ),
                      ),
                    ]);

                    return DataRow(cells: cells);
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _currentPage == 0 ? null : _goToPreviousPage,
                child: const Text('Önceki'),
              ),
              const SizedBox(width: 16),
              Text('Sayfa ${_currentPage + 1} / $_totalPages'),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _currentPage >= _totalPages - 1 ? null : _goToNextPage,
                child: const Text('Sonraki'),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
