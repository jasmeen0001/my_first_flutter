import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherApp(),
    );
  }
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  TextEditingController gatewayIdController = TextEditingController();
  TextEditingController nodeIdController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  DateTime? selectedStartDate = DateTime.now();
  DateTime? selectedEndDate = DateTime.now();

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? selectedStartDate ?? DateTime.now() : selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
          startDateController.text = "${picked.toLocal()}".split(' ')[0];
        } else {
          selectedEndDate = picked;
          endDateController.text = "${picked.toLocal()}".split(' ')[0];
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartDate) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartDate
          ? TimeOfDay.fromDateTime(selectedStartDate ?? DateTime.now())
          : TimeOfDay.fromDateTime(selectedEndDate ?? DateTime.now()),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = DateTime(
            selectedStartDate!.year,
            selectedStartDate!.month,
            selectedStartDate!.day,
            picked.hour,
            picked.minute,
          );
          startDateController.text = "${selectedStartDate!.toLocal()}".split(' ')[1];
        } else {
          selectedEndDate = DateTime(
            selectedEndDate!.year,
            selectedEndDate!.month,
            selectedEndDate!.day,
            picked.hour,
            picked.minute,
          );
          endDateController.text = "${selectedEndDate!.toLocal()}".split(' ')[1];
        }
      });
    }
  }

  void _navigateToFetchedData() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FetchedData(
          gatewayId: gatewayIdController.text,
          nodeId: nodeIdController.text,
          startDate: selectedStartDate!,
          endDate: selectedEndDate!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: gatewayIdController,
              decoration: InputDecoration(labelText: 'Gateway ID'),
            ),
            TextField(
              controller: nodeIdController,
              decoration: InputDecoration(labelText: 'Node ID'),
            ),
            TextField(
              controller: startDateController,
              readOnly: true,
              onTap: () => _selectDate(context, true),
              decoration: InputDecoration(labelText: 'Start Date'),
            ),
            TextField(
              controller: endDateController,
              readOnly: true,
              onTap: () => _selectDate(context, false),
              decoration: InputDecoration(labelText: 'End Date'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToFetchedData(),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class FetchedData extends StatefulWidget {
  final String gatewayId;
  final String nodeId;
  final DateTime startDate;
  final DateTime endDate;

  FetchedData({
    required this.gatewayId,
    required this.nodeId,
    required this.startDate,
    required this.endDate,
  });

  @override
  _FetchedDataState createState() => _FetchedDataState();
}

class _FetchedDataState extends State<FetchedData> {
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
        Uri.parse('https://qqvlf6v6kc.execute-api.us-east-1.amazonaws.com/v1/data?nodeId=${widget.nodeId}&gatewayId=${widget.gatewayId}&starttime=${widget.startDate.millisecondsSinceEpoch ~/ 1000}&endtime=${widget.endDate.millisecondsSinceEpoch ~/ 1000}'));

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetched Data'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Temperature: ${data.isNotEmpty ? data[0]['temperature'] : 'N/A'}'),
                        Text('Humidity: ${data.isNotEmpty ? data[0]['humidity'] : 'N/A'}'),
                        Text('CO2: ${data.isNotEmpty ? data[0]['co2'] : 'N/A'}'),
                        Text('Timestamp: ${data.isNotEmpty ? data[0]['timestamp'] : 'N/A'}'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
