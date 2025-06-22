import 'package:flutter/material.dart';
import 'dart:convert';
import '../type.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import '../dboAPI.dart';
import '../DataFiles.dart';
import '../user_prefs.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:ffi' as ffi;
import 'dart:convert';                    // برای jsonDecode و jsonEncode
import 'package:http/http.dart' as http;


import '../type.dart';
import '../GetCarInfoPage.dart';
import '../GetCarProblemPage.dart';
import 'package:autonetwork/Common.dart';
import '../backend_services/backend_services.dart';
import '../backend_services/ApiEndpoints.dart';

import 'package:autonetwork/utils/string_helper.dart';
import '../utils/utility.dart';
import 'LoginPage.dart';
import 'UserProfilePage.dart';
import 'RegisterNewJobPage.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = const [
    UserProfilePage(),
    GetCarInfoPage(),
    GetCarProblemPage(),
    RegisterNewJobPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    // _loadAppVersion();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('loginTimestamp');
    //TODO For Login
    if (timestamp == null ||
        DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(timestamp))
            .inDays >=
            2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Image.asset(
          'assets/images/Logo.png',
          fit: BoxFit.cover,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 0, top: 0, bottom: 8),
            child: IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.redAccent, size: 40),
              onPressed: () async {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                );
              },
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: WaterDropNavBar(
        backgroundColor: Colors.white,
        waterDropColor: Colors.deepPurple,
        selectedIndex: _selectedIndex,
        onItemSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuad,
          );
        },
        barItems: [
          BarItem(filledIcon: Icons.person, outlinedIcon: Icons.person_outline),
          BarItem(filledIcon: Icons.directions_car, outlinedIcon: Icons.add_circle_outline),
          BarItem(filledIcon: Icons.list, outlinedIcon: Icons.list_alt_outlined),
          BarItem(filledIcon: Icons.build, outlinedIcon: Icons.build_outlined),
        ],
      ),
    );
  }

}