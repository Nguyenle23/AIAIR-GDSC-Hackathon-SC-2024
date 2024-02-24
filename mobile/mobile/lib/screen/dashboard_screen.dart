import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class AirQualityDataHCM {
  String tempValue;
  String humiValue;
  String co2Value;
  String coValue;
  String pm25Value;
  String uvValue;
  String date;

  AirQualityDataHCM(
      {this.tempValue = "",
      this.humiValue = "",
      this.co2Value = "",
      this.coValue = "",
      this.pm25Value = "",
      this.uvValue = "",
      this.date = ""});
}

class AirQualityDataThuDuc {
  String tempValue;
  String humiValue;
  String co2Value;
  String coValue;
  String pm25Value;
  String uvValue;
  String date;

  AirQualityDataThuDuc(
      {this.tempValue = "",
      this.humiValue = "",
      this.co2Value = "",
      this.coValue = "",
      this.pm25Value = "",
      this.uvValue = "",
      this.date = ""});
}

class _DashboardScreenState extends State<DashboardScreen> {
  AirQualityDataHCM _airQualityDataHCM = AirQualityDataHCM();
  AirQualityDataThuDuc _airQualityDataThuDuc = AirQualityDataThuDuc();

  late Timer _timer;

  // get data from thingspeak
  getDataHCM() async {
    var url =
        "https://api.thingspeak.com/channels/2115707/feeds.json?results=1&timezone=Asia%2FBangkok";
    var response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );

    var data = response.body;
    var jsonData = json.decode(data);
    var getFeed = jsonData['feeds'];

    double tempValue = double.parse(getFeed[0]['field1']);
    double humiValue = double.parse(getFeed[0]['field2']);
    double co2Value = double.parse(getFeed[0]['field3']);
    double coValue = double.parse(getFeed[0]['field4']);
    double pm25Value = double.parse(getFeed[0]['field5']);
    double uvValue = double.parse(getFeed[0]['field6']);

    String formattedTemp = tempValue.toStringAsFixed(1);
    String formattedHumi = humiValue.toStringAsFixed(1);
    String formattedCO2 = co2Value.toStringAsFixed(4);
    String formattedCO = coValue.toStringAsFixed(4);
    String formattedPM25 = pm25Value.toStringAsFixed(4);
    String formattedUV = uvValue.toStringAsFixed(4);

    // for (var i = 0; i < getFeed.length; i++) {
    //   String dateTimeString = getFeed[i]['created_at'];
    //   DateTime dateTime = DateTime.parse(dateTimeString);
    //   String collectedDate = DateFormat('HH:mm').format(dateTime).toString();
    //   String indeAir = getFeed[i]['field1'];
    // }

    //formate date
    String dateTimeString = getFeed[0]['created_at'];
    DateTime dateTime =
        DateTime.parse(dateTimeString).toLocal(); // Convert to local time

    tz.Location asiaBangkok = tz.getLocation('Asia/Bangkok');
    tz.TZDateTime asiaBangkokTime = tz.TZDateTime.from(dateTime, asiaBangkok);
    String day = DateFormat('dd-MM-yyyy', 'en_US').format(dateTime).toString();
    String collectedDate = DateFormat('HH:mm:ss').format(dateTime).toString();
    String dayOfWeek =
        DateFormat('EEEE', 'en_US').format(asiaBangkokTime).toString();
    String amPm = DateFormat('a', 'en_US').format(asiaBangkokTime).toString();

