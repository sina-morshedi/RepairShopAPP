import 'package:autonetwork/DTO/UserProfileDTO.dart';
import 'package:autonetwork/type.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';
import 'ManagerMenu.dart';
import 'RepairmanMenu.dart';
import 'user_prefs.dart';
import 'Dashboard.dart';
import 'InventoryForm.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  bool isRoleSelected = false;
  String selectedRole = "";
  UserProfileDTO? user;
  bool? _inventoryEnabled;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadUserProfileDTO();

  }

  void _loadUserProfileDTO() async {
    _inventoryEnabled = await UserPrefs.getInventoryEnabled();
    final loadedUser = await UserPrefs.getUserWithID();

    if (mounted) {
      setState(() {
        user = loadedUser;
      });
    }
  }


  void _onRoleSelected(String role) {
    setState(() {
      selectedRole = role;
      isRoleSelected = true;
    });
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

  Widget _buildRoleWidget() {
    switch (selectedRole) {
      case "dashboard":
        return Dashboard();
      case "manager":
        return ManagerMenu(selectedRole: selectedRole);
      case "inventory":
        return Inventoryform();
      case "secretary":
        return const Center(child: Text("Sekreter sayfası burada olacak"));
      case "technician":
        return RepairmanMenu(selectedRole: selectedRole);;
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRoleButton(BuildContext context, String title, IconData icon, String roleKey) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.6; // 60 درصد عرض صفحه

    return SizedBox(
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: () => _onRoleSelected(roleKey),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size.fromHeight(48),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
      ),
    );
  }


  Widget _buildRoleSelection() {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Widget> buttons = [];

    // اگر دسترسی مدیر دارد، همه دکمه‌ها را نشان بده
    if (user!.permission.permissionName.contains("Yönetici")) {
      buttons.add(_buildRoleButton(context, "Dashboard", Icons.dashboard, "dashboard"));
      buttons.add(const SizedBox(height: 20));
      if(_inventoryEnabled!){
        buttons.add(_buildRoleButton(context, "Yedek Parça", Icons.inventory, "inventory"));
        buttons.add(const SizedBox(height: 20));
      }
      buttons.add(_buildRoleButton(context, "Yönetici", Icons.admin_panel_settings, "manager"));
      buttons.add(const SizedBox(height: 20));
      buttons.add(_buildRoleButton(context, "Sekreter", Icons.person, "secretary"));
      buttons.add(const SizedBox(height: 20));
      buttons.add(_buildRoleButton(context, "Tamirci", Icons.build, "technician"));
    } else if (user!.permission.permissionName.contains("sekreter")) {
      buttons.add(_buildRoleButton(context, "Sekreter", Icons.person, "secretary"));
    } else if (user!.permission.permissionName.contains("Tamirci")) {
      buttons.add(_buildRoleButton(context, "Tamirci", Icons.build, "technician"));
    }

    if (buttons.isEmpty) {
      return const Center(child: Text("Herhangi bir yetkiniz yok"));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttons,
      ),
    );
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
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent, size: 40),
            onPressed: () async{
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: isRoleSelected
          ? Column(
        children: [
          AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  isRoleSelected = false;
                  selectedRole = "";
                });
              },
            ),
            title: Text(
                  selectedRole == "dashboard"
                  ? "Dashboard Menüsü"
                  : selectedRole == "inventory"
                  ? "Yedek Parça Menüsü"
                  : selectedRole == "manager"
                  ? "Yönetici Menüsü"
                  : selectedRole == "secretary"
                  ? "Sekreter Menüsü"
                  : "Tamirci Menüsü",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.deepPurple,
          ),
          Expanded(child: _buildRoleWidget()),
        ],
      )
          : _buildRoleSelection(),
    );
  }
}
