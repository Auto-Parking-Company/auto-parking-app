import 'package:flutter/material.dart';
import 'package:mqtt_client_app/connection/mqtt.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Parking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Auto Parking'),
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
  final MqttController mqttController =
      MqttController(topic: 'parking-auto-sihs-si/allowed');
  final TextEditingController _carPlateTextfieldController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _carPlateTextfieldController,
                decoration: const InputDecoration(label: Text('Car Plate')),
              ),
              ElevatedButton(
                  onPressed: () => mqttController
                      .publishMessage(_carPlateTextfieldController.text),
                  child: const Text('Submit'))
            ],
          ),
        ),
      ),
    );
  }
}
