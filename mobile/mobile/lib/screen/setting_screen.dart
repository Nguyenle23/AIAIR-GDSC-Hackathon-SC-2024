import 'package:flutter/material.dart';
import 'package:iu_air_quality/screen/sub_setting/general_info_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: const [
      //       Center(
      //         child: Image(
      //           image: AssetImage('assets/images/faviconIU1.png'),
      //           height: 40,
      //           width: 40,
      //           // color: Colors.white,
      //         ),
      //       ),
      //       SizedBox(
      //         width: 10,
      //       ),
      //       Center(
      //         child: Text(
      //           'Air Quality App',
      //           style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 25,
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(
      //       bottom: Radius.circular(20),
      //     ),
      //   ),
      // ),
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
                  'IU Air Quality App',
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
                const SizedBox(
                  width: 10,
                ),
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
                const SizedBox(
                  width: 10,
                ),
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
                  Icons.question_answer_outlined,
                  size: 30,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'FAQs',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 210,
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

            //version number
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Image(
                  image: AssetImage('assets/images/LogoAIoT.png'),
                  height: 95,
                  width: 95,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Version: 0.0.2',
                  style: TextStyle(
                    fontSize: 20,
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
