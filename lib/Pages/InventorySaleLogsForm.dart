import 'package:flutter/material.dart';
import '../backend_services/backend_services.dart';
import '../DTO/InventorySaleLogDTO.dart';
import '../DTO/CustomerDTO.dart';
import '../Pages/Components/helpers/app_helpers.dart';
import 'InventorySaleLogCard.dart';

class InventorySaleLogsForm extends StatefulWidget {
  const InventorySaleLogsForm({super.key});

  @override
  State<InventorySaleLogsForm> createState() => _InventorySaleLogsFormState();
}

class _InventorySaleLogsFormState extends State<InventorySaleLogsForm> {
  final TextEditingController _remainingCustomerController = TextEditingController();

  List<CustomerDTO> customerSearchResults = [];
  CustomerDTO? selectedCustomer;

  List<InventorySaleLogDTO> customerSaleLogs = [];
  bool isLoadingSaleLogs = false;

  bool _allLogsSelected = true;
  bool _remainingZeroSelected = false;
  bool _remainingNonZeroSelected = false;

  late VoidCallback _remainingCustomerListener;

  @override
  void initState() {
    super.initState();

    _remainingCustomerListener = () {
      final keyword = _remainingCustomerController.text.trim();
      if (keyword.length < 2) {
        setState(() {
          customerSearchResults = [];
          selectedCustomer = null;
          customerSaleLogs = [];
        });
        return;
      }
      _searchCustomers(keyword);
    };

    _remainingCustomerController.addListener(_remainingCustomerListener);
    _fetchAllSaleLogs();
  }

  @override
  void dispose() {
    _remainingCustomerController.removeListener(_remainingCustomerListener);
    _remainingCustomerController.dispose();
    super.dispose();
  }

  void _onAllLogsChanged(bool? val) {
    setState(() {
      _allLogsSelected = val ?? false;
      if (_allLogsSelected) {
        _remainingZeroSelected = false;
        _remainingNonZeroSelected = false;
        _remainingCustomerController.clear();
        customerSearchResults.clear();
        selectedCustomer = null;
        customerSaleLogs = [];
        _fetchAllSaleLogs();
      }
    });
  }

  void _onRemainingZeroChanged(bool? val) {
    setState(() {
      _remainingZeroSelected = val ?? false;
      if (_remainingZeroSelected) {
        _allLogsSelected = false;
        _remainingNonZeroSelected = false;
        _remainingCustomerController.clear();
        customerSearchResults.clear();
        selectedCustomer = null;
        customerSaleLogs = [];
        _fetchSaleLogsWithNonRemainingZero();
      }
    });
  }

  void _onRemainingNonZeroChanged(bool? val) {
    setState(() {
      _remainingNonZeroSelected = val ?? false;
      if (_remainingNonZeroSelected) {
        _allLogsSelected = false;
        _remainingZeroSelected = false;
        customerSaleLogs = [];
        selectedCustomer = null;
        _remainingCustomerController.clear();
        customerSearchResults.clear();
      } else {
        _remainingCustomerController.clear();
        customerSearchResults.clear();
        selectedCustomer = null;
        customerSaleLogs = [];
      }
    });
  }

  Future<void> _searchCustomers(String keyword) async {
    final response = await CustomerApi().searchCustomerByName(keyword.toUpperCase());
    if (response.status == 'success' && response.data != null) {
      setState(() {
        customerSearchResults = response.data!;
      });
    } else {
      setState(() {
        customerSearchResults = [];
      });
    }
  }

  Future<void> _fetchAllSaleLogs() async {
    setState(() {
      isLoadingSaleLogs = true;
    });
    final response = await InventorySaleLogApi().getAllSaleLogs();
    if (response.status == 'success' && response.data != null) {
      setState(() {
        customerSaleLogs = response.data!;
      });
    } else {
      setState(() {
        customerSaleLogs = [];
      });
      if (response.message != null) {
        StringHelper.showErrorDialog(context, response.message!);
      }
    }
    setState(() {
      isLoadingSaleLogs = false;
    });
  }

  Future<void> _fetchSaleLogsWithNonRemainingZero() async {
    setState(() {
      isLoadingSaleLogs = true;
    });
    final response = await InventorySaleLogApi().getSaleLogsWithNonZeroRemaining();
    if (response.status == 'success' && response.data != null) {
      setState(() {
        customerSaleLogs = response.data!;
        print('customerSaleLogs');
        print(customerSaleLogs);
      });
    } else {
      setState(() {
        customerSaleLogs = [];
      });
      if (response.message != null) {
        StringHelper.showErrorDialog(context, response.message!);
      }
    }
    setState(() {
      isLoadingSaleLogs = false;
    });
  }

  Future<void> _fetchSaleLogsWithRemainingNonZeroByCustomer(String customerName) async {
    setState(() {
      isLoadingSaleLogs = true;
    });
    final response = await InventorySaleLogApi().searchByCustomerName(customerName);
    if (response.status == 'success' && response.data != null) {
      setState(() {
        customerSaleLogs = response.data!;
      });
    } else {
      setState(() {
        customerSaleLogs = [];
      });
      if (response.message != null) {
        StringHelper.showErrorDialog(context, response.message!);
      }
    }
    setState(() {
      isLoadingSaleLogs = false;
    });
  }

  void _onCustomerSelected(CustomerDTO customer) {
    setState(() {
      selectedCustomer = customer;

      _remainingCustomerController.removeListener(_remainingCustomerListener);
      _remainingCustomerController.text = customer.fullName;
      _remainingCustomerController.addListener(_remainingCustomerListener);

      customerSearchResults.clear();
    });

    _fetchSaleLogsWithRemainingNonZeroByCustomer(customer.fullName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: const Text('Tüm Kayıtlar'),
                        value: _allLogsSelected,
                        onChanged: _onAllLogsChanged,
                        controlAffinity: ListTileControlAffinity.leading,
                        visualDensity: VisualDensity.compact,
                      ),
                      CheckboxListTile(
                        title: const Text('Ödenmemiş'),
                        value: _remainingZeroSelected,
                        onChanged: _onRemainingZeroChanged,
                        controlAffinity: ListTileControlAffinity.leading,
                        visualDensity: VisualDensity.compact,
                      ),
                      CheckboxListTile(
                        title: const Text('İsme Göre Ara'),
                        value: _remainingNonZeroSelected,
                        onChanged: _onRemainingNonZeroChanged,
                        controlAffinity: ListTileControlAffinity.leading,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),

                if (_remainingNonZeroSelected) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _remainingCustomerController,
                    decoration: const InputDecoration(
                      labelText: 'Müşteri Ara',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (customerSearchResults.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: customerSearchResults.length,
                        itemBuilder: (context, index) {
                          final customer = customerSearchResults[index];
                          return ListTile(
                            title: Text(customer.fullName),
                            subtitle: Text(customer.phone ?? ''),
                            onTap: () => _onCustomerSelected(customer),
                          );
                        },
                      ),
                    ),
                ],

                const SizedBox(height: 16),

                if (isLoadingSaleLogs)
                  const Center(child: CircularProgressIndicator())
                else if (customerSaleLogs.isEmpty)
                  SizedBox(
                    height: 200,
                    child: const Center(child: Text('Kayıt bulunamadı.')),
                  )
                else
                  Container(
                    height: 300,  // یا هر ارتفاع دلخواه متناسب با صفحه
                    child: ListView.builder(
                      itemCount: customerSaleLogs.length,
                      itemBuilder: (context, index) {
                        final log = customerSaleLogs[index];
                        return InventorySaleLogDetailCard(
                          customerId: selectedCustomer?.id ?? '',
                          log: log,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
