import 'dart:convert';
import 'dart:io';
import 'package:autonetwork/dboAPI.dart';
import 'package:autonetwork/type.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Showcarinfoapp extends StatefulWidget {
  const Showcarinfoapp({super.key});

  @override
  State<Showcarinfoapp> createState() => _ShowcarinfoappState();
}

class _ShowcarinfoappState extends State<Showcarinfoapp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final List<String> items = [
    'Kaydedilen tüm arabaları göster',
    'ŞASE NO',
    'PLAKA',
  ];
  final TextEditingController textController = TextEditingController();
  String? selectedItem;

  List<String> itemsList = [''];
  int? selectedIndex;
  List<Map<String, dynamic>> serverData = [];
  List<carInfo> carList = [];
  String resaultString = '';

  @override
  void initState() {
    super.initState();

    setState(() {
      selectedItem = items[0];
      itemsList.clear();
      serverData.clear();
    });
  }

  String toUpperIfAllLower(String input) {
    final isAllLower = RegExp(r'^[a-z]+$').hasMatch(input);

    if (isAllLower) {
      return input.toUpperCase();
    } else {
      return input;
    }
  }


  void showErrorDialog(
    BuildContext context,
    String errorMessage,
    String errorCode,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('HATA', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage),
            SizedBox(height: 12),
            Text(
              'HATA KODU: $errorCode',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void getCarInfo() async {
    Object result;

    if (selectedItem != items[0]) {
      String str = textController.text.trim();
      if (str.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$selectedItem: lütfen ekle",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (str.contains(' ')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "lütfen $selectedItem kutuya boşluk eklemeyin",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    dboAPI obj = dboAPI();
    if (selectedItem == items[0]) {
      ApiResponseDatabase<List<carInfo>> result = await obj.jobGetAllCarInfo();
      final car = result.data!;
      if (!result.hasError) {
        serverData.clear();
        itemsList.clear();
        carList.clear();
        carList = car;
        for (var item in car) {
          setState(() {
            // serverData.add({'license_plate': item.license_plate});
            itemsList.add(item.license_plate);
          });
        }
      }else {
        if (result.dbo_error != null)
          showErrorDialog(
            context,
            result.dbo_error!.message,
            result.dbo_error!.error_code,
          );
        else
          showErrorDialog(
            context,
            result.error!.message,
            result.error!.statusCode.toString(),
          );
      }
    } else {
      String str = '';
      if (selectedItem == 'ŞASE NO') str = 'chassis_no';
      if (selectedItem == 'PLAKA') str = 'license_plate';
      ApiResponseDatabase<carInfo> result = await obj.jobGetCarInfo(
        str,
        textController.text.trim().toUpperCase(),
      );

      if (!result.hasError) {
        final car = result.data!;
        carList = [car];
        setState(() {
          serverData.clear();
          serverData.add({'license_plate': car.license_plate});
          itemsList.clear();
          itemsList.add(car.license_plate);
        });
      } else {
        if (result.dbo_error != null)
          showErrorDialog(
            context,
            result.dbo_error!.message,
            result.dbo_error!.error_code,
          );
        else
          showErrorDialog(
            context,
            result.error!.message,
            result.error!.statusCode.toString(),
          );
      }
    }
  }

  // setState(() {
  //   serverData = data;
  //   itemsList.clear();
  //   for (var item in data) {
  //     if (item.containsKey('license_plate')) {
  //       // print("${item['license_plate'].toString()}");
  //       itemsList.add(item['license_plate'].toString());
  //     }
  //   }
  // });
  // if (data is List<Map<String, dynamic>>) {
  //   // Handle case where data is a list of maps (e.g., multiple errors)
  // } else if (data is Map<String, dynamic>) {
  //   final context = navigatorKey.currentState?.overlay?.context;
  //   if (context != null) {
  //     final String message = data['message'] ?? 'Unknown error';
  //     final int statusCode = data['statusCode'] ?? -1; // fallback if null
  //     showErrorDialog(context, message, statusCode.toString());
  //   }
  // }
  // else {
  //     // Context is not available, optionally handle this case silently or log it
  //   }

  @override
  Widget build(BuildContext context) {
    navigatorKey:
    navigatorKey;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/Logo.png', fit: BoxFit.cover),
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5F46AA),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: screenHeight * .05),
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: screenWidth * 0.9,
                  child: DropdownButtonFormField<String>(
                    value: selectedItem,
                    hint: Text('Seçili seçenek'),
                    items: items.map((item) {
                      return DropdownMenuItem(value: item, child: Text(item));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedItem = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * .03),
                SizedBox(
                  width: screenWidth * 0.9,
                  child: TextField(
                    controller: textController,
                    textCapitalization: TextCapitalization.characters,
                    enabled: selectedItem != items[0],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: selectedItem,
                      hintText: 'Değerinizi girin',
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * .03),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 13),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    height: screenHeight * 0.3,
                    child: ListView.builder(
                      itemCount: itemsList.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Ruhsat Bilgi'),
                                content: Text(carList[selectedIndex!].toPrettyString()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Kapat'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              itemsList[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * .03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.4,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5F46AA),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (selectedItem != null) getCarInfo();
                        },
                        child: Text('Ara'),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.4,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5F46AA),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedItem = items[0];
                            itemsList.clear();
                          });
                        },
                        child: Text('Sil'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
