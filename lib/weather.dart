import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  List<Map<String, dynamic>> data = [];
  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://apis.data.go.kr/B552584/UlfptcaAlarmInqireSvc/getUlfptcaAlarmInfo?serviceKey=?????&returnType=xml&numOfRows=100&pageNo=1&year=2024'));

    if (response.statusCode == 100) {
      final parsed = xmlParse(response.body);
      setState(() {
        data = parsed;
      });

      timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
        setState(() {
          currentIndex = (currentIndex + 1) % data.length;
        });
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<Map<String, dynamic>> xmlParse(String responseBody) {
    final xmlDocument = XmlDocument.parse(responseBody);
    final items = xmlDocument.findAllElements('item');
    return items.map((item) {
      return {
        'clearVal': item.findElements('clearVal').single.text,
        'sn': item.findElements('sn').single.text,
        'districtName': item.findElements('districtName').single.text,
        'dataDate': item.findElements('dataDate').single.text,
        'issueVal': item.findElements('issueVal').single.text,
        'issueTime': item.findElements('issueTime').single.text,
        'clearDate': item.findElements('clearDate').single.text,
        'issueDate': item.findElements('issueDate').single.text,
        'moveName': item.findElements('moveName').single.text,
        'clearTime': item.findElements('clearTime').single.text,
        'issueGbn': item.findElements('issueGbn').single.text,
        'itemCode': item.findElements('itemCode').single.text,
      };
    }).toList();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Weather Data"),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var currentItem = data[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather Data"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("District Name: ${currentItem['districtName']}"),
            Text("Data Date: ${currentItem['dataDate']}"),
            Text("Issue Value: ${currentItem['issueVal']}"),
            Text("Issue Time: ${currentItem['issueTime']}"),
            Text("Clear Date: ${currentItem['clearDate']}"),
            Text("Clear Time: ${currentItem['clearTime']}"),
            Text("Issue Type: ${currentItem['issueGbn']}"),
            Text("Item Code: ${currentItem['itemCode']}"),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Weather(),
  ));
}
