import 'package:flutter/material.dart';

import 'calendar.dart'; // Import the Calendar page
import 'geolocator.dart'; // Import the Geolocator page
import 'weather.dart'; // Import the Weather page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/calendar': (context) => const Calendar(),
        '/geolocator': (context) => const GeolocatorPage(),
        '/weather': (context) => const Weather(), // Add the Weather route
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.location_on),
              tooltip: 'Go to Geolocator',
              onPressed: () {
                Navigator.pushNamed(context, '/geolocator');
              },
              iconSize: 50.0,
            ),
            IconButton(
              icon: const Icon(Icons.cloud),
              tooltip: 'Go to Weather', // Updated tooltip
              onPressed: () {
                Navigator.pushNamed(
                    context, '/weather'); // Navigate to Weather page
              },
              iconSize: 50.0,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/calendar');
        },
        tooltip: 'Go to Calendar',
        child: const Icon(Icons.calendar_today),
      ),
    );
  }
}
