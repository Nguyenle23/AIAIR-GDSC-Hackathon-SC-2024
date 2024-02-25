import 'package:flutter/material.dart';
import 'package:iu_air_quality/screen/dashboard_screen.dart';
import 'package:iu_air_quality/screen/map_screen.dart';
import 'package:iu_air_quality/screen/chart_screen.dart';
import 'package:iu_air_quality/screen/setting_screen.dart';
import 'package:iu_air_quality/screen/info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),
    MapScreen(),
    ChartScreen(),
    InfoScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green[800],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Center(
              child: Text(
                'Air Quality Monitoring',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: 'Kanit Medium 500'
                ),
              ),
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex), //New
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 25,
        currentIndex: _selectedIndex, //New
        onTap: _onItemTapped,
        unselectedItemColor: const Color.fromARGB(255, 236, 236, 236).withOpacity(0.5),
        selectedItemColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.green[800],
            icon: const Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.language_outlined),
            label: 'Map',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.area_chart_outlined),
            label: 'Chart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.info_outline_rounded),
            label: 'Information',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
