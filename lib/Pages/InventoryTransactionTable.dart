import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../DTO/InventoryTransactionResponseDTO.dart';
import '../backend_services/backend_services.dart';
import '../Pages/Components/helpers/app_helpers.dart';
import '../DTO/InventoryTransactionType.dart';
import '../backend_services/ApiEndpoints.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class InventoryTransactionsTable extends StatefulWidget {
  final List<InventoryTransactionResponseDTO>? transactions;
  final bool showDeleteIcon;
  final void Function(InventoryTransactionResponseDTO)? onDelete;

  const InventoryTransactionsTable({
    super.key,
    this.transactions,
    this.showDeleteIcon = false,
    this.onDelete,
  });

  @override
  _InventoryTransactionsTableState createState() =>
      _InventoryTransactionsTableState();
}

class _InventoryTransactionsTableState
    extends State<InventoryTransactionsTable> {
  late List<InventoryTransactionResponseDTO> transactions;
  PagedApiResponse<InventoryTransactionResponseDTO>? pagedResponse;

  bool _loading = false;
  DateTime? startDate;
  DateTime? endDate;

  int currentPage = 0;
  final int pageSize = 9;

  int totalCount = 0;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.transactions != null) {
      transactions = widget.transactions!;
      totalCount = transactions.length;
    } else {
      transactions = [];
      fetchTransactions();
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  String _formatDateTimeToIstanbul(DateTime utcDateTime) {
    final istanbul = tz.getLocation('Europe/Istanbul');
    final localDate = tz.TZDateTime.from(utcDateTime.toUtc(), istanbul);
    return DateFormat('yyyy-MM-dd HH:mm').format(localDate);
  }

  Future<void> fetchTotalCount() async {

    String? startDateStr;
    String? endDateStr;

    if(startDate != null && endDate != null){
      startDateStr = _formatDateForBackend(startDate!, isStart: true);
      endDateStr = _formatDateForBackend(endDate!, isStart: false);
    }

    final response = (startDate != null && endDate != null) ?
    await InventoryTransactionApi().getTransactionsByDateRangeCount(
      startDate: startDateStr!,
      endDate: endDateStr!):
    await InventoryTransactionApi().getAllTransactionsCount();

    if (response.status == 'success' && response.data != null) {
      totalCount = response.data!;
    } else {
      totalCount = 0;
    }
  }

  Future<void> fetchTransactions() async {
    setState(() => _loading = true);

    await fetchTotalCount();

    ApiResponse<List<InventoryTransactionResponseDTO>> response;

    if (startDate != null && endDate != null) {
      final startDateStr = _formatDateForBackend(startDate!, isStart: true);
      final endDateStr = _formatDateForBackend(endDate!, isStart: false);

      response = await InventoryTransactionApi().getTransactionsByDateRangePaginated(
        startDate: startDateStr,
        endDate: endDateStr,
        page: currentPage,
        size: pageSize,
      );
    } else {
      response = await InventoryTransactionApi().getTransactionsPaged(
        page: currentPage,
        size: pageSize,
      );
    }

    if (response.status == 'success') {
      setState(() {
        transactions = response.data ?? [];
      });
    } else {
      StringHelper.showErrorDialog(
        context,
        response.message ?? 'Bilinmeyen hata',
      );
    }

    setState(() => _loading = false);
  }

  String _formatDateForBackend(DateTime date, {bool isStart = true}) {
    final dt = isStart
        ? DateTime(date.year, date.month, date.day, 0, 0, 0)
        : DateTime(date.year, date.month, date.day, 23, 59, 59);
    return dt.toUtc().toIso8601String();
  }

  Future<void> _pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: endDate ?? DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        _startDateController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
        _endDateController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _resetFilters() {
    setState(() {
      startDate = null;
      endDate = null;
      currentPage = 0;
      _startDateController.clear();
      _endDateController.clear();
    });
    fetchTransactions();
  }

  void _nextPage() {
    setState(() {
      currentPage++;
    });
    fetchTransactions();
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
      fetchTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalCount / pageSize).ceil();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // فیلترها
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickStartDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _startDateController,
                            decoration: InputDecoration(
                              labelText: 'Start Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickEndDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _endDateController,
                            decoration: InputDecoration(
                              labelText: 'End Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentPage = 0;
                        });
                        fetchTransactions();
                      },
                      child: const Text('Ara'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _resetFilters,
                      child: const Text('Sıfırla'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),


          const SizedBox(height: 16),

          // جدول با اسکرول افقی
          SizedBox(
            height: 500,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                ? const Center(child: Text("Hiç işlem bulunamadı."))
                : GestureDetector(
              onHorizontalDragUpdate: (details) {
                final newOffset =
                    _horizontalScrollController.offset - details.delta.dx;
                if (newOffset < 0) {
                  _horizontalScrollController.jumpTo(0);
                } else if (newOffset >
                    _horizontalScrollController.position.maxScrollExtent) {
                  _horizontalScrollController
                      .jumpTo(_horizontalScrollController.position.maxScrollExtent);
                } else {
                  _horizontalScrollController.jumpTo(newOffset);
                }
              },
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1200,
                  child: DataTable(
                    columns: [
                      if (widget.showDeleteIcon)
                        const DataColumn(label: Text('')),
                      const DataColumn(label: Text('Tarih')),
                      const DataColumn(label: Text('Tür')),
                      const DataColumn(label: Text('Parça')),
                      const DataColumn(label: Text('Adet')),
                      const DataColumn(label: Text('Kullanıcı')),
                      const DataColumn(label: Text('Açıklama')),
                      const DataColumn(label: Text('Plaka')),
                      const DataColumn(label: Text('Müşteri')),
                    ],
                    rows: transactions.map((transaction) {
                      final cells = <DataCell>[];

                      if (widget.showDeleteIcon) {
                        cells.add(
                          DataCell(
                            IconButton(
                              icon: Icon(MdiIcons.delete, color: Colors.red),
                              onPressed: () {
                                if (widget.onDelete != null) {
                                  widget.onDelete!(transaction);
                                }
                              },
                            ),
                          ),
                        );
                      }

                      cells.addAll([
                        DataCell(Text(transaction.dateTime != null
                            ? _formatDateTimeToIstanbul(transaction.dateTime!)
                            : '-')),
                        DataCell(Text(transactionTypeToString(transaction.type) ?? '-')),
                        DataCell(Text(transaction.inventoryItem?.partName ?? '-')),
                        DataCell(Text(transaction.quantity.toString())),
                        DataCell(Text(transaction.creatorUser?.firstName ?? '-')),
                        DataCell(Text(transaction.description ?? '-')),
                        DataCell(Text(transaction.carInfo?.licensePlate ?? '-')),
                        DataCell(Text(transaction.customer?.fullName ?? '-')),
                      ]);

                      return DataRow(cells: cells);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // دکمه‌های صفحه‌بندی و نمایش شماره صفحه
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: currentPage > 0 ? _previousPage : null,
                child: const Text('Önceki'),
              ),
              const SizedBox(width: 16),
              Text('Page ${currentPage + 1} of $totalPages'),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: (currentPage+1) != totalPages ? _nextPage : null,
                child: const Text('Sonraki'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
