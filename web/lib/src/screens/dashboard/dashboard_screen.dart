import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:iu_air_quality/src/constants/constant_color.dart';
import 'package:iu_air_quality/src/screens/weather_item/weather_item.dart';
import 'package:iu_air_quality/src/utils/format_date.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ConstantColor _constants = ConstantColor();
  final int _totalPages = 2;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String stationName = '';

  String tempValue = '';
  String humiValue = '';
  String co2Value = '';
  String coValue = '';
  String pm25Value = '';
  String uvValue = '';
  String currentTime = '';
  String currentDayOfWeek = '';
  String currentDay = '';
  String currentAmPm = '';
  String windSpeed = '';
  String windDirection = '';

  String tempValueTD = '';
  String humiValueTD = '';
  String co2ValueTD = '';
  String coValueTD = '';
  String pm25ValueTD = '';
  String uvValueTD = '';
  String currentTimeTD = '';
  String currentDayOfWeekTD = '';
  String currentDayTD = '';
  String currentAmPmTD = '';
  String windSpeedTD = '';
  String windDirectionTD = '';

  String newsetDataHCM =
      "https://api.thingspeak.com/channels/2404698/feeds.json?results=1&timezone=Asia%2FBangkok";

  String newsetWindHCM =
      "https://api.openweathermap.org/data/2.5/weather?lat=10.7936588867&lon=106.6803109431&appid=99d40475f251003865b51c383d6fda8d";

  String newsetDataTD =
      "https://api.thingspeak.com/channels/2115707/feeds.json?results=1&timezone=Asia%2FBangkok";

  String newsetWindTD =
      "https://api.openweathermap.org/data/2.5/weather?lat=10.8619784&lon=106.8034464&appid=99d40475f251003865b51c383d6fda8d";

  void fetchDataHCM() async {
    try {
      var response = await http.get(Uri.parse(newsetDataHCM));
      var jsonData = json.decode(response.body);
      var getFeed = jsonData['feeds'];

      double tempValue = double.parse(getFeed[0]['field1']);
      double humiValue = double.parse(getFeed[0]['field2']);
      double co2Value = double.parse(getFeed[0]['field3']);
      double coValue = double.parse(getFeed[0]['field4']);
      double pm25Value = double.parse(getFeed[0]['field5']);
      double uvValue = double.parse(getFeed[0]['field6']);

      String formattedTemp = tempValue.toStringAsFixed(1);
      String formattedHumi = humiValue.toStringAsFixed(1);
      String formattedCO2 = co2Value.toStringAsFixed(1);
      String formattedCO = coValue.toStringAsFixed(1);
      String formattedPM25 = pm25Value.toStringAsFixed(1);
      String formattedUV = uvValue.toStringAsFixed(1);

      //formate date
      String dateTimeString = getFeed[0]['created_at'];
      String timeZone = 'Asia/Bangkok';

      //get the day-month-year in Asia/Bangkok time zone
      Map<String, dynamic> formattedInfo =
          formatDateTime(dateTimeString, timeZone);

      //get data wind
      var responseWind = await http.get(Uri.parse(newsetWindHCM));
      var jsonDataWind = json.decode(responseWind.body);

      setState(() {
        this.tempValue = formattedTemp;
        this.humiValue = formattedHumi;
        this.co2Value = formattedCO2;
        this.coValue = formattedCO;
        this.pm25Value = formattedPM25;
        this.uvValue = formattedUV;
        currentTime = formattedInfo['collectedTime'];
        currentDayOfWeek = formattedInfo['dayOfWeek'];
        currentDay = formattedInfo['day'];
        currentAmPm = formattedInfo['amPm'];
        windSpeed = jsonDataWind['wind']['speed'].toString();
        windDirection = jsonDataWind['wind']['deg'].toString();
      });
    } catch (e) {
      print(e);
    }
  }

  void fetchDataTD() async {
    try {
      var response = await http.get(Uri.parse(newsetDataTD));
      var jsonData = json.decode(response.body);
      var getFeed = jsonData['feeds'];

      double tempValueTD = double.parse(getFeed[0]['field1']);
      double humiValueTD = double.parse(getFeed[0]['field2']);
      double co2ValueTD = double.parse(getFeed[0]['field3']);
      double coValueTD = double.parse(getFeed[0]['field4']);
      double pm25ValueTD = double.parse(getFeed[0]['field5']);
      double uvValueTD = double.parse(getFeed[0]['field6']);

      String formattedTempTD = tempValueTD.toStringAsFixed(1);
      String formattedHumiTD = humiValueTD.toStringAsFixed(1);
      String formattedCO2TD = co2ValueTD.toStringAsFixed(1);
      String formattedCOTD = coValueTD.toStringAsFixed(1);
      String formattedPM25TD = pm25ValueTD.toStringAsFixed(1);
      String formattedUVTD = uvValueTD.toStringAsFixed(1);

      //formate date
      String dateTimeString = getFeed[0]['created_at'];
      String timeZone = 'Asia/Bangkok';

      //get the day-month-year in Asia/Bangkok time zone
      Map<String, dynamic> formattedInfoTD =
          formatDateTime(dateTimeString, timeZone);

      //get data wind
      var responseWind = await http.get(Uri.parse(newsetWindTD));
      var jsonDataWind = json.decode(responseWind.body);

      setState(() {
        this.tempValueTD = formattedTempTD;
        this.humiValueTD = formattedHumiTD;
        this.co2ValueTD = formattedCO2TD;
        this.coValueTD = formattedCOTD;
        this.pm25ValueTD = formattedPM25TD;
        this.uvValueTD = formattedUVTD;
        currentTimeTD = formattedInfoTD['collectedTime'];
        currentDayOfWeekTD = formattedInfoTD['dayOfWeek'];
        currentDayTD = formattedInfoTD['day'];
        currentAmPmTD = formattedInfoTD['amPm'];
        windSpeedTD = jsonDataWind['wind']['speed'].toString();
        windDirectionTD = jsonDataWind['wind']['deg'].toString();
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataHCM();
    fetchDataTD();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget buildStationInfoPage(
      int stationIndex,
      int stationCount,
      Size size,
      String stationName,
      String currentTime,
      String currentDayOfWeek,
      String currentDay,
      String currentAmPm,
      String tempValue,
      String humiValue,
      String co2Value,
      String coValue,
      String pm25Value,
      String uvValue,
      String windSpeed,
      String windDirection) {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      color: _constants.primaryColor.withOpacity(.1),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          height: size.height * .71,
          decoration: BoxDecoration(
              gradient: _constants.linearGradientBlue,
              boxShadow: [
                BoxShadow(
                  color: _constants.primaryColor.withOpacity(.5),
                  blurRadius: 7,
                  spreadRadius: 5,
                  offset: const Offset(0, 3),
                )
              ],
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/aiair.png',
                      width: 55,
                      height: 55,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        stationName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Kanit Medium 500'),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/images/menu.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 150,
                child: Image.asset(
                  'assets/images/good.png',
                ),
              ),
              const Text(
                "Air Quality Index (AQI)",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Good',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      // foreground: Paint()..shader = _constants.shader,
                    ),
                  ),
                ],
              ),
              Text(
                "$currentTime $currentAmPm || $currentDayOfWeek || $currentDay",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WeatherItem(
                    value: tempValue,
                    unit: '°C',
                    imageUrl: 'assets/images/temp.png',
                  ),
                  WeatherItem(
                    value: humiValue,
                    unit: '%',
                    imageUrl: 'assets/images/humi.png',
                  ),
                  WeatherItem(
                    value: windSpeed,
                    unit: 'km/h',
                    imageUrl: 'assets/images/windspeed.png',
                  ),
                  WeatherItem(
                    value: windDirection,
                    unit: '°',
                    imageUrl: 'assets/images/winddirection.png',
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Divider(
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WeatherItem(
                      value: co2Value,
                      unit: 'ppm',
                      imageUrl: 'assets/images/co2.png',
                    ),
                    WeatherItem(
                      value: coValue,
                      unit: 'ppm',
                      imageUrl: 'assets/images/co.png',
                    ),
                    WeatherItem(
                      value: uvValue,
                      unit: '',
                      imageUrl: 'assets/images/uv.png',
                    ),
                    WeatherItem(
                      value: pm25Value,
                      unit: 'ug/m3',
                      imageUrl: 'assets/images/dust.png',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget buildPageIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _totalPages,
          (int index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Colors.blue
                    : Colors.blue.withOpacity(0.5),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                buildStationInfoPage(
                    0,
                    1,
                    size,
                    'Ho Chi Minh station',
                    currentTime,
                    currentDayOfWeek,
                    currentDay,
                    currentAmPm,
                    tempValue,
                    humiValue,
                    co2Value,
                    coValue,
                    pm25Value,
                    uvValue,
                    windSpeed,
                    windDirection),
                buildStationInfoPage(
                    1,
                    1,
                    size,
                    'Thu Duc station',
                    currentTimeTD,
                    currentDayOfWeekTD,
                    currentDayTD,
                    currentAmPmTD,
                    tempValueTD,
                    humiValueTD,
                    co2ValueTD,
                    coValueTD,
                    pm25ValueTD,
                    uvValueTD,
                    windSpeedTD,
                    windDirectionTD),
              ],
            ),
          ),
          Container(
              color: _constants.primaryColor.withOpacity(.1),
              child: buildPageIndicator()),
        ],
      ),
    );
  }
}


