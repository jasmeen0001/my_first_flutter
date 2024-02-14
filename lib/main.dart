import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController gatewayIdController = TextEditingController();
  TextEditingController nodeIdController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = selectedDate;
        } else {
          endDate = selectedDate;
        }
      });
    }
  }

  void _onSubmitPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FetchedDataPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Date Selection App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: gatewayIdController,
              decoration: InputDecoration(labelText: 'Gateway ID'),
            ),
            TextField(
              controller: nodeIdController,
              decoration: InputDecoration(labelText: 'Node ID'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: startDate != null
                          ? "${startDate!.toLocal()}".split(' ')[0]
                          : '',
                    ),
                    decoration: InputDecoration(labelText: 'Start Date'),
                  ),
                ),
                IconButton(
                  onPressed: () => _selectDate(context, true),
                  icon: Icon(Icons.date_range),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: endDate != null
                          ? "${endDate!.toLocal()}".split(' ')[0]
                          : '',
                    ),
                    decoration: InputDecoration(labelText: 'End Date'),
                  ),
                ),
                IconButton(
                  onPressed: () => _selectDate(context, false),
                  icon: Icon(Icons.date_range),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onSubmitPressed,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class FetchedDataPage extends StatelessWidget {
  // Example data, replace with your actual data
  final double temperature = 25.5;
  final double humidity = 60.0;
  final double carbonDioxide = 400.0;
  final String timestamp = DateTime.now().toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetched Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Temperature: $temperature'),
                Text('Humidity: $humidity'),
                Text('Carbon Dioxide: $carbonDioxide'),
                Text('Timestamp: $timestamp'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
