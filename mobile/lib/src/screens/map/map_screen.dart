import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:iu_air_quality/src/constants/constant_color.dart';
import 'package:timezone/timezone.dart' as tz;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ConstantColor _constants = ConstantColor();

  late MapController controller;
  List _markers = [];
  Map<String, dynamic> newestDataHCM = {};
  Map<String, dynamic> newestDataThuDuc = {};
  var dataChannels = [];
  var dataFeeds = [];
  double latHCM = 0.0;
  double longHCM = 0.0;
  double latThuDuc = 0.0;
  double longThuDuc = 0.0;
  String dayHCM = '';
  String dayTD = '';
  String timeHCM = '';
  String timeTD = '';
  String time = '';
  String day = '';
  String stationName = '';
  Map<String, dynamic> stationData = {};
  bool isLoading = true;
  bool showDialogFlag = false;
  ValueNotifier<bool> trackingNotifier = ValueNotifier(false);
  ValueNotifier<bool> showFab = ValueNotifier(false);
  ValueNotifier<IconData> userLocationIcon = ValueNotifier(Icons.near_me);
  ValueNotifier<GeoPoint?> lastGeoPoint = ValueNotifier(null);
  ValueNotifier<GeoPoint?> userLocationNotifier = ValueNotifier(null);
  final mapKey = GlobalKey();

  Future<String> getDataHCM() async {
    var url =
        "https://api.thingspeak.com/channels/2115707/feeds.json?results=1";
    var response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );
    return response.body;
  }

  Future<String> getDataThuDuc() async {
    var url =
        "https://api.thingspeak.com/channels/2239030/feeds.json?results=1";
    var response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );
    return response.body;
  }

  getData() async {
    var dataHCM = await getDataHCM();
    var jsonDataHCM = json.decode(dataHCM);
    var getChannelHCM = jsonDataHCM['channel'];
    newestDataHCM = jsonDataHCM['feeds'][0];

    //formate date
    String dateTimeHCM = getChannelHCM['created_at'];
    DateTime dateTime = DateTime.parse(dateTimeHCM).toLocal();
    String collectedDate = DateFormat('HH:mm:ss').format(dateTime).toString();
    tz.Location asiaBangkok = tz.getLocation('Asia/Bangkok');
    tz.TZDateTime asiaBangkokTime = tz.TZDateTime.from(dateTime, asiaBangkok);
    String dayOfWeek =
        DateFormat('EEEE', 'en_US').format(asiaBangkokTime).toString();
    String day =
        DateFormat('dd-MM-yyyy', 'en_US').format(asiaBangkokTime).toString();
    String amPm = DateFormat('a', 'en_US').format(asiaBangkokTime).toString();

    var dataThuDuc = await getDataThuDuc();
    var jsonDataThuDuc = json.decode(dataThuDuc);
    var getChannelThuDuc = jsonDataThuDuc['channel'];
    newestDataThuDuc = jsonDataThuDuc['feeds'][0];

    //formate date
    String dateTimeThuDuc = getChannelThuDuc['created_at'];
    DateTime dateTimeTD = DateTime.parse(dateTimeThuDuc).toLocal();
    String collectedDateTD =
        DateFormat('HH:mm:ss').format(dateTimeTD).toString();
    tz.Location asiaBangkokTD = tz.getLocation('Asia/Bangkok');
    tz.TZDateTime asiaBangkokTimeTD =
        tz.TZDateTime.from(dateTimeTD, asiaBangkokTD);
    String dayOfWeekTD =
        DateFormat('EEEE', 'en_US').format(asiaBangkokTimeTD).toString();
    String dayTD =
        DateFormat('dd-MM-yyyy', 'en_US').format(asiaBangkokTimeTD).toString();
    String amPmTD =
        DateFormat('a', 'en_US').format(asiaBangkokTimeTD).toString();

    setState(() {
      latHCM = double.parse(getChannelHCM['latitude']);
      longHCM = double.parse(getChannelHCM['longitude']);
      dayHCM = "$dayOfWeek || $day ";
      timeHCM = "$collectedDate $amPm";

      latThuDuc = double.parse(getChannelThuDuc['latitude']);
      longThuDuc = double.parse(getChannelThuDuc['longitude']);
      dayTD = "$dayOfWeekTD || $dayTD ";
      timeTD = "$collectedDateTD $amPmTD";
      isLoading = false;
    });
  }

  @override
  void initState() {
    controller = MapController(
      initPosition: GeoPoint(
        latitude: 10.8619784,
        longitude: 106.8034464,
      ),
    );
    getData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text("Permission location"),
            content: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Let AIAir access your location to show AIAir stations nearby.',
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Only show your location on map without using it for any purposes.',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.blue)),
                child: const Text(
                  "Got it",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapFlutter(
          controller: controller,
          latHCM: latHCM,
          longHCM: longHCM,
          latThuDuc: latThuDuc,
          longThuDuc: longThuDuc,
          newestDataHCM: newestDataHCM,
          newestDataThuDuc: newestDataThuDuc,
          dayHCM: dayHCM,
          dayTD: dayTD,
          timeHCM: timeHCM,
          timeTD: timeTD,
          day: day,
          time: time,
          stationName: stationName,
          stationData: stationData,
        ),
        Positioned(
          bottom: 23.0,
          left: 15,
          child: ZoomNavigation(
            controller: controller,
          ),
        ),
        Positioned(
          bottom: 23.0,
          right: 15,
          child: ActivationUserLocation(
            controller: controller,
            showFab: showFab,
            trackingNotifier: trackingNotifier,
            userLocationIcon: userLocationIcon,
          ),
        ),
        ActivationUserLocation(
          showFab: showFab,
          trackingNotifier: trackingNotifier,
          controller: controller,
          userLocationIcon: userLocationIcon,
        ),
      ],
    );
  }
}