    setState(() {
      _airQualityDataHCM = AirQualityDataHCM(
          tempValue: formattedTemp,
          humiValue: formattedHumi,
          co2Value: formattedCO2,
          coValue: formattedCO,
          pm25Value: formattedPM25,
          uvValue: formattedUV,
          date: "$day || $dayOfWeek || $collectedDate $amPm");
    });
  }

  getDataThuDuc() async {
    var url =
        "https://api.thingspeak.com/channels/2239030/feeds.json?results=1&timezone=Asia%2FBangkok";
    var response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );

    var data = response.body;

    var jsonData = json.decode(data);
    var getFeed = jsonData['feeds'];

    double tempValue = double.parse(getFeed[0]['field1']);
    double humiValue = double.parse(getFeed[0]['field2']);
    double co2Value = double.parse(getFeed[0]['field3']);
    double coValue = double.parse(getFeed[0]['field4']);
    double pm25Value = double.parse(getFeed[0]['field5']);
    double uvValue = double.parse(getFeed[0]['field6']);

    String formattedTemp = tempValue.toStringAsFixed(1);
    String formattedHumi = humiValue.toStringAsFixed(1);
    String formattedCO2 = co2Value.toStringAsFixed(4);
    String formattedCO = coValue.toStringAsFixed(4);
    String formattedPM25 = pm25Value.toStringAsFixed(4);
    String formattedUV = uvValue.toStringAsFixed(4);

    //formate date
    String dateTimeString = getFeed[0]['created_at'];
    DateTime dateTime =
        DateTime.parse(dateTimeString).toLocal(); // Convert to local time
    String collectedDate = DateFormat('HH:mm:ss').format(dateTime).toString();

    // Load the Asia/Bangkok time zone
    tz.Location asiaBangkok = tz.getLocation('Asia/Bangkok');

    // Convert the DateTime to Asia/Bangkok time zone
    tz.TZDateTime asiaBangkokTime = tz.TZDateTime.from(dateTime, asiaBangkok);

    // Get the day of the week in Asia/Bangkok time zone
    String dayOfWeek =
        DateFormat('EEEE', 'en_US').format(asiaBangkokTime).toString();

    //get the day-month-year in Asia/Bangkok time zone
    String day =
        DateFormat('dd-MM-yyyy', 'en_US').format(asiaBangkokTime).toString();

    // Format AM or PM in Asia/Bangkok time zone
    String amPm = DateFormat('a', 'en_US').format(asiaBangkokTime).toString();

    setState(() {
      _airQualityDataThuDuc = AirQualityDataThuDuc(
          tempValue: formattedTemp,
          humiValue: formattedHumi,
          co2Value: formattedCO2,
          coValue: formattedCO,
          pm25Value: formattedPM25,
          uvValue: formattedUV,
          date: "$day || $dayOfWeek || $collectedDate $amPm");
    });
  }

  //auto refresh
  @override
  void initState() {
    super.initState();
    getDataHCM();
    getDataThuDuc();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      getDataHCM();
      getDataThuDuc();
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the timer in the dispose method
    _timer.cancel();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 5,
              ),
              child: SizedBox(
                height: 80,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 5,
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: Colors.green,
                            size: 35,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 2,
                          ),
                          child: Center(
                              child: Text("Ho Chi Minh City",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontFamily: 'Kanit Regular 400'))),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 2,
                          ),
                          // child: Text("07 July 2023",
                          //     style: TextStyle(
                          //         fontSize: 20, fontFamily: 'Kanit Light')),
                          child: _airQualityDataHCM.date == ""
                              ? const Text("Loading...",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Kanit Regular 400'))
                              : Text(_airQualityDataHCM.date,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Kanit Medium 500')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //icon if the temperature is too high
            Padding(
              padding: const EdgeInsets.only(
                top: 5,
                left: 10,
                right: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                    ),
                    child: Text(
                      "Air Quality: ",
                      style: TextStyle(
                          fontSize: 30, fontFamily: 'Kanit Regular 400'),
                    ),
                  ),
                  _airQualityDataHCM.tempValue == "33"
                      ? Row(
                          children: const [
                            Icon(
                              Icons.mood_bad,
                              size: 50,
                            ),
                            Text(
                              "Bad",
                              style: TextStyle(
                                  fontSize: 30, fontFamily: 'Kanit Medium 500'),
                            ),
                          ],
                        )
                      : Row(
                          children: const [
                            Icon(
                              Icons.tag_faces_sharp,
                              size: 50,
                            ),
                            Text(
                              "Good",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'Kanit Medium 500',
                                  color: Colors.green),
                            ),
                          ],
                        )
                ],
              ),
            ),

            Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                  left: 10,
                  right: 5,
                  bottom: 10,
                ),
                child: DataTable(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset.zero,
                          blurRadius: 1,
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Parameter',
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Value',
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'Temperature',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataCell(
                          _airQualityDataHCM.tempValue == "0"
                              ? const Text(
                                  'Loading...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${_airQualityDataHCM.tempValue} °C",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'Humidity',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataCell(
                          _airQualityDataHCM.tempValue == "0"
                              ? const Text(
                                  'Loading...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${_airQualityDataHCM.humiValue} %",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'CO2 Value',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataCell(
                          _airQualityDataHCM.tempValue == "0"
                              ? const Text(
                                  'Loading...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${_airQualityDataHCM.co2Value} ppm",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'CO Value',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataCell(
                          _airQualityDataHCM.tempValue == "0"
                              ? const Text(
                                  'Loading...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${_airQualityDataHCM.coValue} ppm",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'UV Index',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataCell(
                          _airQualityDataHCM.tempValue == "0"
                              ? const Text(
                                  'Loading...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${_airQualityDataHCM.uvValue} mW/cm2",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'PM 2.5',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataCell(
                          _airQualityDataHCM.tempValue == "0"
                              ? const Text(
                                  'Loading...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${_airQualityDataHCM.pm25Value} µg/m3",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 19,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ]),
                    ])),

            //divider
            const Divider(
              height: 10,
              thickness: 5,
              indent: 20,
              endIndent: 20,
              color: Colors.black,
            ),

            Padding(
              padding: const EdgeInsets.only(
                top: 5,
              ),
              child: SizedBox(
                height: 80,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 5,
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: Colors.green,
                            size: 35,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 2,
                          ),
                          child: Center(
                              child: Text("Thu Duc City",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontFamily: 'Kanit Regular 400'))),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 2,
                          ),
                          // child: Text("07 July 2023",
                          //     style: TextStyle(
                          //         fontSize: 20, fontFamily: 'Kanit Light')),
                          child: _airQualityDataThuDuc.date == ""
                              ? const Text("Loading...",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Kanit Regular 400'))
                              : Text(_airQualityDataThuDuc.date,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Kanit Medium 500')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //icon if the temperature is too high
            Padding(
              padding: const EdgeInsets.only(
                top: 5,
                left: 10,
                right: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                    ),
                    child: Text(
                      "Air Quality: ",
                      style: TextStyle(
                          fontSize: 30, fontFamily: 'Kanit Regular 400'),
                    ),
                  ),
                  _airQualityDataThuDuc.tempValue == "33"
                      ? Row(
                          children: const [
                            Icon(
                              Icons.mood_bad,
                              size: 50,
                            ),
                            Text(
                              "Bad",
                              style: TextStyle(
                                  fontSize: 30, fontFamily: 'Kanit Medium 500'),
                            ),
                          ],
                        )
                      : Row(
                          children: const [
                            Icon(
                              Icons.tag_faces_sharp,
                              size: 50,
                            ),
                            Text(
                              "Good",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'Kanit Medium 500',
                                  color: Colors.green),
                            ),
                          ],
                        )
                ],
              ),
            ),

            Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                  left: 10,
                  right: 5,
                  bottom: 10,
                ),
                child: DataTable(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset.zero,
                          blurRadius: 1,
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Parameter',
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Value',
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'Temperature',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataCell(
                          _airQualityDataThuDuc.tempValue == "0"
                              ? const Text(
                                  'Loading...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${_airQualityDataThuDuc.tempValue} °C",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'Humidity',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataCell(
                          _airQualityDataThuDuc.tempValue == "0"
                              ? const Text(
                                  'Loading...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${_airQualityDataThuDuc.humiValue} %",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'CO2 Value',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataCell(
                          _airQualityDataThuDuc.tempValue == "0"
                              ? const Text(
                                  'Loading...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${_airQualityDataThuDuc.co2Value} ppm",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'CO Value',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataCell(
                          _airQualityDataThuDuc.tempValue == "0"
                              ? const Text(
                                  'Loading...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${_airQualityDataThuDuc.coValue} ppm",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'UV Index',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataCell(
                          _airQualityDataThuDuc.tempValue == "0"
                              ? const Text(
                                  'Loading...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${_airQualityDataThuDuc.uvValue} mW/cm2",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'PM 2.5',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DataCell(
                          _airQualityDataThuDuc.tempValue == "0"
                              ? const Text(
                                  'Loading...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${_airQualityDataThuDuc.pm25Value} µg/m3",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 19,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ]),
                    ])),

            //button predict
            Padding(
              padding: const EdgeInsets.only(
                top: 5,
                left: 100,
                right: 100,
              ),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset.zero,
                      blurRadius: 1,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const DashboardScreen()),
                          );
                        },
                        child: const Text(
                          'More Details',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