// class AirQualityDataHCM {
//   String tempValue;
//   String humiValue;
//   String co2Value;
//   String coValue;
//   String pm25Value;
//   String uvValue;
//   String date;

//   AirQualityDataHCM(
//       {this.tempValue = "",
//       this.humiValue = "",
//       this.co2Value = "",
//       this.coValue = "",
//       this.pm25Value = "",
//       this.uvValue = "",
//       this.date = ""});
// }

// class AirQualityDataThuDuc {
//   String tempValue;
//   String humiValue;
//   String co2Value;
//   String coValue;
//   String pm25Value;
//   String uvValue;
//   String date;

//   AirQualityDataThuDuc(
//       {this.tempValue = "",
//       this.humiValue = "",
//       this.co2Value = "",
//       this.coValue = "",
//       this.pm25Value = "",
//       this.uvValue = "",
//       this.date = ""});
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   bool _isMounted = false;

//   AirQualityDataHCM _airQualityDataHCM = AirQualityDataHCM();
//   AirQualityDataThuDuc _airQualityDataThuDuc = AirQualityDataThuDuc();

//   @override
//   void initState() {
//     _isMounted = true;
//     super.initState();
//     getDataHCM();
//     getDataThuDuc();
//     Timer.periodic(const Duration(minutes: 5), (timer) {
//       getDataHCM();
//       getDataThuDuc();
//     });
//   }

