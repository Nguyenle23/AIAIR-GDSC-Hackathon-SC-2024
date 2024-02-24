import 'package:flutter/material.dart';
import 'package:iu_air_quality/src/screens/home/home_page.dart';
import 'package:iu_air_quality/src/utils/theme.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  tzdata.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeClass.lightTheme,
      darkTheme: ThemeClass.darkTheme,
      title: 'Air Quality Monitoring',
      home: const HomePage(),
    );
  }
}
