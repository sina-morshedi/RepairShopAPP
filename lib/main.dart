import 'package:flutter/material.dart';
import 'Pages/MainMenuPage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
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
      locale: const Locale('tr', 'TR'), // ← این خط مهمه
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const MainMenuPage(),
    );

  }
}