class ZoomNavigation extends StatelessWidget {
  ZoomNavigation({
    super.key,
    required this.controller,
    
  });
  final MapController controller;
  final ConstantColor _constants = ConstantColor();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PointerInterceptor(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              maximumSize: const Size(48, 48),
              minimumSize: const Size(24, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: _constants.tertiaryColor,
              padding: EdgeInsets.zero,
            ),
            child: const Center(
              child: Icon(Icons.add, color: Colors.white),
            ),
            onPressed: () async {
              controller.zoomIn();
            },
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        PointerInterceptor(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              maximumSize: const Size(48, 48),
              minimumSize: const Size(24, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: _constants.tertiaryColor,
              padding: EdgeInsets.zero,
            ),
            child: const Center(
              child: Icon(Icons.remove, color: Colors.white),
            ),
            onPressed: () async {
              controller.zoomOut();
            },
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class MapFlutter extends StatelessWidget {
  MapFlutter({
    super.key,
    required this.controller,
    required this.latHCM,
    required this.longHCM,
    required this.latThuDuc,
    required this.longThuDuc,
    required this.newestDataHCM,
    required this.newestDataThuDuc,
    required this.timeHCM,
    required this.timeTD,
    required this.dayHCM,
    required this.dayTD,
    required this.time,
    required this.day,
    required this.stationName,
    required this.stationData,
  });
  final MapController controller;
  double latHCM = 0.0;
  double longHCM = 0.0;
  double latThuDuc = 0.0;
  double longThuDuc = 0.0;
  Map<String, dynamic> newestDataHCM = {};
  Map<String, dynamic> newestDataThuDuc = {};
  String dayHCM;
  String dayTD;
  String timeHCM;
  String timeTD;
  String time;
  String day;
  String stationName;
  Map<String, dynamic> stationData = {};

  @override
  Widget build(BuildContext context) {
    return OSMFlutter(
      controller: controller,
      mapIsLoading: const Center(
        child: CircularProgressIndicator(),
      ),
      osmOption: OSMOption(
        enableRotationByGesture: true,
        zoomOption: const ZoomOption(
          initZoom: 14,
          minZoomLevel: 3,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
        userLocationMarker: UserLocationMaker(
            personMarker: const MarkerIcon(
              icon: Icon(
                Icons.car_crash_sharp,
                color: Colors.red,
                size: 48,
              ),
            ),
            directionArrowMarker: const MarkerIcon(
              icon: Icon(
                Icons.navigation_rounded,
                size: 48,
              ),
            )),
        staticPoints: [
          StaticPositionGeoPoint(
            "line 1",
            MarkerIcon(
              assetMarker: AssetMarker(
                image: const AssetImage(
                  "assets/images/station.png",
                ),
                scaleAssetImage: 10,
              ),
            ),
            [
              GeoPoint(
                latitude: 10.7936588867,
                longitude: 106.6803109431,
              ),
              GeoPoint(
                latitude: 10.8675737,
                longitude: 106.7939631,
              ),
            ],
          ),
        ],
        roadConfiguration: const RoadOption(
          roadColor: Colors.blueAccent,
        ),
        markerOption: MarkerOption(
          defaultMarker: const MarkerIcon(
            icon: Icon(
              Icons.home,
              color: Colors.orange,
              size: 32,
            ),
          ),
          advancedPickerMarker: const MarkerIcon(
            icon: Icon(
              Icons.location_searching,
              color: Colors.green,
              size: 56,
            ),
          ),
        ),
        showContributorBadgeForOSM: true,
        showDefaultInfoWindow: false,
      ),
      onGeoPointClicked: (geoPoint) {
        if (geoPoint.latitude == latHCM && geoPoint.longitude == longHCM) {
          stationName = 'Ho Chi Minh';
          time = timeHCM;
          day = dayHCM;
          stationData = newestDataHCM;
        } else {
          stationName = 'Thu Duc';
          time = timeTD;
          day = dayTD;
          stationData = newestDataThuDuc;
        }
        _showStationDetails(
          context,
          geoPoint.latitude,
          geoPoint.longitude,
          stationName,
          stationData,
          time,
          day,
        );
      },
    );
  }
}

TableRow _buildTableRow(String field, String value) {
  return TableRow(
    children: [
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              field,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
    ],
  );
}

void _showStationDetails(
  BuildContext context,
  double lat,
  double long,
  String stationName,
  Map<String, dynamic> stationData,
  String time,
  String day,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'AIAir Station: $stationName',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Table(
            border: TableBorder.all(),
            columnWidths: const {
              0: FlexColumnWidth(1.0),
              1: FlexColumnWidth(2.0),
            },
            children: [
              _buildTableRow('Time & Date', '$day $time'),
              _buildTableRow('Temperature', '${stationData['field1']}°C'),
              _buildTableRow('Humidity', '${stationData['field2']}%'),
              _buildTableRow('CO2 Values', '${stationData['field3']} ppm'),
              _buildTableRow('CO Values', '${stationData['field4']} ppm'),
              _buildTableRow('PM2.5', '${stationData['field5']} ppm'),
              _buildTableRow('UV Index', '${stationData['field6']} ppm'),
              _buildTableRow('Dewpoints', '${stationData['field7']} ppm'),
              _buildTableRow('Wind Direction', 'North'),
              _buildTableRow('Wind Speed', '10 km/h'),
              // Add more rows for other details
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class PointerInterceptor extends StatelessWidget {
  PointerInterceptor({
    required this.child,
    this.intercepting = true,
    this.debug = false,
    super.key,
  });
  final ConstantColor _constants = ConstantColor();
  final Widget child;
  final bool intercepting;
  final bool debug;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class ActivationUserLocation extends StatelessWidget {
  final ConstantColor _constants = ConstantColor();

  final ValueNotifier<bool> showFab;
  final ValueNotifier<bool> trackingNotifier;
  final MapController controller;
  final ValueNotifier<IconData> userLocationIcon;

  ActivationUserLocation({
    super.key,
    required this.showFab,
    required this.trackingNotifier,
    required this.controller,
    required this.userLocationIcon,
  });
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showFab,
      builder: (ctx, isShow, child) {
        if (!isShow) {
          return const SizedBox.shrink();
        }
        return child!;
      },
      child: PointerInterceptor(
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onLongPress: () async {
            await controller.disabledTracking();
            trackingNotifier.value = false;
          },
          child: FloatingActionButton(
            key: UniqueKey(),
            onPressed: () async {
              if (!trackingNotifier.value) {
                await controller.currentLocation();
                await controller.enableTracking(
                  enableStopFollow: true,
                  disableUserMarkerRotation: true,
                  anchor: Anchor.left,
                );
                trackingNotifier.value = true;
              } else {
                await controller.enableTracking(
                  enableStopFollow: false,
                  disableUserMarkerRotation: true,
                  anchor: Anchor.left,
                );
              }
            },
            mini: true,
            heroTag: "UserLocationFab",
            child: ValueListenableBuilder<bool>(
              valueListenable: trackingNotifier,
              builder: (ctx, isTracking, _) {
                if (isTracking) {
                  return ValueListenableBuilder<IconData>(
                    valueListenable: userLocationIcon,
                    builder: (context, icon, _) {
                      return Icon(icon);
                    },
                  );
                }
                return const Icon(Icons.near_me);
              },
            ),
          ),
        ),
      ),
    );
  }
}
  
  
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: OSMFlutter(
  //       controller: _mapController,
  //       trackMyPosition: true,
  //       initZoom: 12,
  //       minZoomLevel: 3,
  //       maxZoomLevel: 18,
  //       stepZoom: 1.0,
  //       userLocationMarker: UserLocationMaker(
  //         personMarker: const MarkerIcon(
  //           icon: Icon(
  //             Icons.person_pin_circle,
  //             color: Colors.deepPurple,
  //             size: 120,
  //           ),
  //         ),
  //         directionArrowMarker: const MarkerIcon(
  //           icon: Icon(
  //             Icons.location_on,
  //             color: Color.fromRGBO(23, 43, 221, 1),
  //             size: 120,
  //           ),
  //         ),
  //       ),
  //       roadConfiguration:
  //           const RoadOption(roadColor: Colors.black, roadWidth: 10),
  //       markerOption: MarkerOption(
  //         defaultMarker: const MarkerIcon(
  //           icon: Icon(
  //             Icons.location_on,
  //             color: Colors.red,
  //             size: 140,
  //           ),
  //         ),
  //         advancedPickerMarker: const MarkerIcon(
  //           icon: Icon(
  //             Icons.location_on,
  //             color: Colors.red,
  //             size: 140,
  //           ),
  //         ),
  //       ),
  //       onMapIsReady: (isReady) async {
  //         if (isReady) {
  //           await Future.delayed(const Duration(seconds: 2), () async {
  //             await _mapController.currentLocation();

  //             // add marker
  //             GeoPoint station1Position =
  //                 GeoPoint(latitude: latHCM, longitude: longHCM);
  //             _mapController.addMarker(
  //               station1Position,
  //               markerIcon: const MarkerIcon(
  //                 icon: Icon(
  //                   Icons.cloud_circle_rounded,
  //                   color: Colors.green,
  //                   size: 140,
  //                 ),
  //               ),
  //             );

  //             GeoPoint station2Position =
  //                 GeoPoint(latitude: latThuDuc, longitude: longThuDuc);
  //             _mapController.addMarker(
  //               station2Position,
  //               markerIcon: const MarkerIcon(
  //                 icon: Icon(
  //                   Icons.cloud_circle_rounded,
  //                   color: Colors.green,
  //                   size: 140,
  //                 ),
  //               ),
  //             );
  //           });
  //         }
  //       },
  //       onGeoPointClicked: (geoPoint) {
  //         if (geoPoint.latitude == latHCM && geoPoint.longitude == longHCM) {
  //           // This is the first marker (station 1)
  //           showStation1BottomSheet(context);
  //         } else if (geoPoint.latitude == latThuDuc &&
  //             geoPoint.longitude == longThuDuc) {
  //           // This is the second marker (station 2)
  //           showStation2BottomSheet(context);
  //         }
  //       },
  //       onLocationChanged: (location) {
  //         print(location);
  //       },
  //     ),
  //     floatingActionButton: SpeedDial(
  //       marginBottom: 8,
  //       marginEnd: 4,
  //       icon: Icons.menu,
  //       activeIcon: Icons.close,
  //       backgroundColor: Colors.green[800],
  //       foregroundColor: Colors.white,
  //       activeBackgroundColor: const Color.fromARGB(255, 46, 38, 70),
  //       activeForegroundColor: Colors.white,
  //       buttonSize: 40.0, //button size
  //       visible: true,
  //       closeManually: false,
  //       curve: Curves.bounceIn,
  //       overlayColor: Colors.black,
  //       overlayOpacity: 0.25,
  //       onOpen: () => print('OPENING DIAL'), // action when menu opens
  //       onClose: () => print('DIAL CLOSED'), //action when menu closes

  //       elevation: 5.0,
  //       shape: const CircleBorder(),

  //       children: [
  //         SpeedDialChild(
  //           child: const Icon(Icons.my_location_outlined),
  //           backgroundColor: Colors.red[400],
  //           foregroundColor: Colors.white,
  //           label: 'Your Location',
  //           labelStyle: const TextStyle(fontSize: 15.0),
  //           onTap: () => {_mapController.currentLocation()},
  //           // onLongPress: () => print('FIRST CHILD LONG PRESS'),
  //         ),
  //         SpeedDialChild(
  //           child: const Icon(Icons.cloud_rounded),
  //           foregroundColor: Colors.white,
  //           backgroundColor: Colors.green,
  //           label: 'Air Quality Index',
  //           labelStyle: const TextStyle(fontSize: 15.0),
  //           onTap: () => print('SECOND CHILD'),
  //         ),
  //         SpeedDialChild(
  //           child: const Icon(Icons.refresh_outlined),
  //           backgroundColor: Colors.blue,
  //           foregroundColor: Colors.white,
  //           label: 'Refresh Map',
  //           labelStyle: const TextStyle(fontSize: 15.0),
  //           onTap: () => print('THIRD CHILD LONG PRESS'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
