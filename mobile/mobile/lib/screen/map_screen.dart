import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  final _mapController = MapController();
  List _markers = [];
  Map<String, dynamic> newestDataHCM = {};
  Map<String, dynamic> newestDataThuDuc = {};
  var dataChannels = [];
  var dataFeeds = [];
  double latHCM = 0.0;
  double longHCM = 0.0;
  double latThuDuc = 0.0;
  double longThuDuc = 0.0;
  String dayVizHCM = '';
  String dayVizTD = '';
  String timeHCM = '';
  String timeTD = '';
  bool isLoading = true;

  void toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
      }
    });
  }

  // get data from thingspeak
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
    // double tempValue = double.parse(getFeed[0]['field1']);
    // double humiValue = double.parse(getFeed[0]['field2']);
    // double co2Value = double.parse(getFeed[0]['field3']);
    // double coValue = double.parse(getFeed[0]['field4']);
    // double pm25Value = double.parse(getFeed[0]['field5']);
    // double uvValue = double.parse(getFeed[0]['field6']);

    // String formattedTemp = tempValue.toStringAsFixed(1);
    // String formattedHumi = humiValue.toStringAsFixed(1);
    // String formattedCO2 = co2Value.toStringAsFixed(4);
    // String formattedCO = coValue.toStringAsFixed(4);
    // String formattedPM25 = pm25Value.toStringAsFixed(4);
    // String formattedUV = uvValue.toStringAsFixed(4);

    //formate date
    String dateTimeHoChiMinh = newestDataHCM['created_at'];
    DateTime dateTimeHCM = DateTime.parse(dateTimeHoChiMinh).toLocal();

    // tz.Location asiaBangkok = tz.getLocation('Asia/Bangkok');
    // tz.TZDateTime asiaBangkokTime = tz.TZDateTime.from(dateTime, asiaBangkok);
    // String dayHCM =
    //     DateFormat('dd-MM-yyyy', 'en_US').format(dateTime).toString();
    // String collectedDateHCM =
    //     DateFormat('HH:mm:ss').format(dateTime).toString();
    // String dayOfWeekHCM =
    //     DateFormat('EEEE', 'en_US').format(asiaBangkokTime).toString();
    // String amPmHCM =
    //     DateFormat('a', 'en_US').format(asiaBangkokTime).toString();

    tz.Location asiaBangkok = tz.getLocation('Asia/Bangkok');
    tz.TZDateTime asiaBangkokTime =
        tz.TZDateTime.from(dateTimeHCM, asiaBangkok);
    String dayHCM =
        DateFormat('dd-MM-yyyy', 'en_US').format(dateTimeHCM).toString();
    String collectedDateHCM =
        DateFormat('HH:mm:ss').format(dateTimeHCM).toString();
    String dayOfWeekHCM =
        DateFormat('EEEE', 'en_US').format(asiaBangkokTime).toString();
    String amPmHCM =
        DateFormat('a', 'en_US').format(asiaBangkokTime).toString();

    var dataThuDuc = await getDataThuDuc();
    var jsonDataThuDuc = json.decode(dataThuDuc);
    var getChannelThuDuc = jsonDataThuDuc['channel'];
    newestDataThuDuc = jsonDataThuDuc['feeds'][0];

    //formate date
    String dateTimeThuDuc = newestDataThuDuc['created_at'];
    DateTime dateTimeTD = DateTime.parse(dateTimeThuDuc).toLocal();
    String dayTD =
        DateFormat('dd-MM-yyyy', 'en_US').format(dateTimeTD).toString();
    String collectedDateTD =
        DateFormat('HH:mm:ss').format(dateTimeTD).toString();
    String dayOfWeekTD =
        DateFormat('EEEE', 'en_US').format(asiaBangkokTime).toString();
    String amPmTD = DateFormat('a', 'en_US').format(asiaBangkokTime).toString();

    setState(() {
      latHCM = double.parse(getChannelHCM['latitude']);
      longHCM = double.parse(getChannelHCM['longitude']);
      dayVizHCM = "$dayOfWeekHCM || $dayHCM ";
      timeHCM = "$collectedDateHCM $amPmHCM";

      latThuDuc = double.parse(getChannelThuDuc['latitude']);
      longThuDuc = double.parse(getChannelThuDuc['longitude']);
      dayVizTD = "$dayOfWeekTD || $dayTD ";
      timeTD = "$collectedDateTD $amPmTD";
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void showStation1BottomSheet(BuildContext context) {
    showBottomSheet(
      context: context,
      builder: (context) => Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Text(
                            'Station: 1',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Ho Chi Minh City',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        child: Divider(
                          thickness: 2,
                          color: Color.fromARGB(255, 15, 71, 7),
                        ),
                      ),
                      Text(
                        'Time: $timeHCM',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Date: $dayVizHCM',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        child: Divider(
                          thickness: 2,
                          color: Color.fromARGB(255, 15, 71, 7),
                        ),
                      ),
                      Text(
                        'Temperature: ${newestDataHCM['field1']} °C',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Humidity: ${newestDataHCM['field2']} %',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'CO2: ${newestDataHCM['field3']} ppm',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'CO: ${newestDataHCM['field4']} ppm',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'PM2.5: ${newestDataHCM['field5']} µg/m3',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'UV Index: ${newestDataHCM['field6']} mW/cm2',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Dewpoint: ${newestDataHCM['field7']} °C',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.clear),
                ),
              ],
            ),
          )),
    );
  }

  void showStation2BottomSheet(BuildContext context) {
    showBottomSheet(
      context: context,
      builder: (context) => Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Text(
                            'Station: 2',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Thu Duc City',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        child: Divider(
                          thickness: 2,
                          color: Color.fromARGB(255, 15, 71, 7),
                        ),
                      ),
                      Text(
                        'Time: $timeTD',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Date: $dayVizTD',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        child: Divider(
                          thickness: 2,
                          color: Color.fromARGB(255, 15, 71, 7),
                        ),
                      ),
                      Text(
                        'Temperature: ${newestDataThuDuc['field1']} °C',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Humidity: ${newestDataThuDuc['field2']} %',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'CO2: ${newestDataThuDuc['field3']} ppm',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'CO: ${newestDataThuDuc['field4']} ppm',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'PM2.5: ${newestDataThuDuc['field5']} µg/m3',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'UV Index: ${newestDataThuDuc['field6']} mW/cm2',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Dewpoint: ${newestDataThuDuc['field7']} °C',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.clear),
                ),
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OSMFlutter(
        controller: _mapController,
        trackMyPosition: true,
        initZoom: 12,
        minZoomLevel: 3,
        maxZoomLevel: 18,
        stepZoom: 1.0,
        userLocationMarker: UserLocationMaker(
          personMarker: const MarkerIcon(
            icon: Icon(
              Icons.person_pin_circle,
              color: Colors.deepPurple,
              size: 120,
            ),
          ),
          directionArrowMarker: const MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Color.fromRGBO(23, 43, 221, 1),
              size: 120,
            ),
          ),
        ),
        roadConfiguration:
            const RoadOption(roadColor: Colors.black, roadWidth: 10),
        markerOption: MarkerOption(
          defaultMarker: const MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 140,
            ),
          ),
          advancedPickerMarker: const MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 140,
            ),
          ),
        ),
        onMapIsReady: (isReady) async {
          if (isReady) {
            await Future.delayed(const Duration(seconds: 2), () async {
              await _mapController.currentLocation();

              // add marker
              GeoPoint station1Position =
                  GeoPoint(latitude: latHCM, longitude: longHCM);
              _mapController.addMarker(
                station1Position,
                markerIcon: const MarkerIcon(
                  icon: Icon(
                    Icons.cloud_circle_rounded,
                    color: Colors.green,
                    size: 140,
                  ),
                ),
              );

              GeoPoint station2Position =
                  GeoPoint(latitude: latThuDuc, longitude: longThuDuc);
              _mapController.addMarker(
                station2Position,
                markerIcon: const MarkerIcon(
                  icon: Icon(
                    Icons.cloud_circle_rounded,
                    color: Colors.green,
                    size: 140,
                  ),
                ),
              );
            });
          }
        },
        onGeoPointClicked: (geoPoint) {
          if (geoPoint.latitude == latHCM && geoPoint.longitude == longHCM) {
            // This is the first marker (station 1)
            showStation1BottomSheet(context);
          } else if (geoPoint.latitude == latThuDuc &&
              geoPoint.longitude == longThuDuc) {
            // This is the second marker (station 2)
            showStation2BottomSheet(context);
          }
        },
        onLocationChanged: (location) {
          print(location);
        },
      ),
      floatingActionButton: SpeedDial(
        marginBottom: 8,
        marginEnd: 4,
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        activeBackgroundColor: const Color.fromARGB(255, 46, 38, 70),
        activeForegroundColor: Colors.white,
        buttonSize: 40.0, //button size
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.25,
        onOpen: () => print('OPENING DIAL'), // action when menu opens
        onClose: () => print('DIAL CLOSED'), //action when menu closes

        elevation: 5.0,
        shape: const CircleBorder(),

        children: [
          SpeedDialChild(
            child: const Icon(Icons.my_location_outlined),
            backgroundColor: Colors.red[400],
            foregroundColor: Colors.white,
            label: 'Your Location',
            labelStyle: const TextStyle(fontSize: 15.0),
            onTap: () => {_mapController.currentLocation()},
            // onLongPress: () => print('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.cloud_rounded),
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            label: 'Air Quality Index',
            labelStyle: const TextStyle(fontSize: 15.0),
            onTap: () => print('SECOND CHILD'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.refresh_outlined),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'Refresh Map',
            labelStyle: const TextStyle(fontSize: 15.0),
            onTap: () => print('THIRD CHILD LONG PRESS'),
          ),
        ],
      ),
    );
  }
}
