import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui';
import '../DataFiles.dart';
import 'user_prefs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

import '../DTO/UserProfileDTO.dart';
import '../backend_services/ApiEndpoints.dart';

import 'package:autonetwork/utils/string_helper.dart';
import '../utils/utility.dart';
import 'MainMenuPage.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  bool _isScanServerButtonEnabled = false;
  bool _isLoginButtonEnabled = true;
  String _appVersion = '';
  String ip = '';
  int port = 8000;
  bool isChecked = false;

  String? username;
  String? password;

  @override
  void initState() {
    super.initState();
    //TODO: For Json Delete File
    // deleteJsonFile();
    _checkStatus();
    _loadAppVersion();
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
    if (user != '') {
      _usernameController.text = user;
      _passwordController.text = pass;
      setState(() {
        isChecked = true;
      });
    } else {
      _usernameController.text = user;
      _passwordController.text = pass;
      setState(() {
        isChecked = false;
      });
    }

  }
  void _loginToWebServer() async{
    username = _usernameController.text;
    password = _passwordController.text;
    final String backendUrl =
        '${ApiEndpoints.login}?username=$username&password=$password';

    try {
      final response = await http.get(Uri.parse(backendUrl));


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userProfile = UserProfileDTO.fromJson(data);

        await UserPrefs.clearUserWithID();
        await UserPrefs.saveUserWithID(userProfile);
        await UserPrefs.saveLoginTimestamp();
        if (isChecked) {
          final storage = FlutterSecureStorage();
          await storage.write(key: 'username', value: username);
          await storage.write(key: 'password', value: password);
        } else {
          final storage = FlutterSecureStorage();
          await storage.delete(key: 'username');
          await storage.delete(key: 'password');
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



  Future<void> _showIPPortDialog() async {
    await _checkStatus();
    _ipController.text = ip;
    _portController.text = port.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter IP and Port"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _ipController,
                decoration: const InputDecoration(labelText: "IP Address"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _portController,
                decoration: const InputDecoration(labelText: "Port"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Confirm"),
              onPressed: () async {
                String ip = _ipController.text.trim();
                int port = int.parse(_portController.text.trim());

                if (isValidIPAddress(ip)) {
                  setState(() {
                    _isLoginButtonEnabled = true;
                  });

                  Map<String, dynamic> data = {
                    'serverIP': ip,
                    'serverPort': port,
                  };
                  await writeJsonToFile(data, fileType.serverConfig);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("IP: $ip - Port: $port")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter Valid IP")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
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
              '© 2025 Sina Morshedi - v$_appVersion',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}