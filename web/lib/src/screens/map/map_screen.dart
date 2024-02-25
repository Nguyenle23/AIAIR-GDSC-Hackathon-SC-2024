import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:iu_air_quality/src/constants/constant_color.dart'; // Ensure this path is correct

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ConstantColor _constants = ConstantColor();

  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDataAndAddMarkers();
  }

  Future<void> _fetchDataAndAddMarkers() async {
    // Simulate fetching data for HCM and Thu Duc, replace with your actual fetching logic
    var hcmData = await _fetchAirQualityData(
        "https://api.thingspeak.com/channels/2115707/feeds.json?results=1");
    var thuDucData = await _fetchAirQualityData(
        "https://api.thingspeak.com/channels/2239030/feeds.json?results=1");

    setState(() {
      _addMarker(hcmData, "Hồ Chí Minh City",
          LatLng(10.776889, 106.700806)); // Use actual coordinates
      _addMarker(thuDucData, "Thủ Đức City",
          LatLng(10.852588, 106.755838)); // Use actual coordinates
      _isLoading = false;
    });
  }

  Future<Map<String, dynamic>> _fetchAirQualityData(String url) async {
    var response = await http.get(Uri.parse(url));
    var jsonData = json.decode(response.body);
    return jsonData['feeds']
        [0]; // Assuming the first feed contains the data you need
  }

  void _addMarker(
      Map<String, dynamic> data, String stationName, LatLng position) {
    _markers.add(
      Marker(
        markerId: MarkerId(stationName),
        position: position,
        infoWindow: InfoWindow(
          title: stationName,
          snippet: _generateMarkerSnippet(data),
          onTap: () {
            // Handle tap on info window if needed
          },
        ),
      ),
    );
  }

  String _generateMarkerSnippet(Map<String, dynamic> data) {
    String temperature = "Temperature: ${data['field1']}°C\n";
    String humidity = "Humidity: ${data['field2']}%\n";
    String co2 = "CO2: ${data['field3']} ppm\n";
    String co = "CO: ${data['field4']} ppm\n";
    String uv = "UV: ${data['field5']}\n";
    String pm25 = "PM2.5: ${data['field6']} µg/m³\n";

    return '$temperature$humidity$co2$co$uv$pm25';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    10.776889, 106.700806), // Center around HCM for example
                zoom: 15.0,
              ),
              markers: _markers,
            ),
    );
  }
}
