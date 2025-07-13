import 'package:flutter/material.dart';
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