//   @override
//   void dispose() {
//     _isMounted = false;
//     super.dispose();
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//     ));
//   }

//   getDataHCM() async {
//     var url =
//         "https://api.thingspeak.com/channels/2115707/feeds.json?results=1&timezone=Asia%2FBangkok";
//     var response = await http.get(
//       Uri.parse(url),
//       headers: {"Accept": "application/json"},
//     );

//     if (_isMounted) {
//       var data = response.body;
//       var jsonData = json.decode(data);
//       var getFeed = jsonData['feeds'];

//       double tempValue = double.parse(getFeed[0]['field1']);
//       double humiValue = double.parse(getFeed[0]['field2']);
//       double co2Value = double.parse(getFeed[0]['field3']);
//       double coValue = double.parse(getFeed[0]['field4']);
//       double pm25Value = double.parse(getFeed[0]['field5']);
//       double uvValue = double.parse(getFeed[0]['field6']);

//       String formattedTemp = tempValue.toStringAsFixed(1);
//       String formattedHumi = humiValue.toStringAsFixed(1);
//       String formattedCO2 = co2Value.toStringAsFixed(4);
//       String formattedCO = coValue.toStringAsFixed(4);
//       String formattedPM25 = pm25Value.toStringAsFixed(4);
//       String formattedUV = uvValue.toStringAsFixed(4);

//       // for (var i = 0; i < getFeed.length; i++) {
//       //   String dateTimeString = getFeed[i]['created_at'];
//       //   DateTime dateTime = DateTime.parse(dateTimeString);
//       //   String collectedDate = DateFormat('HH:mm').format(dateTime).toString();
//       //   String indeAir = getFeed[i]['field1'];
//       // }

