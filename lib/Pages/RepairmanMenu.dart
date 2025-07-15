import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'GetCarInfoPage.dart';
import 'TroubleshootingForm.dart';

import 'LoginPage.dart';
import 'UserProfilePage.dart';
import 'WorkespacePage.dart';

class RepairmanMenu extends StatefulWidget {
  final String selectedRole;
  const RepairmanMenu({super.key, required this.selectedRole});

  @override
  State<RepairmanMenu> createState() => _RepairmanMenuState();
}

class _RepairmanMenuState extends State<RepairmanMenu> {
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
      UserProfilePage(key: _userProfileKey),
      const GetCarInfoPage(),
      const TroubleshootingForm(),
      WorkespacePage(),
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
          BarItem(filledIcon: Icons.person, outlinedIcon: Icons.person_outline),
          BarItem(filledIcon: Icons.directions_car, outlinedIcon: Icons.add_circle_outline),
          BarItem(filledIcon: Icons.list, outlinedIcon: Icons.list_alt_outlined),
          BarItem(filledIcon: Icons.build, outlinedIcon: Icons.build_outlined),
        ],
      ),
    );
  }
}
