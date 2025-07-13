import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'GetCarProblemPage-Backup.dart';

import 'LoginPage.dart';
import 'UserProfilePage.dart';
import 'WorkespacePage.dart';
import 'ProjectManageForm.dart';
import 'InvoiceForm.dart';
import 'ReportsForm.dart';
import 'SettingsForm.dart';

class ManagerMenu extends StatefulWidget {
  final String selectedRole;
  const ManagerMenu({super.key, required this.selectedRole});

  @override
  State<ManagerMenu> createState() => _ManagerMenuState();
}

class _ManagerMenuState extends State<ManagerMenu> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final GlobalKey<UserProfilePageState> _userProfileKey = GlobalKey<UserProfilePageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _checkLoginStatus();

    _pages = [
      ProjectmanageForm(),
      InvoiceForm(),
      ReportsForm(),
      SettingsForm(),
    ];
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('loginTimestamp');
    if (timestamp == null ||
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp)).inHours >= 20) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            _userProfileKey.currentState?.reloadUserData();
          }
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
          if (index == 0) {
            _userProfileKey.currentState?.reloadUserData();
          }
        },
        barItems: [
          BarItem(filledIcon: Icons.assignment,outlinedIcon: Icons.assignment_outlined),
          BarItem(filledIcon: Icons.receipt_long,outlinedIcon: Icons.receipt_long_outlined),
          BarItem(filledIcon: Icons.list, outlinedIcon: Icons.list_alt_outlined),
          BarItem(filledIcon: Icons.settings,outlinedIcon: Icons.settings_outlined)

        ],
      ),
    );
  }
}