//       //formate date
//       String dateTimeString = getFeed[0]['created_at'];
//       DateTime dateTime =
//           DateTime.parse(dateTimeString).toLocal(); // Convert to local time
//       String collectedDate = DateFormat('HH:mm:ss').format(dateTime).toString();

//       // Load the Asia/Bangkok time zone
//       tz.Location asiaBangkok = tz.getLocation('Asia/Bangkok');

//       // Convert the DateTime to Asia/Bangkok time zone
//       tz.TZDateTime asiaBangkokTime = tz.TZDateTime.from(dateTime, asiaBangkok);

//       // Get the day of the week in Asia/Bangkok time zone
//       String dayOfWeek =
//           DateFormat('EEEE', 'en_US').format(asiaBangkokTime).toString();

//       //get the day-month-year in Asia/Bangkok time zone
//       String day =
//           DateFormat('dd-MM-yyyy', 'en_US').format(asiaBangkokTime).toString();

//       // Format AM or PM in Asia/Bangkok time zone
//       String amPm = DateFormat('a', 'en_US').format(asiaBangkokTime).toString();

//       setState(() {
//         _airQualityDataHCM = AirQualityDataHCM(
//             tempValue: formattedTemp,
//             humiValue: formattedHumi,
//             co2Value: formattedCO2,
//             coValue: formattedCO,
//             pm25Value: formattedPM25,
//             uvValue: formattedUV,
//             date: "$day || $dayOfWeek || $collectedDate $amPm");
//       });
//     }
//   }

//   getDataThuDuc() async {
//     var url =
//         "https://api.thingspeak.com/channels/2239030/feeds.json?results=1&timezone=Asia%2FBangkok";
//     var response = await http.get(
//       Uri.parse(url),
//       headers: {"Accept": "application/json"},
//     );

//     var data = response.body;

//     if (_isMounted) {
//       var jsonData = json.decode(data);
//       var getFeed = jsonData['feeds'];

//       double tempValue = double.parse(getFeed[0]['field1']);
//       double humiValue = double.parse(getFeed[0]['field2']);
//       double co2Value = double.parse(getFeed[0]['field3']);
//       double coValue = double.parse(getFeed[0]['field4']);
//       double pm25Value = double.parse(getFeed[0]['field5']);
//       double uvValue = double.parse(getFeed[0]['field6']);

//       String formattedTemp = tempValue.toStringAsFixed(1);
//       String formattedHumi = humiValue.toStringAsFixed(1);
//       String formattedCO2 = co2Value.toStringAsFixed(4);
//       String formattedCO = coValue.toStringAsFixed(4);
//       String formattedPM25 = pm25Value.toStringAsFixed(4);
//       String formattedUV = uvValue.toStringAsFixed(4);

//       //formate date
//       String dateTimeString = getFeed[0]['created_at'];
//       DateTime dateTime =
//           DateTime.parse(dateTimeString).toLocal(); // Convert to local time
//       String collectedDate = DateFormat('HH:mm:ss').format(dateTime).toString();

//       // Load the Asia/Bangkok time zone
//       tz.Location asiaBangkok = tz.getLocation('Asia/Bangkok');

//       // Convert the DateTime to Asia/Bangkok time zone
//       tz.TZDateTime asiaBangkokTime = tz.TZDateTime.from(dateTime, asiaBangkok);

//       // Get the day of the week in Asia/Bangkok time zone
//       String dayOfWeek =
//           DateFormat('EEEE', 'en_US').format(asiaBangkokTime).toString();

//       //get the day-month-year in Asia/Bangkok time zone
//       String day =
//           DateFormat('dd-MM-yyyy', 'en_US').format(asiaBangkokTime).toString();

//       // Format AM or PM in Asia/Bangkok time zone
//       String amPm = DateFormat('a', 'en_US').format(asiaBangkokTime).toString();

