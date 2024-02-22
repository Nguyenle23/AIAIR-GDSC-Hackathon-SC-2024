import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:flutter/gestures.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class AQIData {
  final String time;
  final String index;

  AQIData(this.time, this.index);
}

final dataAIQ = [
  AQIData("00:00", "00"),
  AQIData("00:00", "00"),
];

class _ChartScreenState extends State<ChartScreen> {
  final _monthDayFormat = DateFormat('MM-dd');
  var _airQualityIndex = '0';
  bool _isMounted = false;

  String formatInputStartDate =
      DateFormat('yyyy-MM-dd 00:00:00').format(DateTime.now().toUtc());
  String formatInputEndDate =
      DateFormat('yyyy-MM-dd 23:59:00').format(DateTime.now().toUtc());

  Future<String> getStringData({
    String start = '',
    String end = '',
  }) async {
    var url =
        "https://api.thingspeak.com/channels/2115707/fields/1.json?timezone=Asia%2FBangkok&results=288&start=$start&end=$end";
    var response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );

    return response.body;
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true; // Set to true when widget is mounted
    getAirQualityIndex();
  }

  @override
  void dispose() {
    super.dispose();
    _isMounted = false; // Set to false when widget is disposed
  }

  getAirQualityIndex() async {
    var data = await getStringData(
      start: formatInputStartDate,
      end: formatInputEndDate,
    );

    if (!_isMounted) return; // Check if widget is still mounted before setState

    var jsonData = json.decode(data);
    var getFeed = jsonData['feeds'];

    for (var i = 0; i < getFeed.length; i++) {
      String dateTimeString = getFeed[i]['created_at'];
      DateTime dateTime = DateTime.parse(dateTimeString);
      String collectedDate = DateFormat('HH:mm').format(dateTime).toString();
      String indeAir = getFeed[i]['field1'];
      addDataToAIQ(collectedDate, indeAir);
    }

    if (!_isMounted) return; // Check again before calling setState

    setState(() {
      _airQualityIndex = getFeed[0]['field1'];
    });
  }

  // draw chart
  void addDataToAIQ(String date, String airQualityIndex) {
    dataAIQ.add(AQIData(date, airQualityIndex));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding:
            //       const EdgeInsets.symmetric(vertical: 5.0, horizontal: 40),
            //   child: SizedBox(
            //     width: 300,
            //     height: 300,
            //     child: Chart(
            //       data: const [
            //         {'genre': 'Sports', 'sold': 275},
            //         {'genre': 'Strategy', 'sold': 115},
            //         {'genre': 'Action', 'sold': 120},
            //         {'genre': 'Shooter', 'sold': 350},
            //         {'genre': 'Other', 'sold': 150},
            //       ],
            //       variables: {
            //         'genre': Variable(
            //           accessor: (Map map) => map['genre'] as String,
            //         ),
            //         'sold': Variable(
            //           accessor: (Map map) => map['sold'] as num,
            //         ),
            //       },
            //       marks: [IntervalMark()],
            //       axes: [
            //         Defaults.horizontalAxis,
            //         Defaults.verticalAxis,
            //       ],
            //     ),
            //   ),
            // ),
            // const Padding(
            //   padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 150.0),
            //   child: Text(
            //     'Bar chart',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 30.0),
            //   child: Divider(
            //     thickness: 2,
            //     color: Color.fromARGB(255, 0, 0, 0),
            //   ),
            // ),

            // time-serie part
            Container(
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
              ),
              child: const Text(
                'Time series line chart for temperature (°C)',
                style: TextStyle(fontSize: 23, fontFamily: 'Kanit Regular 400'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              width: 350,
              height: 300,
              child: Chart(
                data: dataAIQ,
                variables: {
                  'Time': Variable(
                    accessor: (AQIData e) => e.time,
                  ),
                  'Index': Variable(
                    accessor: (AQIData e) => e.index,
                  ),
                },
                marks: [
                  LineMark(
                    shape: ShapeEncode(
                        value: BasicLineShape(
                      smooth: true,
                    )),
                    selected: {
                      'touchMove': {1}
                    },
                  )
                ],
                coord: RectCoord(color: Colors.white),
                axes: [
                  Defaults.horizontalAxis,
                  Defaults.verticalAxis,
                ],
                selections: {
                  'touchMove': PointSelection(
                    on: {
                      GestureType.scaleUpdate,
                      GestureType.tapDown,
                      GestureType.longPressMoveUpdate
                    },
                    dim: Dim.x,
                  )
                },
                tooltip: TooltipGuide(
                  followPointer: [false, true],
                  align: Alignment.topLeft,
                  offset: const Offset(-20, -20),
                ),
                crosshair: CrosshairGuide(followPointer: [false, true]),
              ),
            ),
            const SizedBox(height: 20),

            // Container(
            //   padding:
            //       const EdgeInsets.symmetric(horizontal: 100.0, vertical: 10),
            //   child: const Text(
            //     'Time series line chart',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 80.0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- Pre-select a point.',
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 80.0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- Dash line.',
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 80.0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- With time scale in domain dimension.',
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 80.0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- Input data type is a custom class.',
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 80.0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- With coordinate region background color.',
            //   ),
            // ),
            // Container(
            //   margin: const EdgeInsets.only(top: 10, left: 20),
            //   width: 350,
            //   height: 300,
            //   child: Chart(
            //     data: timeSeriesSales,
            //     variables: {
            //       'time': Variable(
            //         accessor: (TimeSeriesSales datum) => datum.time,
            //         scale: TimeScale(
            //           formatter: (time) => _monthDayFormat.format(time),
            //         ),
            //       ),
            //       'sales': Variable(
            //         accessor: (TimeSeriesSales datum) => datum.sales,
            //       ),
            //     },
            //     marks: [
            //       LineMark(
            //         shape: ShapeEncode(value: BasicLineShape(dash: [5, 2])),
            //         selected: {
            //           'touchMove': {1}
            //         },
            //       )
            //     ],
            //     coord: RectCoord(color: const Color(0xffdddddd)),
            //     axes: [
            //       Defaults.horizontalAxis,
            //       Defaults.verticalAxis,
            //     ],
            //     selections: {
            //       'touchMove': PointSelection(
            //         on: {
            //           GestureType.scaleUpdate,
            //           GestureType.tapDown,
            //           GestureType.longPressMoveUpdate
            //         },
            //         dim: Dim.x,
            //       )
            //     },
            //     tooltip: TooltipGuide(
            //       followPointer: [false, true],
            //       align: Alignment.topLeft,
            //       offset: const Offset(-20, -20),
            //     ),
            //     crosshair: CrosshairGuide(followPointer: [false, true]),
            //   ),
            // ),

            // Container(
            //   padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
            //   child: const Text(
            //     'Smooth Line and Area chart',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- Line and area will break at NaN.',
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- A touch moving triggerd selection.',
            //   ),
            // ),
            // Container(
            //   margin: const EdgeInsets.only(top: 10),
            //   width: 350,
            //   height: 300,
            //   child: Chart(
            //     data: invalidData,
            //     variables: {
            //       'Date': Variable(
            //         accessor: (Map map) => map['Date'] as String,
            //         scale: OrdinalScale(tickCount: 5),
            //       ),
            //       'Close': Variable(
            //         accessor: (Map map) => (map['Close'] ?? double.nan) as num,
            //       ),
            //     },
            //     marks: [
            //       AreaMark(
            //         shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
            //         color: ColorEncode(
            //             value: Defaults.colors10.first.withAlpha(80)),
            //       ),
            //       LineMark(
            //         shape: ShapeEncode(value: BasicLineShape(smooth: true)),
            //         size: SizeEncode(value: 0.5),
            //       ),
            //     ],
            //     axes: [
            //       Defaults.horizontalAxis,
            //       Defaults.verticalAxis,
            //     ],
            //     selections: {
            //       'touchMove': PointSelection(
            //         on: {
            //           GestureType.scaleUpdate,
            //           GestureType.tapDown,
            //           GestureType.longPressMoveUpdate
            //         },
            //         dim: Dim.x,
            //       )
            //     },
            //     tooltip: TooltipGuide(
            //       followPointer: [false, true],
            //       align: Alignment.topLeft,
            //       offset: const Offset(-20, -20),
            //     ),
            //     crosshair: CrosshairGuide(followPointer: [false, true]),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
            //   child: const Text(
            //     'Group interactions',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- Select and change color of a whole group',
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- The group and tooltip selections are different but triggerd by same gesture.',
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- Different interactions for different devices',
            //   ),
            // ),
            // Container(
            //   margin: const EdgeInsets.only(top: 10),
            //   width: 350,
            //   height: 300,
            //   child: Chart(
            //     data: complexGroupData,
            //     variables: {
            //       'date': Variable(
            //         accessor: (Map map) => map['date'] as String,
            //         scale: OrdinalScale(tickCount: 5, inflate: true),
            //       ),
            //       'points': Variable(
            //         accessor: (Map map) => map['points'] as num,
            //       ),
            //       'name': Variable(
            //         accessor: (Map map) => map['name'] as String,
            //       ),
            //     },
            //     coord: RectCoord(horizontalRange: [0.01, 0.99]),
            //     marks: [
            //       LineMark(
            //         position:
            //             Varset('date') * Varset('points') / Varset('name'),
            //         shape: ShapeEncode(value: BasicLineShape(smooth: true)),
            //         size: SizeEncode(value: 0.5),
            //         color: ColorEncode(
            //           variable: 'name',
            //           values: Defaults.colors10,
            //           updaters: {
            //             'groupMouse': {false: (color) => color.withAlpha(100)},
            //             'groupTouch': {false: (color) => color.withAlpha(100)},
            //           },
            //         ),
            //       ),
            //       PointMark(
            //         color: ColorEncode(
            //           variable: 'name',
            //           values: Defaults.colors10,
            //           updaters: {
            //             'groupMouse': {false: (color) => color.withAlpha(100)},
            //             'groupTouch': {false: (color) => color.withAlpha(100)},
            //           },
            //         ),
            //       ),
            //     ],
            //     axes: [
            //       Defaults.horizontalAxis,
            //       Defaults.verticalAxis,
            //     ],
            //     selections: {
            //       'tooltipMouse': PointSelection(on: {
            //         GestureType.hover,
            //       }, devices: {
            //         PointerDeviceKind.mouse
            //       }),
            //       'groupMouse': PointSelection(
            //           on: {
            //             GestureType.hover,
            //           },
            //           variable: 'name',
            //           devices: {PointerDeviceKind.mouse}),
            //       'tooltipTouch': PointSelection(on: {
            //         GestureType.scaleUpdate,
            //         GestureType.tapDown,
            //         GestureType.longPressMoveUpdate
            //       }, devices: {
            //         PointerDeviceKind.touch
            //       }),
            //       'groupTouch': PointSelection(
            //           on: {
            //             GestureType.scaleUpdate,
            //             GestureType.tapDown,
            //             GestureType.longPressMoveUpdate
            //           },
            //           variable: 'name',
            //           devices: {PointerDeviceKind.touch}),
            //     },
            //     tooltip: TooltipGuide(
            //       selections: {'tooltipTouch', 'tooltipMouse'},
            //       followPointer: [true, true],
            //       align: Alignment.topLeft,
            //       mark: 0,
            //       variables: [
            //         'date',
            //         'name',
            //         'points',
            //       ],
            //     ),
            //     crosshair: CrosshairGuide(
            //       selections: {'tooltipTouch', 'tooltipMouse'},
            //       styles: [
            //         PaintStyle(strokeColor: const Color(0xffbfbfbf)),
            //         PaintStyle(strokeColor: const Color(0x00bfbfbf)),
            //       ],
            //       followPointer: [true, false],
            //     ),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
            //   child: const Text(
            //     'River chart',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
            // Container(
            //   margin: const EdgeInsets.only(top: 10),
            //   width: 350,
            //   height: 300,
            //   child: Chart(
            //     data: riverData,
            //     variables: {
            //       'date': Variable(
            //         accessor: (List list) => list[0] as String,
            //         scale: OrdinalScale(tickCount: 5),
            //       ),
            //       'value': Variable(
            //         accessor: (List list) => list[1] as num,
            //         scale: LinearScale(min: -120, max: 120),
            //       ),
            //       'type': Variable(
            //         accessor: (List list) => list[2] as String,
            //       ),
            //     },
            //     marks: [
            //       AreaMark(
            //         position: Varset('date') * Varset('value') / Varset('type'),
            //         shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
            //         color: ColorEncode(
            //           variable: 'type',
            //           values: Defaults.colors10,
            //         ),
            //         modifiers: [StackModifier(), SymmetricModifier()],
            //       ),
            //     ],
            //     axes: [
            //       Defaults.horizontalAxis,
            //       Defaults.verticalAxis,
            //     ],
            //     selections: {
            //       'touchMove': PointSelection(
            //         on: {
            //           GestureType.scaleUpdate,
            //           GestureType.tapDown,
            //           GestureType.longPressMoveUpdate
            //         },
            //         dim: Dim.x,
            //         variable: 'date',
            //       )
            //     },
            //     tooltip: TooltipGuide(
            //       followPointer: [false, true],
            //       align: Alignment.topLeft,
            //       offset: const Offset(-20, -20),
            //       multiTuples: true,
            //       variables: ['type', 'value'],
            //     ),
            //     crosshair: CrosshairGuide(followPointer: [false, true]),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
            //   child: const Text(
            //     'Spider Net Chart',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- A loop connects the first and last point.',
            //   ),
            // ),
            // Container(
            //   margin: const EdgeInsets.only(top: 10),
            //   width: 350,
            //   height: 300,
            //   child: Chart(
            //     data: adjustData,
            //     variables: {
            //       'index': Variable(
            //         accessor: (Map map) => map['index'].toString(),
            //       ),
            //       'type': Variable(
            //         accessor: (Map map) => map['type'] as String,
            //       ),
            //       'value': Variable(
            //         accessor: (Map map) => map['value'] as num,
            //       ),
            //     },
            //     marks: [
            //       LineMark(
            //         position:
            //             Varset('index') * Varset('value') / Varset('type'),
            //         shape: ShapeEncode(value: BasicLineShape(loop: true)),
            //         color: ColorEncode(
            //             variable: 'type', values: Defaults.colors10),
            //       )
            //     ],
            //     coord: PolarCoord(),
            //     axes: [
            //       Defaults.circularAxis,
            //       Defaults.radialAxis,
            //     ],
            //     selections: {
            //       'touchMove': PointSelection(
            //         on: {
            //           GestureType.scaleUpdate,
            //           GestureType.tapDown,
            //           GestureType.longPressMoveUpdate
            //         },
            //         dim: Dim.x,
            //         variable: 'index',
            //       )
            //     },
            //     tooltip: TooltipGuide(
            //       anchor: (_) => Offset.zero,
            //       align: Alignment.bottomRight,
            //       multiTuples: true,
            //       variables: ['type', 'value'],
            //     ),
            //     crosshair: CrosshairGuide(followPointer: [false, true]),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
            //   child: const Text(
            //     'Interactive Scatter Chart',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- Tuples in various shapes for different types.',
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- Tap to toggle a multiple selecton.',
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- Scalable coordinate ranges.',
            //   ),
            // ),
            // Container(
            //   margin: const EdgeInsets.only(top: 10),
            //   width: 350,
            //   height: 300,
            //   child: Chart(
            //     data: scatterData,
            //     variables: {
            //       '0': Variable(
            //         accessor: (List datum) => datum[0] as num,
            //       ),
            //       '1': Variable(
            //         accessor: (List datum) => datum[1] as num,
            //       ),
            //       '2': Variable(
            //         accessor: (List datum) => datum[2] as num,
            //       ),
            //       '4': Variable(
            //         accessor: (List datum) => datum[4].toString(),
            //       ),
            //     },
            //     marks: [
            //       PointMark(
            //         size: SizeEncode(variable: '2', values: [5, 20]),
            //         color: ColorEncode(
            //           variable: '4',
            //           values: Defaults.colors10,
            //           updaters: {
            //             'choose': {true: (_) => Colors.red}
            //           },
            //         ),
            //         shape: ShapeEncode(variable: '4', values: [
            //           CircleShape(hollow: true),
            //           SquareShape(hollow: true),
            //         ]),
            //       )
            //     ],
            //     axes: [
            //       Defaults.horizontalAxis,
            //       Defaults.verticalAxis,
            //     ],
            //     coord: RectCoord(
            //       horizontalRange: [0.05, 0.95],
            //       verticalRange: [0.05, 0.95],
            //       horizontalRangeUpdater: Defaults.horizontalRangeEvent,
            //       verticalRangeUpdater: Defaults.verticalRangeEvent,
            //     ),
            //     selections: {'choose': PointSelection(toggle: true)},
            //     tooltip: TooltipGuide(
            //       anchor: (_) => Offset.zero,
            //       align: Alignment.bottomRight,
            //       multiTuples: true,
            //     ),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
            //   child: const Text(
            //     'Interval selection',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- Pan to trigger an interval selection.',
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- Note to pan horizontally first to avoid conflict with the scroll view.',
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- Axis lines set to middle of the coordinate region.',
            //   ),
            // ),
            // Container(
            //   margin: const EdgeInsets.only(top: 10),
            //   width: 350,
            //   height: 300,
            //   child: Chart(
            //     data: scatterData,
            //     variables: {
            //       '0': Variable(
            //         accessor: (List datum) => datum[0] as num,
            //       ),
            //       '1': Variable(
            //         accessor: (List datum) => datum[1] as num,
            //       ),
            //       '2': Variable(
            //         accessor: (List datum) => datum[2] as num,
            //       ),
            //       '4': Variable(
            //         accessor: (List datum) => datum[4].toString(),
            //       ),
            //     },
            //     marks: [
            //       PointMark(
            //         size: SizeEncode(variable: '2', values: [5, 20]),
            //         color: ColorEncode(
            //           variable: '4',
            //           values: Defaults.colors10,
            //           updaters: {
            //             'choose': {true: (_) => Colors.red}
            //           },
            //         ),
            //         shape: ShapeEncode(variable: '4', values: [
            //           CircleShape(hollow: true),
            //           SquareShape(hollow: true),
            //         ]),
            //       )
            //     ],
            //     axes: [
            //       Defaults.horizontalAxis
            //         ..position = 0.5
            //         ..grid = null
            //         ..line = Defaults.strokeStyle,
            //       Defaults.verticalAxis
            //         ..position = 0.5
            //         ..grid = null
            //         ..line = Defaults.strokeStyle,
            //     ],
            //     coord: RectCoord(
            //       horizontalRange: [0.05, 0.95],
            //       verticalRange: [0.05, 0.95],
            //     ),
            //     selections: {'choose': IntervalSelection()},
            //     tooltip: TooltipGuide(
            //       anchor: (_) => Offset.zero,
            //       align: Alignment.bottomRight,
            //       multiTuples: true,
            //     ),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
            //   child: const Text(
            //     'Polar Scatter Chart',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            //   alignment: Alignment.centerLeft,
            //   child: const Text(
            //     '- A red danger tag marks a position.',
            //   ),
            // ),
            // Container(
            //   margin: const EdgeInsets.only(top: 10),
            //   width: 350,
            //   height: 300,
            //   child: Chart(
            //     data: scatterData,
            //     variables: {
            //       '0': Variable(
            //         accessor: (List datum) => datum[0] as num,
            //         scale: LinearScale(min: 0, max: 80000, tickCount: 8),
            //       ),
            //       '1': Variable(
            //         accessor: (List datum) => datum[1] as num,
            //       ),
            //       '2': Variable(
            //         accessor: (List datum) => datum[2] as num,
            //       ),
            //       '4': Variable(
            //         accessor: (List datum) => datum[4].toString(),
            //       ),
            //     },
            //     marks: [
            //       PointMark(
            //         size: SizeEncode(variable: '2', values: [5, 20]),
            //         color: ColorEncode(
            //           variable: '4',
            //           values: Defaults.colors10,
            //           updaters: {
            //             'choose': {true: (_) => Colors.red}
            //           },
            //         ),
            //         shape: ShapeEncode(variable: '4', values: [
            //           CircleShape(hollow: true),
            //           SquareShape(hollow: true),
            //         ]),
            //       )
            //     ],
            //     axes: [
            //       Defaults.circularAxis
            //         ..labelMapper = (_, index, total) {
            //           if (index == total - 1) {
            //             return null;
            //           }
            //           return LabelStyle(textStyle: Defaults.textStyle);
            //         }
            //         ..label = null,
            //       Defaults.radialAxis
            //         ..labelMapper = (_, index, total) {
            //           if (index == total - 1) {
            //             return null;
            //           }
            //           return LabelStyle(textStyle: Defaults.textStyle);
            //         }
            //         ..label = null,
            //     ],
            //     coord: PolarCoord(),
            //     selections: {'choose': PointSelection(toggle: true)},
            //     tooltip: TooltipGuide(
            //       anchor: (_) => Offset.zero,
            //       align: Alignment.bottomRight,
            //       multiTuples: true,
            //     ),
            //     annotations: [
            //       TagAnnotation(
            //         label: Label(
            //             'DANGER',
            //             LabelStyle(
            //                 textStyle: const TextStyle(
            //               color: Colors.red,
            //               fontSize: 12,
            //             ))),
            //         values: [45000, 65],
            //       )
            //     ],
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
            //   child: const Text(
            //     '1D Scatter Chart',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
            // Container(
            //   margin: const EdgeInsets.only(top: 10),
            //   width: 350,
            //   height: 300,
            //   child: Chart(
            //     data: const [65, 43, 22, 11],
            //     variables: {
            //       'value': Variable(
            //         accessor: (num value) => value,
            //         scale: LinearScale(min: 0),
            //       ),
            //     },
            //     marks: [
            //       PointMark(
            //         position: Varset('value'),
            //       )
            //     ],
            //     axes: [
            //       Defaults.verticalAxis,
            //     ],
            //     coord: RectCoord(dimCount: 1),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}

final timeSeriesSales = [
  TimeSeriesSales(DateTime(2017, 9, 19), 5),
  TimeSeriesSales(DateTime(2017, 9, 26), 25),
  TimeSeriesSales(DateTime(2017, 10, 3), 100),
  TimeSeriesSales(DateTime(2017, 10, 10), 75),
];

const complexGroupData = [
  {'date': '2021-10-01', 'name': 'Liam', 'points': 1468},
  {'date': '2021-10-01', 'name': 'Oliver', 'points': 1487},
  {'date': '2021-10-01', 'name': 'Elijah', 'points': 1494},
  {'date': '2021-10-02', 'name': 'Liam', 'points': 1526},
  {'date': '2021-10-02', 'name': 'Noah', 'points': 1492},
  {'date': '2021-10-02', 'name': 'Oliver', 'points': 1470},
  {'date': '2021-10-02', 'name': 'Elijah', 'points': 1477},
  {'date': '2021-10-03', 'name': 'Liam', 'points': 1466},
  {'date': '2021-10-03', 'name': 'Noah', 'points': 1465},
  {'date': '2021-10-03', 'name': 'Oliver', 'points': 1524},
  {'date': '2021-10-03', 'name': 'Elijah', 'points': 1534},
  {'date': '2021-10-04', 'name': 'Noah', 'points': 1504},
  {'date': '2021-10-04', 'name': 'Elijah', 'points': 1524},
  {'date': '2021-10-05', 'name': 'Oliver', 'points': 1534},
  {'date': '2021-10-06', 'name': 'Noah', 'points': 1463},
  {'date': '2021-10-07', 'name': 'Liam', 'points': 1502},
  {'date': '2021-10-07', 'name': 'Noah', 'points': 1539},
  {'date': '2021-10-08', 'name': 'Liam', 'points': 1476},
  {'date': '2021-10-08', 'name': 'Noah', 'points': 1483},
  {'date': '2021-10-08', 'name': 'Oliver', 'points': 1534},
  {'date': '2021-10-08', 'name': 'Elijah', 'points': 1530},
  {'date': '2021-10-09', 'name': 'Noah', 'points': 1519},
  {'date': '2021-10-09', 'name': 'Oliver', 'points': 1497},
  {'date': '2021-10-09', 'name': 'Elijah', 'points': 1460},
  {'date': '2021-10-10', 'name': 'Liam', 'points': 1514},
  {'date': '2021-10-10', 'name': 'Noah', 'points': 1518},
  {'date': '2021-10-10', 'name': 'Oliver', 'points': 1470},
  {'date': '2021-10-10', 'name': 'Elijah', 'points': 1526},
  {'date': '2021-10-11', 'name': 'Liam', 'points': 1517},
  {'date': '2021-10-11', 'name': 'Noah', 'points': 1478},
  {'date': '2021-10-11', 'name': 'Oliver', 'points': 1468},
  {'date': '2021-10-11', 'name': 'Elijah', 'points': 1487},
  {'date': '2021-10-12', 'name': 'Liam', 'points': 1535},
  {'date': '2021-10-12', 'name': 'Noah', 'points': 1537},
  {'date': '2021-10-12', 'name': 'Oliver', 'points': 1463},
  {'date': '2021-10-12', 'name': 'Elijah', 'points': 1478},
  {'date': '2021-10-13', 'name': 'Oliver', 'points': 1524},
  {'date': '2021-10-13', 'name': 'Elijah', 'points': 1496},
  {'date': '2021-10-14', 'name': 'Liam', 'points': 1527},
  {'date': '2021-10-14', 'name': 'Oliver', 'points': 1527},
  {'date': '2021-10-14', 'name': 'Elijah', 'points': 1462},
  {'date': '2021-10-15', 'name': 'Liam', 'points': 1532},
  {'date': '2021-10-15', 'name': 'Noah', 'points': 1509},
  {'date': '2021-10-15', 'name': 'Oliver', 'points': 1540},
  {'date': '2021-10-15', 'name': 'Elijah', 'points': 1536},
  {'date': '2021-10-16', 'name': 'Liam', 'points': 1480},
  {'date': '2021-10-16', 'name': 'Elijah', 'points': 1533},
  {'date': '2021-10-17', 'name': 'Noah', 'points': 1515},
  {'date': '2021-10-17', 'name': 'Oliver', 'points': 1518},
  {'date': '2021-10-17', 'name': 'Elijah', 'points': 1515},
  {'date': '2021-10-18', 'name': 'Oliver', 'points': 1489},
  {'date': '2021-10-18', 'name': 'Elijah', 'points': 1518},
  {'date': '2021-10-19', 'name': 'Oliver', 'points': 1472},
  {'date': '2021-10-19', 'name': 'Elijah', 'points': 1473},
  {'date': '2021-10-20', 'name': 'Liam', 'points': 1513},
  {'date': '2021-10-20', 'name': 'Noah', 'points': 1533},
  {'date': '2021-10-20', 'name': 'Oliver', 'points': 1487},
  {'date': '2021-10-20', 'name': 'Elijah', 'points': 1532},
  {'date': '2021-10-21', 'name': 'Liam', 'points': 1497},
  {'date': '2021-10-21', 'name': 'Noah', 'points': 1477},
  {'date': '2021-10-21', 'name': 'Oliver', 'points': 1516},
  {'date': '2021-10-22', 'name': 'Liam', 'points': 1466},
  {'date': '2021-10-22', 'name': 'Noah', 'points': 1476},
  {'date': '2021-10-22', 'name': 'Oliver', 'points': 1536},
  {'date': '2021-10-22', 'name': 'Elijah', 'points': 1483},
  {'date': '2021-10-23', 'name': 'Liam', 'points': 1503},
  {'date': '2021-10-23', 'name': 'Oliver', 'points': 1521},
  {'date': '2021-10-23', 'name': 'Elijah', 'points': 1529},
  {'date': '2021-10-24', 'name': 'Liam', 'points': 1460},
  {'date': '2021-10-24', 'name': 'Noah', 'points': 1532},
  {'date': '2021-10-24', 'name': 'Oliver', 'points': 1477},
  {'date': '2021-10-24', 'name': 'Elijah', 'points': 1470},
  {'date': '2021-10-25', 'name': 'Noah', 'points': 1504},
  {'date': '2021-10-25', 'name': 'Oliver', 'points': 1494},
  {'date': '2021-10-25', 'name': 'Elijah', 'points': 1528},
  {'date': '2021-10-26', 'name': 'Liam', 'points': 1517},
  {'date': '2021-10-26', 'name': 'Noah', 'points': 1503},
  {'date': '2021-10-26', 'name': 'Elijah', 'points': 1507},
  {'date': '2021-10-27', 'name': 'Liam', 'points': 1538},
  {'date': '2021-10-27', 'name': 'Noah', 'points': 1530},
  {'date': '2021-10-27', 'name': 'Oliver', 'points': 1496},
  {'date': '2021-10-27', 'name': 'Elijah', 'points': 1519},
  {'date': '2021-10-28', 'name': 'Liam', 'points': 1511},
  {'date': '2021-10-28', 'name': 'Oliver', 'points': 1500},
  {'date': '2021-10-28', 'name': 'Elijah', 'points': 1519},
  {'date': '2021-10-29', 'name': 'Noah', 'points': 1499},
  {'date': '2021-10-29', 'name': 'Oliver', 'points': 1489},
  {'date': '2021-10-30', 'name': 'Noah', 'points': 1460}
];

const invalidData = [
  {"Date": "04.01.2016", "Close": 126.12},
  {"Date": "05.01.2016", "Close": 125.688},
  {"Date": "06.01.2016", "Close": 119.704},
  {"Date": "07.01.2016", "Close": 120.19},
  {"Date": "08.01.2016", "Close": 121.157},
  {"Date": "11.01.2016", "Close": 117},
  {"Date": "12.01.2016", "Close": 120},
  {"Date": "13.01.2016", "Close": 122},
  {"Date": "14.01.2016", "Close": 117.76},
  {"Date": "15.01.2016", "Close": 114.397},
  {"Date": "18.01.2016", "Close": 116.373},
  {"Date": "19.01.2016", "Close": 120.547},
  {"Date": "20.01.2016", "Close": 113.733},
  {"Date": "21.01.2016", "Close": 114.098},
  {"Date": "22.01.2016", "Close": 123.833},
  {"Date": "25.01.2016", "Close": 125},
  {"Date": "26.01.2016", "Close": 124.866},
  {"Date": "27.01.2016", "Close": 120.264},
  {"Date": "28.01.2016", "Close": 122.296},
  {"Date": "29.01.2016", "Close": 124.502},
  {"Date": "01.02.2016", "Close": 127.936},
  {"Date": "02.02.2016", "Close": null},
  {"Date": "03.02.2016", "Close": 129.95},
  {"Date": "04.02.2016", "Close": 129.275},
  {"Date": "05.02.2016", "Close": 127.898},
  {"Date": "08.02.2016", "Close": 134.9},
  {"Date": "09.02.2016", "Close": 122.819},
  {"Date": "10.02.2016", "Close": 120.108},
  {"Date": "11.02.2016", "Close": 119.447},
  {"Date": "12.02.2016", "Close": 117.8},
  {"Date": "15.02.2016", "Close": 122.8},
  {"Date": "16.02.2016", "Close": 121.865},
  {"Date": "17.02.2016", "Close": 126.3},
  {"Date": "18.02.2016", "Close": 128.259},
  {"Date": "19.02.2016", "Close": 125.724},
  {"Date": "22.02.2016", "Close": 130},
  {"Date": "23.02.2016", "Close": 129.948},
  {"Date": "24.02.2016", "Close": 132.5},
  {"Date": "25.02.2016", "Close": 128.08},
  {"Date": "26.02.2016", "Close": 122},
  {"Date": "29.02.2016", "Close": 122},
  {"Date": "01.03.2016", "Close": 123.449},
  {"Date": "02.03.2016", "Close": double.nan},
  {"Date": "03.03.2016", "Close": 132},
  {"Date": "04.03.2016", "Close": 135},
  {"Date": "07.03.2016", "Close": 123.905},
  {"Date": "08.03.2016", "Close": 125.155},
  {"Date": "09.03.2016", "Close": 126},
  {"Date": "10.03.2016", "Close": 126.778},
  {"Date": "11.03.2016", "Close": 129.656},
  {"Date": "14.03.2016", "Close": 127.64},
  {"Date": "15.03.2016", "Close": 124.786},
  {"Date": "16.03.2016", "Close": 124.469},
  {"Date": "17.03.2016", "Close": 123.5},
  {"Date": "18.03.2016", "Close": 124.061},
  {"Date": "21.03.2016", "Close": 123.5},
  {"Date": "22.03.2016", "Close": 129.002},
  {"Date": "23.03.2016", "Close": 129},
  {"Date": "24.03.2016", "Close": 131.31},
  {"Date": "29.03.2016", "Close": 133},
  {"Date": "30.03.2016", "Close": 129.298},
  {"Date": "31.03.2016", "Close": 127.4},
  {"Date": "01.04.2016", "Close": 122.376},
  {"Date": "04.04.2016", "Close": 119.467},
  {"Date": "05.04.2016", "Close": 120.695},
  {"Date": "06.04.2016", "Close": 118.725},
  {"Date": "07.04.2016", "Close": 127.539},
  {"Date": "08.04.2016", "Close": 129.8},
  {"Date": "11.04.2016", "Close": 129.5},
  {"Date": "12.04.2016", "Close": 134.465},
  {"Date": "13.04.2016", "Close": 133},
  {"Date": "14.04.2016", "Close": 137.35},
  {"Date": "15.04.2016", "Close": 137.2},
  {"Date": "18.04.2016", "Close": 132.611},
  {"Date": "19.04.2016", "Close": 135.479},
  {"Date": "20.04.2016", "Close": 139.05},
  {"Date": "21.04.2016", "Close": 142},
  {"Date": "22.04.2016", "Close": 135.761},
  {"Date": "25.04.2016", "Close": 136.174},
  {"Date": "26.04.2016", "Close": 134.782},
  {"Date": "27.04.2016", "Close": 128},
  {"Date": "28.04.2016", "Close": 121.5},
  {"Date": "29.04.2016", "Close": 120},
  {"Date": "02.05.2016", "Close": 123.966},
  {"Date": "03.05.2016", "Close": 122.538},
  {"Date": "04.05.2016", "Close": 120},
  {"Date": "05.05.2016", "Close": 120.21},
  {"Date": "06.05.2016", "Close": 121.01},
  {"Date": "09.05.2016", "Close": double.nan},
  {"Date": "10.05.2016", "Close": 120.622},
  {"Date": "11.05.2016", "Close": 123.85},
  {"Date": "12.05.2016", "Close": 122.963},
  {"Date": "13.05.2016", "Close": 126},
  {"Date": "17.05.2016", "Close": 130},
  {"Date": "18.05.2016", "Close": 128.845},
  {"Date": "19.05.2016", "Close": 130.17},
  {"Date": "20.05.2016", "Close": 129.741},
  {"Date": "23.05.2016", "Close": 129.668},
  {"Date": "24.05.2016", "Close": 126.886},
  {"Date": "25.05.2016", "Close": 128.239},
  {"Date": "26.05.2016", "Close": 127.239},
  {"Date": "27.05.2016", "Close": 127.457},
  {"Date": "30.05.2016", "Close": 127.37},
  {"Date": "31.05.2016", "Close": 130.756},
  {"Date": "01.06.2016", "Close": 133.232},
  {"Date": "02.06.2016", "Close": 126.47},
  {"Date": "03.06.2016", "Close": 126.385},
  {"Date": "06.06.2016", "Close": 128.331},
  {"Date": "07.06.2016", "Close": 130.914},
  {"Date": "08.06.2016", "Close": 133},
  {"Date": "09.06.2016", "Close": 133.041},
  {"Date": "10.06.2016", "Close": 133.041},
  {"Date": "13.06.2016", "Close": 129},
  {"Date": "14.06.2016", "Close": 129.166},
  {"Date": "15.06.2016", "Close": 124.687},
  {"Date": "16.06.2016", "Close": 122.77},
  {"Date": "17.06.2016", "Close": 126.461},
  {"Date": "20.06.2016", "Close": 127},
  {"Date": "21.06.2016", "Close": 125.594},
  {"Date": "22.06.2016", "Close": 127.438},
  {"Date": "23.06.2016", "Close": 124.44},
  {"Date": "24.06.2016", "Close": 122.131},
  {"Date": "27.06.2016", "Close": 120.53},
  {"Date": "28.06.2016", "Close": 120.296},
  {"Date": "29.06.2016", "Close": 125.877},
  {"Date": "30.06.2016", "Close": 126.404},
];

const riverData = [
  ['2015/11/08', 10, 'DQ'],
  ['2015/11/09', 15, 'DQ'],
  ['2015/11/10', 35, 'DQ'],
  ['2015/11/11', 38, 'DQ'],
  ['2015/11/12', 22, 'DQ'],
  ['2015/11/13', 16, 'DQ'],
  ['2015/11/14', 7, 'DQ'],
  ['2015/11/15', 2, 'DQ'],
  ['2015/11/16', 17, 'DQ'],
  ['2015/11/17', 33, 'DQ'],
  ['2015/11/18', 40, 'DQ'],
  ['2015/11/19', 32, 'DQ'],
  ['2015/11/20', 26, 'DQ'],
  ['2015/11/21', 35, 'DQ'],
  ['2015/11/22', 40, 'DQ'],
  ['2015/11/23', 32, 'DQ'],
  ['2015/11/24', 26, 'DQ'],
  ['2015/11/25', 22, 'DQ'],
  ['2015/11/26', 16, 'DQ'],
  ['2015/11/27', 22, 'DQ'],
  ['2015/11/28', 10, 'DQ'],
  ['2015/11/08', 35, 'TY'],
  ['2015/11/09', 36, 'TY'],
  ['2015/11/10', 37, 'TY'],
  ['2015/11/11', 22, 'TY'],
  ['2015/11/12', 24, 'TY'],
  ['2015/11/13', 26, 'TY'],
  ['2015/11/14', 34, 'TY'],
  ['2015/11/15', 21, 'TY'],
  ['2015/11/16', 18, 'TY'],
  ['2015/11/17', 45, 'TY'],
  ['2015/11/18', 32, 'TY'],
  ['2015/11/19', 35, 'TY'],
  ['2015/11/20', 30, 'TY'],
  ['2015/11/21', 28, 'TY'],
  ['2015/11/22', 27, 'TY'],
  ['2015/11/23', 26, 'TY'],
  ['2015/11/24', 15, 'TY'],
  ['2015/11/25', 30, 'TY'],
  ['2015/11/26', 35, 'TY'],
  ['2015/11/27', 42, 'TY'],
  ['2015/11/28', 42, 'TY'],
  ['2015/11/08', 21, 'SS'],
  ['2015/11/09', 25, 'SS'],
  ['2015/11/10', 27, 'SS'],
  ['2015/11/11', 23, 'SS'],
  ['2015/11/12', 24, 'SS'],
  ['2015/11/13', 21, 'SS'],
  ['2015/11/14', 35, 'SS'],
  ['2015/11/15', 39, 'SS'],
  ['2015/11/16', 40, 'SS'],
  ['2015/11/17', 36, 'SS'],
  ['2015/11/18', 33, 'SS'],
  ['2015/11/19', 43, 'SS'],
  ['2015/11/20', 40, 'SS'],
  ['2015/11/21', 34, 'SS'],
  ['2015/11/22', 28, 'SS'],
  ['2015/11/23', 26, 'SS'],
  ['2015/11/24', 37, 'SS'],
  ['2015/11/25', 41, 'SS'],
  ['2015/11/26', 46, 'SS'],
  ['2015/11/27', 47, 'SS'],
  ['2015/11/28', 41, 'SS'],
  ['2015/11/08', 10, 'QG'],
  ['2015/11/09', 15, 'QG'],
  ['2015/11/10', 35, 'QG'],
  ['2015/11/11', 38, 'QG'],
  ['2015/11/12', 22, 'QG'],
  ['2015/11/13', 16, 'QG'],
  ['2015/11/14', 7, 'QG'],
  ['2015/11/15', 2, 'QG'],
  ['2015/11/16', 17, 'QG'],
  ['2015/11/17', 33, 'QG'],
  ['2015/11/18', 40, 'QG'],
  ['2015/11/19', 32, 'QG'],
  ['2015/11/20', 26, 'QG'],
  ['2015/11/21', 35, 'QG'],
  ['2015/11/22', 40, 'QG'],
  ['2015/11/23', 32, 'QG'],
  ['2015/11/24', 26, 'QG'],
  ['2015/11/25', 22, 'QG'],
  ['2015/11/26', 16, 'QG'],
  ['2015/11/27', 22, 'QG'],
  ['2015/11/28', 10, 'QG'],
  ['2015/11/08', 10, 'SY'],
  ['2015/11/09', 15, 'SY'],
  ['2015/11/10', 35, 'SY'],
  ['2015/11/11', 38, 'SY'],
  ['2015/11/12', 22, 'SY'],
  ['2015/11/13', 16, 'SY'],
  ['2015/11/14', 7, 'SY'],
  ['2015/11/15', 2, 'SY'],
  ['2015/11/16', 17, 'SY'],
  ['2015/11/17', 33, 'SY'],
  ['2015/11/18', 40, 'SY'],
  ['2015/11/19', 32, 'SY'],
  ['2015/11/20', 26, 'SY'],
  ['2015/11/21', 35, 'SY'],
  ['2015/11/22', 4, 'SY'],
  ['2015/11/23', 32, 'SY'],
  ['2015/11/24', 26, 'SY'],
  ['2015/11/25', 22, 'SY'],
  ['2015/11/26', 16, 'SY'],
  ['2015/11/27', 22, 'SY'],
  ['2015/11/28', 10, 'SY'],
  ['2015/11/08', 10, 'DD'],
  ['2015/11/09', 15, 'DD'],
  ['2015/11/10', 35, 'DD'],
  ['2015/11/11', 38, 'DD'],
  ['2015/11/12', 22, 'DD'],
  ['2015/11/13', 16, 'DD'],
  ['2015/11/14', 7, 'DD'],
  ['2015/11/15', 2, 'DD'],
  ['2015/11/16', 17, 'DD'],
  ['2015/11/17', 33, 'DD'],
  ['2015/11/18', 4, 'DD'],
  ['2015/11/19', 32, 'DD'],
  ['2015/11/20', 26, 'DD'],
  ['2015/11/21', 35, 'DD'],
  ['2015/11/22', 40, 'DD'],
  ['2015/11/23', 32, 'DD'],
  ['2015/11/24', 26, 'DD'],
  ['2015/11/25', 22, 'DD'],
  ['2015/11/26', 16, 'DD'],
  ['2015/11/27', 22, 'DD'],
  ['2015/11/28', 10, 'DD']
];

const adjustData = [
  {"type": "Email", "index": 0, "value": 120},
  {"type": "Email", "index": 1, "value": 132},
  {"type": "Email", "index": 2, "value": 101},
  {"type": "Email", "index": 3, "value": 134},
  {"type": "Email", "index": 4, "value": 90},
  {"type": "Email", "index": 5, "value": 230},
  {"type": "Email", "index": 6, "value": 210},
  {"type": "Affiliate", "index": 0, "value": 220},
  {"type": "Affiliate", "index": 1, "value": 182},
  {"type": "Affiliate", "index": 2, "value": 191},
  {"type": "Affiliate", "index": 3, "value": 234},
  {"type": "Affiliate", "index": 4, "value": 290},
  {"type": "Affiliate", "index": 5, "value": 330},
  {"type": "Affiliate", "index": 6, "value": 310},
  {"type": "Video", "index": 0, "value": 150},
  {"type": "Video", "index": 1, "value": 232},
  {"type": "Video", "index": 2, "value": 201},
  {"type": "Video", "index": 3, "value": 154},
  {"type": "Video", "index": 4, "value": 190},
  {"type": "Video", "index": 5, "value": 330},
  {"type": "Video", "index": 6, "value": 410},
  {"type": "Direct", "index": 0, "value": 320},
  {"type": "Direct", "index": 1, "value": 332},
  {"type": "Direct", "index": 2, "value": 301},
  {"type": "Direct", "index": 3, "value": 334},
  {"type": "Direct", "index": 4, "value": 390},
  {"type": "Direct", "index": 5, "value": 330},
  {"type": "Direct", "index": 6, "value": 320},
  {"type": "Search", "index": 0, "value": 320},
  {"type": "Search", "index": 1, "value": 432},
  {"type": "Search", "index": 2, "value": 401},
  {"type": "Search", "index": 3, "value": 434},
  {"type": "Search", "index": 4, "value": 390},
  {"type": "Search", "index": 5, "value": 430},
  {"type": "Search", "index": 6, "value": 420},
];

const scatterData = [
  [28604, 77, 17096869, 'Australia', 1990],
  [31163, 77.4, 27662440, 'Canada', 1990],
  [1516, 68, 1154605773, 'China', 1990],
  [13670, 74.7, 10582082, 'Cuba', 1990],
  [28599, 75, 4986705, 'Finland', 1990],
  [29476, 77.1, 56943299, 'France', 1990],
  [31476, 75.4, 78958237, 'Germany', 1990],
  [28666, 78.1, 254830, 'Iceland', 1990],
  [1777, 57.7, 870601776, 'India', 1990],
  [29550, 79.1, 122249285, 'Japan', 1990],
  [2076, 67.9, 20194354, 'North Korea', 1990],
  [12087, 72, 42972254, 'South Korea', 1990],
  [24021, 75.4, 3397534, 'New Zealand', 1990],
  [43296, 76.8, 4240375, 'Norway', 1990],
  [10088, 70.8, 38195258, 'Poland', 1990],
  [19349, 69.6, 147568552, 'Russia', 1990],
  [10670, 67.3, 53994605, 'Turkey', 1990],
  [26424, 75.7, 57110117, 'United Kingdom', 1990],
  [37062, 75.4, 252847810, 'United States', 1990],
  [44056, 81.8, 23968973, 'Australia', 2015],
  [43294, 81.7, 35939927, 'Canada', 2015],
  [13334, 76.9, 1376048943, 'China', 2015],
  [21291, 78.5, 11389562, 'Cuba', 2015],
  [38923, 80.8, 5503457, 'Finland', 2015],
  [37599, 81.9, 64395345, 'France', 2015],
  [44053, 81.1, 80688545, 'Germany', 2015],
  [42182, 82.8, 329425, 'Iceland', 2015],
  [5903, 66.8, 1311050527, 'India', 2015],
  [36162, 83.5, 126573481, 'Japan', 2015],
  [1390, 71.4, 25155317, 'North Korea', 2015],
  [34644, 80.7, 50293439, 'South Korea', 2015],
  [34186, 80.6, 4528526, 'New Zealand', 2015],
  [64304, 81.6, 5210967, 'Norway', 2015],
  [24787, 77.3, 38611794, 'Poland', 2015],
  [23038, 73.13, 143456918, 'Russia', 2015],
  [19360, 76.5, 78665830, 'Turkey', 2015],
  [38225, 81.4, 64715810, 'United Kingdom', 2015],
  [53354, 79.1, 321773631, 'United States', 2015]
];
