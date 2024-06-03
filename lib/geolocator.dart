import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GeolocatorPage extends StatefulWidget {
  const GeolocatorPage({Key? key}) : super(key: key);

  @override
  _GeolocatorPageState createState() => _GeolocatorPageState();
}

class _GeolocatorPageState extends State<GeolocatorPage> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  bool _isLoading = true;
  final String _openweatherkey = '??';
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(
        'Current Position: Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    await getWeatherData(
        lat: position.latitude.toString(), lon: position.longitude.toString());
  }

  Future<void> getWeatherData({
    required String lat,
    required String lon,
  }) async {
    var url =
        'http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_openweatherkey&units=metric';
    print(url);
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = response.body;
      var dataJson = jsonDecode(data); // string to json
      print('data = $data');
      setState(() {
        _weatherData = dataJson;
      });
    } else {
      print('response status code = ${response.statusCode}');
      setState(() {
        _weatherData = {'error': 'Error fetching weather data'};
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentPosition != null) {
      mapController.moveCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  void _showWeatherDialog() {
    if (_weatherData == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Weather Information'),
          content: _weatherData != null
              ? _buildWeatherContent()
              : const CircularProgressIndicator(),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeatherContent() {
    if (_weatherData == null || _weatherData!.containsKey('error')) {
      return Text(_weatherData?['error'] ?? 'Unknown error');
    }

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('City: ${_weatherData!['name']}'),
          Text('Temperature: ${_weatherData!['main']['temp']}°C'),
          Text('Feels like: ${_weatherData!['main']['feels_like']}°C'),
          Text('Pressure: ${_weatherData!['main']['pressure']} hPa'),
          Text('Humidity: ${_weatherData!['main']['humidity']}%'),
          Text('Weather: ${_weatherData!['weather'][0]['description']}'),
          Text('Wind Speed: ${_weatherData!['wind']['speed']} m/s'),
          Text('Wind Direction: ${_weatherData!['wind']['deg']}°'),
          Text('Cloudiness: ${_weatherData!['clouds']['all']}%'),
          Text('Visibility: ${_weatherData!['visibility']} meters'),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geolocator Page'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.wb_sunny),
            onPressed: _showWeatherDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14.0,
              ),
              markers: _currentPosition == null
                  ? {}
                  : {
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: _currentPosition!,
                      ),
                    },
            ),
    );
  }
}
