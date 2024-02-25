import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:iu_air_quality/src/constants/constant_color.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final ConstantColor constantColor = ConstantColor();
  Map<String, dynamic> dataObject = {
    "station": [
      {
        "name": "TD",
        "attributes": [
          {"name": "temperature", "properties": []},
          {"name": "humidity", "properties": []},
          {"name": "CO2", "properties": []},
          {"name": "CO", "properties": []},
          {"name": "UV", "properties": []},
          {"name": "PM2.5", "properties": []},
        ],
      },
      {
        "name": "HCM",
        "attributes": [
          {"name": "temperature", "properties": []},
          {"name": "humidity", "properties": []},
          {"name": "CO2", "properties": []},
          {"name": "CO", "properties": []},
          {"name": "UV", "properties": []},
          {"name": "PM2.5", "properties": []},
        ],
      },
    ]
  };

  String formatInputStartDate =
      DateFormat('yyyy-MM-dd%2000:00:00').format(DateTime.now().toUtc());
  String formatInputEndDate =
      DateFormat('yyyy-MM-dd%2023:59:00').format(DateTime.now().toUtc());

  String urlTempHCM = "";
  String urlHumiHCM = "";
  String urlCO2HCM = "";
  String urlCOHCM = "";
  String urlUVHCM = "";
  String urlPM25HCM = "";

  String urlTempTD = "";
  String urlHumiTD = "";

  @override
  void initState() {
    super.initState();
    urlTempHCM =
        "https://api.thingspeak.com/channels/2404698/fields/1.json?timezone=Asia%2FBangkok&results=288&start=$formatInputStartDate&end=$formatInputEndDate";
    urlHumiHCM =
        "https://api.thingspeak.com/channels/2404698/fields/2.json?timezone=Asia%2FBangkok&results=288&start=$formatInputStartDate&end=$formatInputEndDate";
    urlCO2HCM =
        "https://api.thingspeak.com/channels/2404698/fields/3.json?timezone=Asia%2FBangkok&results=288&start=$formatInputStartDate&end=$formatInputEndDate";
    urlCOHCM =
        "https://api.thingspeak.com/channels/2404698/fields/4.json?timezone=Asia%2FBangkok&results=288&start=$formatInputStartDate&end=$formatInputEndDate";
    urlUVHCM =
        "https://api.thingspeak.com/channels/2404698/fields/5.json?timezone=Asia%2FBangkok&results=288&start=$formatInputStartDate&end=$formatInputEndDate";
    urlPM25HCM =
        "https://api.thingspeak.com/channels/2404698/fields/6.json?timezone=Asia%2FBangkok&results=288&start=$formatInputStartDate&end=$formatInputEndDate";

    urlTempTD =
        "https://api.thingspeak.com/channels/2115707/fields/1.json?timezone=Asia%2FBangkok&results=288&start=$formatInputStartDate&end=$formatInputEndDate";
    urlHumiTD =
        "https://api.thingspeak.com/channels/2115707/fields/2.json?timezone=Asia%2FBangkok&results=288&start=$formatInputStartDate&end=$formatInputEndDate";

    fetchDataHCM();
    fetchDataHumiHCM();
    fetchDataTD();
  }

  void fetchDataHumiHCM() async {
    try {
      var dataStation = dataObject['station'];
      var stationName = dataStation.firstWhere(
        (station) => station['name'] == 'HCM',
      );

      if (stationName != null) {
        var attHCM = stationName['attributes'];
        var humidityAttribute = attHCM.firstWhere(
          (attribute) => attribute['name'] == 'humidity',
        );
        if (humidityAttribute != null) {
          var responseHumi = await http.get(Uri.parse(urlHumiHCM));
          var jsonDataHumi = json.decode(responseHumi.body);
          var getFeedHumi = jsonDataHumi['feeds'] as List<dynamic>;
          List<Map<String, dynamic>> propertiesHumi = getFeedHumi.map((data) {
            return {
              'value': double.parse(data['field2']),
              'created_at': data['created_at'],
            };
          }).toList();
          humidityAttribute['properties'] = propertiesHumi;
        }
      }

      // Print updated jsonData for demonstration
      setState(() {
        dataObject = dataObject;
      });
    } catch (e) {
      print(e);
    }
  }

  void fetchDataHCM() async {
    try {
      var dataStation = dataObject['station'];
      var stationName = dataStation.firstWhere(
        (station) => station['name'] == 'HCM',
      );

      if (stationName != null) {
        var attHCM = stationName['attributes'];
        var temperatureAttribute = attHCM.firstWhere(
          (attribute) => attribute['name'] == 'temperature',
        );

        if (temperatureAttribute != null) {
          var responseTemp = await http.get(Uri.parse(urlTempHCM));
          var jsonDataTemp = json.decode(responseTemp.body);
          var getFeedTemp = jsonDataTemp['feeds'] as List<dynamic>;
          List<Map<String, dynamic>> propertiesTemp = getFeedTemp.map((data) {
            return {
              'value': double.parse(data['field1']),
              'created_at': data['created_at'],
            };
          }).toList();
          temperatureAttribute['properties'] = propertiesTemp;
        }

        var humidityAttribute = attHCM.firstWhere(
          (attribute) => attribute['name'] == 'humidity',
        );
        if (humidityAttribute != null) {
          var responseHumi = await http.get(Uri.parse(urlHumiHCM));
          var jsonDataHumi = json.decode(responseHumi.body);
          var getFeedHumi = jsonDataHumi['feeds'] as List<dynamic>;
          List<Map<String, dynamic>> propertiesHumi = getFeedHumi.map((data) {
            return {
              'value': double.parse(data['field2']),
              'created_at': data['created_at'],
            };
          }).toList();
          humidityAttribute['properties'] = propertiesHumi;
        }
      }

      // Print updated jsonData for demonstration
      // print(dataObject);

      setState(() {
        dataObject = dataObject;
      });
    } catch (e) {
      print(e);
    }
  }

  void fetchDataTD() async {
    try {
      var dataStation = dataObject['station'];
      var stationName = dataStation.firstWhere(
        (station) => station['name'] == 'TD',
      );

      if (stationName != null) {
        var attTD = stationName['attributes'];
        var temperatureAttribute = attTD.firstWhere(
          (attribute) => attribute['name'] == 'temperature',
        );

        if (temperatureAttribute != null) {
          var responseTemp = await http.get(Uri.parse(urlTempTD));
          var jsonData = json.decode(responseTemp.body);
          var getFeed = jsonData['feeds'] as List<dynamic>;

          List<Map<String, dynamic>> propertiesTemp = getFeed.map((data) {
            return {
              'value': double.parse(data['field1']),
              'created_at': data['created_at'],
            };
          }).toList();
          temperatureAttribute['properties'] = propertiesTemp;
        }

        var humidityAttribute = attTD.firstWhere(
          (attribute) => attribute['name'] == 'humidity',
        );
        if (humidityAttribute != null) {
          var responseHumi = await http.get(Uri.parse(urlHumiHCM));
          var jsonDataHumi = json.decode(responseHumi.body);
          var getFeedHumi = jsonDataHumi['feeds'] as List<dynamic>;
          List<Map<String, dynamic>> propertiesHumi = getFeedHumi.map((data) {
            return {
              'value': double.parse(data['field2']),
              'created_at': data['created_at'],
            };
          }).toList();
          humidityAttribute['properties'] = propertiesHumi;
        }
      }

      setState(() {
        dataObject = dataObject;
      });
    } catch (e) {
      print(e);
    }
  }

  List<FastLineSeries<Map<String, dynamic>, DateTime>> _getChartSeriesTemp() {
    final List<dynamic> stations = dataObject['station'];
    List<Map<String, dynamic>> temperatureDataHCM = [];
    List<Map<String, dynamic>> temperatureDataTD = [];
    // List<Map<String, dynamic>> humiHCM = [];

    for (var station in stations) {
      if (station['name'] == 'HCM') {
        var attributes = station['attributes'];
        for (var attribute in attributes) {
          if (attribute['name'] == 'temperature') {
            temperatureDataHCM =
                List<Map<String, dynamic>>.from(attribute['properties']);
          }

          // if (attribute['name'] == 'humidity') {
          //   humiHCM = List<Map<String, dynamic>>.from(attribute['properties']);
          // }
        }
      }
      if (station['name'] == 'TD') {
        var attributes = station['attributes'];
        for (var attribute in attributes) {
          if (attribute['name'] == 'temperature') {
            temperatureDataTD =
                List<Map<String, dynamic>>.from(attribute['properties']);
          }
        }
      }
    }

    // print(humiHCM);

    return [
      FastLineSeries<Map<String, dynamic>, DateTime>(
        dataSource: temperatureDataHCM,
        xValueMapper: (Map<String, dynamic> data, _) =>
            DateTime.parse(data['created_at']),
        yValueMapper: (Map<String, dynamic> data, _) => data['value'] as double,
        legendItemText: 'Ho Chi Minh',
        color: Colors.blue,
        enableTooltip: true,
      ),
      FastLineSeries<Map<String, dynamic>, DateTime>(
        dataSource: temperatureDataTD,
        xValueMapper: (Map<String, dynamic> data, _) =>
            DateTime.parse(data['created_at']),
        yValueMapper: (Map<String, dynamic> data, _) => data['value'] as double,
        legendItemText: 'Thu Duc',
        color: Colors.green,
        enableTooltip: true,
      ),
    ];
  }

  List<FastLineSeries<Map<String, dynamic>, DateTime>> _getChartSeriesHumi() {
    final List<dynamic> stations = dataObject['station'];
    List<Map<String, dynamic>> humidityDataHCM = [];
    List<Map<String, dynamic>> humidityDataTD = [];

    for (var station in stations) {
      if (station['name'] == 'HCM') {
        var attributes = station['attributes'];
        for (var attribute in attributes) {
          if (attribute['name'] == 'humidity') {
            humidityDataHCM =
                List<Map<String, dynamic>>.from(attribute['properties']);
          }
        }
      }
      if (station['name'] == 'TD') {
        var attributes = station['attributes'];
        for (var attribute in attributes) {
          if (attribute['name'] == 'humidity') {
            humidityDataTD =
                List<Map<String, dynamic>>.from(attribute['properties']);
          }
        }
      }
    }

    return [
      FastLineSeries<Map<String, dynamic>, DateTime>(
        dataSource: humidityDataHCM,
        xValueMapper: (Map<String, dynamic> data, _) =>
            DateTime.parse(data['created_at']),
        yValueMapper: (Map<String, dynamic> data, _) => data['value'] as double,
        legendItemText: 'Ho Chi Minh',
        color: Colors.blue,
        enableTooltip: true,
      ),
      // FastLineSeries<Map<String, dynamic>, DateTime>(
      //   dataSource: humidityDataTD,
      //   xValueMapper: (Map<String, dynamic> data, _) =>
      //       DateTime.parse(data['created_at']),
      //   yValueMapper: (Map<String, dynamic> data, _) => data['value'] as double,
      //   legendItemText: 'Thu Duc',
      //   color: Colors.green,
      //   enableTooltip: true,
      // ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        color: constantColor.primaryColor.withOpacity(.1),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: constantColor.blackColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SfCartesianChart(
                tooltipBehavior: TooltipBehavior(enable: true),
                plotAreaBorderColor: Colors.black,
                plotAreaBorderWidth: 1,
                backgroundColor: constantColor.primaryColor.withOpacity(.15),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePanning: true,
                  enableDoubleTapZooming: true,
                  enablePinching: true,
                ),
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat('HH:mm'),
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelFormat: '{value} °C',
                  axisLine: const AxisLine(width: 0),
                  majorTickLines:
                      const MajorTickLines(color: Colors.transparent),
                  minimum: 25,
                  maximum: 40,
                  interval: 5,
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  numberFormat: NumberFormat.compact(),
                ),
                title: ChartTitle(
                  text: 'Historical Data of Temperature (°C)',
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                series: _getChartSeriesTemp(),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: constantColor.blackColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SfCartesianChart(
                tooltipBehavior: TooltipBehavior(enable: true),
                plotAreaBorderColor: Colors.black,
                plotAreaBorderWidth: 1,
                backgroundColor: constantColor.primaryColor.withOpacity(.15),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePanning: true,
                  enableDoubleTapZooming: true,
                  enablePinching: true,
                ),
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat('HH:mm'),
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelFormat: '{value} %',
                  axisLine: const AxisLine(width: 0),
                  majorTickLines:
                      const MajorTickLines(color: Colors.transparent),
                  minimum: 35,
                  maximum: 95,
                  interval: 10,
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  numberFormat: NumberFormat.compact(),
                ),
                title: ChartTitle(
                  text: 'Historical Data of Humdity (%)',
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                series: _getChartSeriesHumi(),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
