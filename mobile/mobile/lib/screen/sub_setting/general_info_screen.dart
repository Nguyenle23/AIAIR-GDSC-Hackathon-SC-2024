import 'package:flutter/material.dart';
import 'package:iu_air_quality/screen/setting_screen.dart';

class GeneralInfoScreen extends StatefulWidget {
  const GeneralInfoScreen({super.key});

  @override
  State<GeneralInfoScreen> createState() => _GeneralInfoScreenState();
}

class _GeneralInfoScreenState extends State<GeneralInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            //About
            SizedBox(
              height: 40,
            ),
            Text(
              'About',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'This app is made by students of Computer Sciences, International University - Vietnam National University. This app is made for the thesis project',
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Image(
              image: AssetImage('assets/images/faviconIU.png'),
              height: 100,
              width: 100,
              color: Colors.white,
            ),
            
            //Developers
            SizedBox(
              height: 20,
            ),
            Text(
              'Developers',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Chair: Dr. Le Duy Tan',
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              '1. Le Nguyen Binh Nguyen',
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '2. Truong Nhat Minh Quang',
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            
            //Mechanism
            Text(
              'Mechanism',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'The diagram below shows the mechanism of the app and how it works',
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Image(
              image: AssetImage('assets/images/diagram.png'),
              height: 500,
              width: 500,
            ),
            SizedBox(
              height: 20,
            ),
            
            //real system
            Text(
              'Real system',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'The diagram below shows the real system of the app',
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Image(
              image: AssetImage('assets/images/newSystem.png'),
              height: 500,
              width: 500,
            ),
          ],
        ),
      ),
    );
  }
}
