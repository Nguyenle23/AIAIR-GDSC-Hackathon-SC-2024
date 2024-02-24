import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iu_air_quality/src/screens/chart/chart_screen.dart';
import 'package:iu_air_quality/src/screens/dashboard/dashboard_screen.dart';
import 'package:iu_air_quality/src/screens/info/info_screen.dart';
import 'package:iu_air_quality/src/screens/map/map_screen.dart';
import 'package:iu_air_quality/src/screens/setting/setting_screen.dart';
import 'package:iu_air_quality/src/constants/constant_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ConstantColor _constants = ConstantColor();
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _constants.tertiaryColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'AIAir Quality Monitoring',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontFamily: 'Kanit Medium 500'),
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
        iconSize: 24,
        currentIndex: _selectedIndex, //New
        onTap: _onItemTapped,
        unselectedItemColor:
            const Color.fromARGB(255, 236, 236, 236).withOpacity(0.5),
        selectedItemColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: _constants.tertiaryColor,
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
