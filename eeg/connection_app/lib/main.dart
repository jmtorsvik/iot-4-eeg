import 'package:flutter/material.dart';

void main() {
  runApp(const ConnectionApp());
}

class ConnectionApp extends StatelessWidget {
  const ConnectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connection App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Scaffold(
        appBar: AppBar(title: const Text('Connect your EEG unit!')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => print('Connect!'),
            child: const Text('Connect!'),
          ),
        ),
      ),
    );
  }
}
