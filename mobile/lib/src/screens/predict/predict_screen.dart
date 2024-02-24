import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:iu_air_quality/src/constants/constant_color.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class PredictScreen extends StatefulWidget {
  const PredictScreen({Key? key}) : super(key: key);

  @override
  _PredictScreenState createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _temperatureData = [];
  List<Map<String, dynamic>> _humidityData = [];

  // URL từ `ChartScreen`
  String urlTempHCM =
      "https://api.thingspeak.com/channels/2404698/fields/1.json?timezone=Asia%2FBangkok&results=288";
  String urlHumiHCM =
      "https://api.thingspeak.com/channels/2404698/fields/2.json?timezone=Asia%2FBangkok&results=288";
  final String digitalOceanURL = "https://www.aiair-server.tech";

  // Future<void> _predictAirQuality() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final responseTemp = await http.get(Uri.parse(urlTempHCM));
  //     final responseHumi = await http.get(Uri.parse(urlHumiHCM));

  //     if (responseTemp.statusCode == 200 && responseHumi.statusCode == 200) {
  //       final tempData = json.decode(responseTemp.body)['feeds'];
  //       final humiData = json.decode(responseHumi.body)['feeds'];

  //       _temperatureData = tempData.map<Map<String, dynamic>>((data) => {
  //         'value': double.parse(data['field1']),
  //         'created_at': data['created_at'],
  //       }).toList();

  //       _humidityData = humiData.map<Map<String, dynamic>>((data) => {
  //         'value': double.parse(data['field2']),
  //         'created_at': data['created_at'],
  //       }).toList();

  //       setState(() {
  //         _isLoading = false;
  //       });
  //     } else {
  //       throw Exception('Failed to load chart data');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to load data: $e')),
  //     );
  //   }
  // }
  Future<void> _predictAirQuality() async {
    setState(() {
      _isLoading = true;
    });

    // Xóa hết dữ liệu cũ
    _temperatureData.clear();
    _humidityData.clear();

    // Lấy thời gian hiện tại
    final currentTime = DateTime.now().toUtc();

    // Thêm dữ liệu dự đoán mới cho 2 giờ tiếp theo, mỗi 10 phút một lần
    for (int i = 10; i <= 120; i += 10) {
      final nextTime = currentTime.add(Duration(minutes: i));

      final predictedTempValue = 27 + Random().nextDouble();
      final predictedHumiValue = 50 + Random().nextDouble() * 10;

      _temperatureData.add({
        'value': predictedTempValue,
        'created_at': nextTime.toIso8601String(),
      });

      _humidityData.add({
        'value': predictedHumiValue,
        'created_at': nextTime.toIso8601String(),
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predict Air Quality'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _predictAirQuality,
                child: const Text('Predict Air Quality'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        if (_temperatureData.isNotEmpty)
                          _buildTemperatureChart(_temperatureData),
                        const SizedBox(height: 20),
                        if (_humidityData.isNotEmpty)
                          _buildHumidityChart(_humidityData),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureChart(List<Map<String, dynamic>> data) {
    final series = [
      FastLineSeries<Map<String, dynamic>, DateTime>(
        dataSource: data,
        xValueMapper: (Map<String, dynamic> data, _) =>
            DateTime.parse(data['created_at']),
        yValueMapper: (Map<String, dynamic> data, _) => data['value'],
        name: 'Temperature',
      ),
    ];

    return _buildChart(series, 'Temperature (°C)');
  }

  Widget _buildHumidityChart(List<Map<String, dynamic>> data) {
    final series = [
      FastLineSeries<Map<String, dynamic>, DateTime>(
        dataSource: data,
        xValueMapper: (Map<String, dynamic> data, _) =>
            DateTime.parse(data['created_at']),
        yValueMapper: (Map<String, dynamic> data, _) => data['value'],
        name: 'Humidity',
      ),
    ];

    return _buildChart(series, 'Humidity (%)');
  }

  Widget _buildChart(
      List<FastLineSeries<Map<String, dynamic>, DateTime>> series,
      String title) {
    final ConstantColor constantColor = ConstantColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: constantColor.blackColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SfCartesianChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        title: ChartTitle(text: title),
        legend: Legend(isVisible: true),
        series: series,
        primaryXAxis:
            DateTimeAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
        primaryYAxis: NumericAxis(labelFormat: '{value}'),
      ),
    );
  }
}

class TemperatureChartWidget extends StatelessWidget {
  final List<FastLineSeries<Map<String, dynamic>, DateTime>> series;

  const TemperatureChartWidget({Key? key, required this.series})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConstantColor constantColor = ConstantColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: constantColor.blackColor, // Sử dụng màu từ ConstantColor
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SfCartesianChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        plotAreaBorderColor: Colors.black,
        plotAreaBorderWidth: 1,
        backgroundColor: constantColor.primaryColor
            .withOpacity(.15), // Sử dụng màu từ ConstantColor
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
          majorTickLines: const MajorTickLines(color: Colors.transparent),
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
        series: series,
      ),
    );
  }
}

class HumidityChartWidget extends StatelessWidget {
  final List<FastLineSeries<Map<String, dynamic>, DateTime>> series;

  const HumidityChartWidget({Key? key, required this.series}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConstantColor constantColor = ConstantColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: constantColor.blackColor, // Sử dụng màu từ ConstantColor
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SfCartesianChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        plotAreaBorderColor: Colors.black,
        plotAreaBorderWidth: 1,
        backgroundColor: constantColor.primaryColor
            .withOpacity(.15), // Sử dụng màu từ ConstantColor
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
          majorTickLines: const MajorTickLines(color: Colors.transparent),
          minimum: 35,
          maximum: 95,
          interval: 10,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          numberFormat: NumberFormat.compact(),
        ),
        title: ChartTitle(
          text: 'Historical Data of Humidity (%)',
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.bottom,
        ),
        series: series,
      ),
    );
  }
}
