import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui';
import '../DataFiles.dart';
import 'user_prefs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';


import '../DTO/UserProfileDTO.dart';
import '../backend_services/ApiEndpoints.dart';

import 'package:autonetwork/utils/string_helper.dart';
import 'package:get_storage/get_storage.dart';
import 'MainMenuPage.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storeNameController = TextEditingController();

  bool _isLoginButtonEnabled = true;
  String _appVersion = '';
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    //TODO: For Json Delete File
    // deleteJsonFile();
    _checkStatus();
    _loadAppVersion();
  }

  @override
  void dispose() {
    // برای جلوگیری از نشت حافظه، کنترلرها را dispose کنید
    _usernameController.dispose();
    _passwordController.dispose();
    _storeNameController.dispose();
    super.dispose();
  }

  void _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
    });
  }

  Future<void> _checkStatus() async {
    final storage = FlutterSecureStorage();
    final user = await storage.read(key: 'username') ?? '';
    final pass = await storage.read(key: 'password') ?? '';
    final storeName = await storage.read(key: 'storeName') ?? '';
    if (user != '') {
      _usernameController.text = user;
      _passwordController.text = pass;
      _storeNameController.text = storeName;
      setState(() {
        isChecked = true;
      });
    } else {
      _usernameController.text = user;
      _passwordController.text = pass;
      _storeNameController.text = storeName;
      setState(() {
        isChecked = false;
      });
    }

  }
  void _loginToWebServer() async{
    String username = _usernameController.text;
    String password = _passwordController.text;
    String storeName = _storeNameController.text;
    final String backendUrl =
        '${ApiEndpoints.login}?username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}&storeName=${Uri.encodeComponent(storeName)}';


    try {
      final response = await http.get(Uri.parse(backendUrl));


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        Map<String, dynamic> payload = JwtDecoder.decode(token);
        bool inventoryEnabled = payload['inventoryEnabled'] ?? false;
        bool customerEnabled = payload['customerEnabled'] ?? false;

        final box = GetStorage();
        box.write('token', token);


        final userProfile = UserProfileDTO.fromJson(data['profile']);
        await UserPrefs.clearUserWithID();
        await UserPrefs.saveInventoryEnabled(inventoryEnabled);
        await UserPrefs.saveCustomerEnabled(customerEnabled);
        await UserPrefs.saveStoreName(storeName);
        await UserPrefs.saveUserWithID(userProfile);
        await UserPrefs.saveLoginTimestamp();
        if (isChecked) {
          final storage = FlutterSecureStorage();
          await storage.write(key: 'username', value: username);
          await storage.write(key: 'password', value: password);
          await storage.write(key: 'storeName', value: storeName);
        } else {
          final storage = FlutterSecureStorage();
          await storage.delete(key: 'username');
          await storage.delete(key: 'password');
          await storage.delete(key: 'storeName');
        }
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainMenuPage()),
        );
      } else {
        StringHelper.showErrorDialog(context, response.body);
      }
    } catch (e) {
      StringHelper.showErrorDialog(context, 'Error: ${e.toString()}');
    }


  }


  @override
  Widget build(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Color(0xFF5F46AA);
      }
      return Colors.lightBlue;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/Logo.png', fit: BoxFit.cover),
            AppBar(backgroundColor: Colors.transparent, elevation: 0),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sistem Girişi',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _storeNameController,
              decoration: InputDecoration(
                labelText: 'TamirgahName',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isChecked = newValue ?? false;
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith(getColor),
                      ),
                      const Expanded(
                        child: Text(
                          'Kullanıcı Adı ve Şifreyi Kaydet',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoginButtonEnabled ? _loginToWebServer : null,
                child: Text('Giriş'),
              ),
            ),
            SizedBox(height: 15),

            SizedBox(height: 30),
            Text(
              '© 2025 Sina Morshedi - v$_appVersion'
             +'      sina.morshedi@gmail.com      ',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}