//       setState(() {
//         _airQualityDataThuDuc = AirQualityDataThuDuc(
//             tempValue: formattedTemp,
//             humiValue: formattedHumi,
//             co2Value: formattedCO2,
//             coValue: formattedCO,
//             pm25Value: formattedPM25,
//             uvValue: formattedUV,
//             date: "$day || $dayOfWeek || $collectedDate $amPm");
//       });
//     }
//   }

  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(
//                 top: 5,
//               ),
//               child: SizedBox(
//                 height: 80,
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Padding(
//                           padding: EdgeInsets.only(
//                             top: 5,
//                           ),
//                           child: Icon(
//                             Icons.location_on_rounded,
//                             color: Colors.green,
//                             size: 35,
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(
//                             left: 2,
//                           ),
//                           child: Center(
//                               child: Text("Ho Chi Minh City",
//                                   style: TextStyle(
//                                       fontSize: 30,
//                                       fontFamily: 'Kanit Regular 400'))),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(
//                             left: 2,
//                           ),
//                           // child: Text("07 July 2023",
//                           //     style: TextStyle(
//                           //         fontSize: 20, fontFamily: 'Kanit Light')),
//                           child: _airQualityDataHCM.date == ""
//                               ? const Text("Loading...",
//                                   style: TextStyle(
//                                       fontSize: 20,
//                                       fontFamily: 'Kanit Regular 400'))
//                               : Text(_airQualityDataHCM.date,
//                                   style: const TextStyle(
//                                       fontSize: 20,
//                                       fontFamily: 'Kanit Medium 500')),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             //icon if the temperature is too high
//             Padding(
//               padding: const EdgeInsets.only(
//                 top: 5,
//                 left: 10,
//                 right: 10,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.only(
//                       left: 10,
//                     ),
//                     child: Text(
//                       "Air Quality: ",
//                       style: TextStyle(
//                           fontSize: 30, fontFamily: 'Kanit Regular 400'),
//                     ),
//                   ),
//                   _airQualityDataHCM.tempValue == "33"
//                       ? Row(
//                           children: const [
//                             Icon(
//                               Icons.mood_bad,
//                               size: 50,
//                             ),
//                             Text(
//                               "Bad",
//                               style: TextStyle(
//                                   fontSize: 30, fontFamily: 'Kanit Medium 500'),
//                             ),
//                           ],
//                         )
//                       : Row(
//                           children: const [
//                             Icon(
//                               Icons.tag_faces_sharp,
//                               size: 50,
//                             ),
//                             Text(
//                               "Good",
//                               style: TextStyle(
//                                   fontSize: 30,
//                                   fontFamily: 'Kanit Medium 500',
//                                   color: Colors.green),
//                             ),
//                           ],
//                         )
//                 ],
//               ),
//             ),

//             Padding(
//                 padding: const EdgeInsets.only(
//                   top: 5,
//                   left: 10,
//                   right: 5,
//                   bottom: 10,
//                 ),
//                 child: DataTable(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(
//                         color: Colors.black,
//                         width: 3,
//                       ),
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black,
//                           offset: Offset.zero,
//                           blurRadius: 1,
//                           blurStyle: BlurStyle.outer,
//                         ),
//                       ],
//                     ),
//                     columns: const [
//                       DataColumn(
//                         label: Text(
//                           'Parameter',
//                           style: TextStyle(fontSize: 24),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       DataColumn(
//                         label: Text(
//                           'Value',
//                           style: TextStyle(fontSize: 24),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ],
//                     rows: [
//                       DataRow(cells: [
//                         const DataCell(
//                           Text(
//                             'Temperature',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         DataCell(
//                           _airQualityDataHCM.tempValue == "0"
//                               ? const Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 )
//                               : Text(
//                                   "${_airQualityDataHCM.tempValue} °C",
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                         ),
//                       ]),
//                       DataRow(cells: [
//                         const DataCell(
//                           Text(
//                             'Humidity',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         DataCell(
//                           _airQualityDataHCM.tempValue == "0"
//                               ? const Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 )
//                               : Text(
//                                   "${_airQualityDataHCM.humiValue} %",
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                         ),
//                       ]),
//                       DataRow(cells: [
//                         const DataCell(
//                           Text(
//                             'CO2 Value',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         DataCell(
//                           _airQualityDataHCM.tempValue == "0"
//                               ? const Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 )
//                               : Text(
//                                   "${_airQualityDataHCM.co2Value} ppm",
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                         ),
//                       ]),
//                       DataRow(cells: [
//                         const DataCell(
//                           Text(
//                             'CO Value',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         DataCell(
//                           _airQualityDataHCM.tempValue == "0"
//                               ? const Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 )
//                               : Text(
//                                   "${_airQualityDataHCM.coValue} ppm",
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                         ),
//                       ]),
//                       DataRow(cells: [
//                         const DataCell(
//                           Text(
//                             'UV Index',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         DataCell(
//                           _airQualityDataHCM.tempValue == "0"
//                               ? const Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 )
//                               : Text(
//                                   "${_airQualityDataHCM.uvValue} mW/cm2",
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 18,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                         ),
//                       ]),
//                       DataRow(cells: [
//                         const DataCell(
//                           Text(
//                             'PM 2.5',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         DataCell(
//                           _airQualityDataHCM.tempValue == "0"
//                               ? const Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 )
//                               : Text(
//                                   "${_airQualityDataHCM.pm25Value} µg/m3",
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 19,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                         ),
//                       ]),
//                     ])),

