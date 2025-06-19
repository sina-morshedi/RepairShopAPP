import 'type.dart';
import 'package:autonetwork/TroubleshootingApp.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'GetCarInfoApp.dart';
import 'ShowCarInfoApp.dart';
import 'GetCarProblemApp.dart';
import 'dboAPI.dart';
import 'DataFiles.dart';
import 'user_prefs.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'EditCarIinfoApp.dart';
import 'TestUI.dart';


List<CameraDescription> cameras = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
      // home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _appVersion = '';
  String topText = '';
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => LoginPage()),
    //   );
    // });

    _loadAppVersion();
    _checkLoginStatus();
  }

  void _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    User? user = await UserPrefs.getUser();
    setState(() {
      if (user != null && user.role != null) {
        topText = '${user.FirstName} ${user.LastName} (${user.role!.RoleName})';
      } else {
        topText = 'Welcome';
      }
      _appVersion = info.version;
    });
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

  void _onButtonPressed(int index) {
    if (index >= 0 && index <= 5) {
      _handleButtonPress(index);
    }
  }

  void _handleButtonPress(int index) async {
    if (index == 0)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GetCarInfoApp()),
      );

    if (index == 1)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditCarInfoApp()),
      );

    if (index == 2)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Showcarinfoapp()),
      );
    if (index == 3)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GetCarProblemApp()),
      );
    if (index == 4)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TroubleshootingApp()),
      );
  }

  List<String> buttonLabels = [
    "Araba Ruhsat Kaydet",
    "Araba Ruhsat düzenlemek",
    "Arabalar",
    "Araba Şikayeti",
    "Arıza Tespit",
    "Giriş tarihi",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Image.asset('assets/images/Logo.png', fit: BoxFit.cover),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 0, top: 0, bottom: 8),

            child: IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.redAccent, size: 40),
              onPressed: () async {
                await UserPrefs.clearLoginTimestamp();
                await UserPrefs.clearUser();
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Instruction text
                Text(
                  topText,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 30),

                // Button grid
                Wrap(
                  spacing: 30,
                  runSpacing: 30,
                  alignment: WrapAlignment.center,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 150,
                      height: 100,
                      child: ElevatedButton(
                        onPressed: () => _onButtonPressed(index),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color(0xFF5F46AA),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(buttonLabels[index]),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 50),

                // Footer text
                Text(
                  '© 2025 Sina Morshedi - v$_appVersion',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
  bool _isServerIPButtonEnabled = true;
  bool _isLoginButtonEnabled = false;
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
    Map<String, dynamic>? data = await readJsonFromFile(fileType.serverConfig);
    final storage = FlutterSecureStorage();
    final user = await storage.read(key: 'username') ?? '';
    final pass = await storage.read(key: 'password') ?? '';
    if(user != '') {
      _usernameController.text = user;
      _passwordController.text = pass;
      setState(() {
        isChecked = true;
      });
    }
    else{
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
          ApiResponseDatabase<User> result = await obj.jobFetchUser(username ?? '');
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
            bool isValid = BCrypt.checkpw(password ?? '', user.userPass!.password);
            if (isValid) {
              //TODO Login Success
              await UserPrefs.saveUser(user);
              await UserPrefs.saveLoginTimestamp();
              if(isChecked) {
                final storage = FlutterSecureStorage();
                await storage.write(key: 'username', value: username);
                await storage.write(key: 'password', value: password);
              }
              else{
                final storage = FlutterSecureStorage();
                await storage.delete(key: 'username');
                await storage.delete(key: 'password');
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
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
    // if (isValidIPAddress(data['ServerIP']))
    //   _showIPPortDialog();
    // TODO: Scan Server
    // Map<String, dynamic>? data = await readJsonFromFile();
    // print(data);
    // var ip;
    // print(data);
    // if (data != null) {
    //   String str = data['serverIP'];
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Server IP is: $str')));
    //   String url = str;
    //
    //   var parts = url.split("://");
    //   if (parts.length > 1) {
    //     var addressPort = parts[1];
    //     ip = addressPort.split(":")[0];
    //
    //     print("IP is: $ip");
    //   } else {
    //     print("Invalid URL format");
    //   }
    //
    //   dboAPI obj2 = dboAPI();
    //   if (await obj2.ping(ip)) {
    //     setState(() {
    //       _isScanServerButtonEnabled = false;
    //     });
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           'Server is RUN',
    //           style: TextStyle(color: Colors.green),
    //         ),
    //       ),
    //     );
    //   } else {
    //     setState(() {
    //       _isScanServerButtonEnabled = true;
    //     });
    //     deleteJsonFile();
    //     Map<String, dynamic> data = {'serverIP': dboAPI.urlAddress};
    //     await writeJsonToFile(data);
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           'Server isn\'t RUN',
    //           style: TextStyle(color: Colors.red),
    //         ),
    //       ),
    //     );
    //   }
    // }
    // else {
    //   dboAPI.urlAddress = '';
    //   dboAPI obj = dboAPI();
    //   obj.initServerDiscovery();
    //   await Future.delayed(Duration(seconds: 1));
    //   await obj.initServerDiscovery();
    //
    //   final message = dboAPI.urlAddress.isEmpty
    //       ? 'No Server'
    //       : dboAPI.urlAddress;
    //
    //   if (message != 'No Server') {
    //     setState(() {
    //       _isScanServerButtonEnabled = false;
    //     });
    //     Map<String, dynamic> data = {'serverIP': message};
    //     await writeJsonToFile(data);
    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(SnackBar(content: Text('Server IP save: $message')));
    //   }
    //   else{
    //     setState(() {
    //       _isScanServerButtonEnabled = false;
    //     });
    //   }
    // }

    // Map<String, dynamic> mapobj = await obj.fetchUser(username);
    // print(mapobj["PasswordHash"]);

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text(mapobj["PasswordHash"])),
    // );

    // _onLoginSuccess(context);
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
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? newValue) {
                    setState(() {
                      isChecked = newValue ?? false;
                    });
                  },
                  fillColor: MaterialStateProperty.resolveWith(getColor),
                ),
                const Text(
                  style: TextStyle(fontWeight: FontWeight.bold),
                  'Kullanıcı Adı ve Şifreyi Kaydet',
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
