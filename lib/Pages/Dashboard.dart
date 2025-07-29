import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../DTO/CarInfoDTO.dart';
import '../backend_services/backend_services.dart';
import 'TaskFlowManager.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<TaskFlowManagerState> taskFlowKey = GlobalKey<TaskFlowManagerState>();


  void _onSearchSubmit(String value) {
    final query = value.trim().toUpperCase();

    taskFlowKey.currentState?.triggerSearch(query, context);

  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TypeAheadField<CarInfoDTO>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Plaka giriniz',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: _onSearchSubmit,
              ),
              suggestionsCallback: (pattern) async {
                if (pattern.trim().isEmpty) return [];
                final response = await CarInfoApi().searchCarsByLicensePlateKeyword(pattern);
                if (response.status == 'success' && response.data != null) {
                  return response.data!;
                }
                return [];
              },
              itemBuilder: (context, CarInfoDTO suggestion) {
                return ListTile(
                  title: Text(suggestion.licensePlate ?? ''),
                  subtitle: suggestion.brandModel != null ? Text(suggestion.brandModel!) : null,
                );
              },
              onSuggestionSelected: (CarInfoDTO suggestion) {
                _searchController.text = suggestion.licensePlate ?? '';
                _onSearchSubmit(suggestion.licensePlate ?? '');
              },
              noItemsFoundBuilder: (context) => const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Eşleşen araç bulunamadı'),
              ),
            ),
            const SizedBox(height: 20),
            // اضافه کردن TaskFlowManager اینجا:
            Expanded(
              child: TaskFlowManager(
                key: taskFlowKey,  // مهم: کلید را اینجا به ویجت بدهید
              ),
            ),
          ],
        ),
      ),
    );
  }
}