//             //divider
//             const Divider(
//               height: 10,
//               thickness: 5,
//               indent: 20,
//               endIndent: 20,
//               color: Colors.black,
//             ),

//             Padding(
//               padding: const EdgeInsets.only(
//                 top: 5,
//               ),
//               child: SizedBox(
//                 height: 80,
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Padding(
//                           padding: EdgeInsets.only(
//                             top: 5,
//                           ),
//                           child: Icon(
//                             Icons.location_on_rounded,
//                             color: Colors.green,
//                             size: 35,
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(
//                             left: 2,
//                           ),
//                           child: Center(
//                               child: Text("Thu Duc City",
//                                   style: TextStyle(
//                                       fontSize: 30,
//                                       fontFamily: 'Kanit Regular 400'))),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(
//                             left: 2,
//                           ),
//                           // child: Text("07 July 2023",
//                           //     style: TextStyle(
//                           //         fontSize: 20, fontFamily: 'Kanit Light')),
//                           child: _airQualityDataThuDuc.date == ""
//                               ? const Text("Loading...",
//                                   style: TextStyle(
//                                       fontSize: 20,
//                                       fontFamily: 'Kanit Regular 400'))
//                               : Text(_airQualityDataThuDuc.date,
//                                   style: const TextStyle(
//                                       fontSize: 20,
//                                       fontFamily: 'Kanit Medium 500')),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             //icon if the temperature is too high
//             Padding(
//               padding: const EdgeInsets.only(
//                 top: 5,
//                 left: 10,
//                 right: 10,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.only(
//                       left: 10,
//                     ),
//                     child: Text(
//                       "Air Quality: ",
//                       style: TextStyle(
//                           fontSize: 30, fontFamily: 'Kanit Regular 400'),
//                     ),
//                   ),
//                   _airQualityDataThuDuc.tempValue == "33"
//                       ? Row(
//                           children: const [
//                             Icon(
//                               Icons.mood_bad,
//                               size: 50,
//                             ),
//                             Text(
//                               "Bad",
//                               style: TextStyle(
//                                   fontSize: 30, fontFamily: 'Kanit Medium 500'),
//                             ),
//                           ],
//                         )
//                       : Row(
//                           children: const [
//                             Icon(
//                               Icons.tag_faces_sharp,
//                               size: 50,
//                             ),
//                             Text(
//                               "Good",
//                               style: TextStyle(
//                                   fontSize: 30,
//                                   fontFamily: 'Kanit Medium 500',
//                                   color: Colors.green),
//                             ),
//                           ],
//                         )
//                 ],
//               ),
//             ),

//             Padding(
//                 padding: const EdgeInsets.only(
//                   top: 5,
//                   left: 10,
//                   right: 5,
//                   bottom: 10,
//                 ),
//                 child: DataTable(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(
//                         color: Colors.black,
//                         width: 3,
//                       ),
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black,
//                           offset: Offset.zero,
//                           blurRadius: 1,
//                           blurStyle: BlurStyle.outer,
//                         ),
//                       ],
//                     ),
//                     columns: const [
//                       DataColumn(
//                         label: Text(
//                           'Parameter',
//                           style: TextStyle(fontSize: 24),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       DataColumn(
//                         label: Text(
//                           'Value',
//                           style: TextStyle(fontSize: 24),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ],
//                     rows: [
//                       DataRow(cells: [
//                         const DataCell(
//                           Text(
//                             'Temperature',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         DataCell(
//                           _airQualityDataThuDuc.tempValue == "0"
//                               ? const Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 )
//                               : Text(
//                                   "${_airQualityDataThuDuc.tempValue} °C",
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                         ),
//                       ]),
//                       DataRow(cells: [
//                         const DataCell(
//                           Text(
//                             'Humidity',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         DataCell(
//                           _airQualityDataThuDuc.tempValue == "0"
//                               ? const Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 )
//                               : Text(
//                                   "${_airQualityDataThuDuc.humiValue} %",
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                         ),
//                       ]),
//                       DataRow(cells: [
//                         const DataCell(
//                           Text(
//                             'CO2 Value',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         DataCell(
//                           _airQualityDataThuDuc.tempValue == "0"
//                               ? const Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 )
//                               : Text(
//                                   "${_airQualityDataThuDuc.co2Value} ppm",
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                         ),
//                       ]),
//                       DataRow(cells: [
//                         const DataCell(
//                           Text(
//                             'CO Value',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         DataCell(
//                           _airQualityDataThuDuc.tempValue == "0"
//                               ? const Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 )
//                               : Text(
//                                   "${_airQualityDataThuDuc.coValue} ppm",
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                         ),
//                       ]),
//                       DataRow(cells: [
//                         const DataCell(
//                           Text(
//                             'UV Index',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         DataCell(
//                           _airQualityDataThuDuc.tempValue == "0"
//                               ? const Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 )
//                               : Text(
//                                   "${_airQualityDataThuDuc.uvValue} mW/cm2",
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 18,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                         ),
//                       ]),
//                       DataRow(cells: [
//                         const DataCell(
//                           Text(
//                             'PM 2.5',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         DataCell(
//                           _airQualityDataThuDuc.tempValue == "0"
//                               ? const Text(
//                                   'Loading...',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 )
//                               : Text(
//                                   "${_airQualityDataThuDuc.pm25Value} µg/m3",
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 19,
//                                       fontFamily: 'Arial',
//                                       fontWeight: FontWeight.bold),
//                                   textAlign: TextAlign.center,
//                                 ),
//                         ),
//                       ]),
//                     ])),

