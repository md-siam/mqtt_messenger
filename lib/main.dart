import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mqtt/state/MQTTAppState.dart';
import 'mqtt5/state/MQTT5AppState.dart';
import 'screens/mqtt5_view.dart';
import 'screens/mqtt_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MQTTAppState()),
        ChangeNotifierProvider(create: (_) => MQTT5AppState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const DashBoard(),
    );
  }
}

class DashBoard extends StatelessWidget {
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MQTT Sample',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('MQTT'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MQTTView(),
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              child: const Text('MQTT5'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MQTT5View(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
