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
import 'GetCarInfoPage.dart';
import 'GetCarProblemPage.dart';
import 'package:autonetwork/Common.dart';
import '../backend_services/backend_services.dart';
import '../backend_services/ApiEndpoints.dart';

import 'package:autonetwork/utils/string_helper.dart';
import '../utils/utility.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  String user_name = '';
  String first_name = '';
  String last_name = '';
  String role_name = '';
  String permission_name = '';

  User? _user;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    _loadUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadUser() async {
    UserWithID? user = await UserPrefs.getUserWithID();
    dboAPI api = dboAPI();

    if (user != null && user.role != null && user.permission != null) {
      setState(() {
        first_name = user.FirstName;
        last_name = user.LastName;
        role_name = user.role!.RoleName;
        permission_name = user.permission!.PermissionName;

      });
    } else {
      debugPrint("user or one of its nested fields is null");
    }
  }

  Future<String> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Icon(Icons.person, size: 100, color: Colors.deepPurple),
                        SizedBox(height: 20),
                        Text('User Profile', style: TextStyle(fontSize: 22)),
                        SizedBox(height: 10),
                        Text(
                          'Ad: $first_name',
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        Text(
                          'Soyad: $last_name',
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        Text(
                          'Görev: $role_name',
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        Text(
                          'Yetki: $permission_name',
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                FutureBuilder<String>(
                  future: _getAppVersion(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    } else if (snapshot.hasError) {
                      return const Text('Failed to get version');
                    } else {
                      return Text(
                        '© 2025 Sina Morshedi - v${snapshot.data}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