//             //button predict
//             // Padding(
//             //   padding: const EdgeInsets.only(
//             //     top: 5,
//             //     left: 100,
//             //     right: 100,
//             //   ),
//             //   child: Container(
//             //     height: 50,
//             //     decoration: BoxDecoration(
//             //       color: Colors.black,
//             //       border: Border.all(
//             //         color: Colors.black,
//             //         width: 2,
//             //       ),
//             //       borderRadius: BorderRadius.circular(15),
//             //       boxShadow: const [
//             //         BoxShadow(
//             //           color: Colors.black,
//             //           offset: Offset.zero,
//             //           blurRadius: 1,
//             //           blurStyle: BlurStyle.outer,
//             //         ),
//             //       ],
//             //     ),
//             //     child: Row(
//             //       children: <Widget>[
//             //         Expanded(
//             //           child: TextButton(
//             //             style: TextButton.styleFrom(
//             //               backgroundColor: Colors.green,
//             //               shape: RoundedRectangleBorder(
//             //                 borderRadius: BorderRadius.circular(15),
//             //               ),
//             //             ),
//             //             onPressed: () {
//             //               Navigator.push(
//             //                 context,
//             //                 CupertinoPageRoute(
//             //                     builder: (context) => const DashboardScreen()),
//             //               );
//             //             },
//             //             child: const Text(
//             //               'More Details',
//             //               style: TextStyle(
//             //                   color: Colors.black,
//             //                   fontSize: 25,
//             //                   fontWeight: FontWeight.bold),
//             //               textAlign: TextAlign.center,
//             //             ),
//             //           ),
//             //         ),
//             //       ],
//             //     ),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }


