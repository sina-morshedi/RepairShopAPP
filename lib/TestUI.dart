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
import 'package:animations/animations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:ui';
import 'dart:ffi' as ffi;

import 'type.dart';
import 'package:autonetwork/TroubleshootingApp.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'Pages/GetCarInfoPage.dart';
import 'Pages/GetCarProblemPage.dart';
import 'ShowCarInfoApp.dart';
import 'GetCarProblemApp.dart';
import 'EditCarIinfoApp.dart';
import 'package:autonetwork/Common.dart';

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

// ----------------- Pages -----------------
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
  bool _isLoginButtonEnabled = false;
  String _appVersion = '';
  String ip = '';
  int port = 8000;
  bool isChecked = false;
  bool isMQTTChecked = false;
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
    Map<String, dynamic>? data = await readJsonFromFile(fileType.serverConfig);
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
    if (data != null) {
      _isLoginButtonEnabled = true;
      setState(() {
        ip = data['serverIP'];
        port = data['serverPort'];
      });
    } else {
      ip = '';
      port = 8000;
      _ipController.text = ip;
      _portController.text = port.toString();
    }

    GeneralConfig? cfg = await UserPrefs.getGeneralConfig();
    if(cfg != null){
      if(cfg.MqttConnection == true){
        setState(() {
          isMQTTChecked = true;
        });
      }else{
        setState(() {
          isMQTTChecked = false;
        });
      }
    }
  }

  void _login() async {
    username = _usernameController.text;
    password = _passwordController.text;

    if ((username ?? '').isEmpty || (password ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen kullanıcı adı ve şifreyi girin')),
      );
      return;
    }
    dboAPI obj = dboAPI();
    Map<String, dynamic>? data = await readJsonFromFile(fileType.serverConfig);
    if (data != null && data.containsKey('serverIP')) {
      dboAPI.serverIP = data['serverIP'];
      if (await obj.ping(data['serverIP'], data['serverPort'])) {
        setState(() {
          _isScanServerButtonEnabled = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Server is RUN',
              style: TextStyle(color: Colors.green),
            ),
          ),
        );
        try {
          ApiResponseDatabase<UserWithID> result = await obj.jobFetchUserWithID(
            username ?? '',
          );
          if (result.hasError) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Hata", style: TextStyle(color: Colors.red)),
                  content: Text("Kullanıcı adı veya şifre yanlış"),
                  actions: [
                    TextButton(
                      child: Text("Tamam"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            final user = result.data!;
            bool isValid = BCrypt.checkpw(
              password ?? '',
              user.userPass!.password,
            );
            if (isValid) {
              //TODO Login Success

              ApiResponseDatabase response = await obj.jobGetTaskStatus();

              if (response.hasError) {
                if(response.dbo_error != null)
                  CarInfoUtility.showErrorDialog(context, response.dbo_error!.message, response.dbo_error!.error_code);
                if(response.error != null)
                  showErrorDialog(context, response.error!.message, response.error!.statusCode.toString());
              } else {
                if (response.data != null && response.data!.isNotEmpty) {
                  final taskList = response.data!;
                  await UserPrefs.saveTaskStatus(taskList); // ذخیره کل لیست
                  print('Saved ${taskList.length} task statuses.');
                } else {
                  print("No task status found.");
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Load Task Status",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                );
              }
              // await UserPrefs.saveUser(user);
              final prefs = await SharedPreferences.getInstance();

              GeneralConfig cfg = GeneralConfig(MqttConnection: false);
              if(isMQTTChecked)
                cfg.MqttConnection = true;
              else
                cfg.MqttConnection = false;

              await UserPrefs.saveGeneralConfig(cfg);
              await UserPrefs.clearUserWithID();
              await UserPrefs.saveUserWithID(user);
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

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainMenuPage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kullanıcı adı veya şifre yanlış.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        } catch (e) {
          print("Error: $e");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Server isn\'t RUN',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    } else {
      print("serverIP not found or data is null");
    }
  }

  bool isValidIPAddress(String ip) {
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}$',
    );
    return ipRegex.hasMatch(ip);
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

  void _LoginPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
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
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: isMQTTChecked,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isMQTTChecked = newValue ?? false;
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith(getColor),
                      ),
                      const Expanded(
                        child: Text(
                          'MQTT Connection',
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
                onPressed: _isLoginButtonEnabled ? _login : null,
                child: Text('Giriş'),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showIPPortDialog,
                child: Text('Set Server IP'),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isScanServerButtonEnabled ? _login : null,
                child: Text('Scan Server IP'),
              ),
            ),
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


class RegisterNewJobPage extends StatelessWidget {
  const RegisterNewJobPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.work_outline, size: 100, color: Colors.deepPurple),
          SizedBox(height: 20),
          Text('Register a New Job', style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}
