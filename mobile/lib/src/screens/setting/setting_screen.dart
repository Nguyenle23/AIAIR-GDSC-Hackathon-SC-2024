import 'package:flutter/material.dart';
import 'package:iu_air_quality/src/screens/setting/sub_setting/general_info_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          children: [
            Row(
              children: const [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(
                right: 220,
              ),
              child: Divider(
                thickness: 2,
                color: Color.fromARGB(255, 8, 61, 26),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.notifications_none_outlined,
                  size: 30,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 135,
                ),
                Switch(
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),

            //option change dark mode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.dark_mode_outlined,
                  size: 30,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 145,
                ),
                Switch(
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),

            //option dropdown menu for language
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.language_outlined,
                  size: 30,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 110,
                ),
                DropdownButton(
                  items: const [
                    DropdownMenuItem(
                      value: 'English',
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: 'Vietnamese',
                      child: Text('Vietnamese'),
                    ),
                  ],
                  onChanged: (value) {},
                  value: 'English',
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),

            //option navigate to about us screen
            Row(
              children: const [
                Text(
                  'AIAir Information',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(
                right: 120,
              ),
              child: Divider(
                thickness: 2,
                color: Color.fromARGB(255, 8, 61, 26),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 30,
                ),
                const Spacer(),
                const Text(
                  'General Information',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 86,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GeneralInfoScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_right_rounded,
                    size: 30,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.cable_outlined,
                  size: 30,
                ),
                const Spacer(),
                const Text(
                  'Technologies',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 145,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.keyboard_arrow_right_rounded,
                    size: 30,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.devices_other_outlined,
                  size: 30,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Devices',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 190,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.keyboard_arrow_right_rounded,
                    size: 30,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.web_asset,
                  size: 30,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Website',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 180,
                ),
                IconButton(
                  onPressed: () {
                    Uri url =
                        Uri.parse('https://www.aiair-aiotlabvn.tech/');
                    launchUrl(url);
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_right_rounded,
                    size: 30,
                  ),
                ),
              ],
            ),

            //version number
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage('assets/images/aiair.png'),
                      height: 80,
                      width: 80,
                    ),
                    Image(
                      image: AssetImage('assets/images/LogoAIoT.png'),
                      height: 80,
                      width: 80,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  _packageInfo.version,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
