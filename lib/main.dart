import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import 'dboAPI.dart';
import 'DataFiles.dart';
import 'user_prefs.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:ffi' as ffi;
import 'dart:convert';                    // برای jsonDecode و jsonEncode
import 'package:http/http.dart' as http;


import 'type.dart';
import 'GetCarInfoPage.dart';
import 'GetCarProblemPage.dart';
import 'package:autonetwork/Common.dart';
import 'backend_services/backend_services.dart';
import 'backend_services/ApiEndpoints.dart';

import 'package:autonetwork/utils/string_helper.dart';
import 'utils/utility.dart';
import 'Pages/LoginPage.dart';
import 'Pages/MainMenuPage.dart';

void main() {
  runApp(const AutoNetworkApp());
}

class AutoNetworkApp extends StatelessWidget {
  const AutoNetworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoNetwork',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const MainMenuPage(),
    );
  }
}
