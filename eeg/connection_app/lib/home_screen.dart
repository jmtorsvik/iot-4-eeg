import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  Set<BluetoothDevice> _scannedDevices = {};
  bool _isScanning = false;

  void scanPeripherals() async {
    Set<BluetoothDevice> devices = {};

    _flutterBlue.scanResults.listen((results) {
      print("Scanning for nearby BLE devices...");
      for (ScanResult result in results) {
        result.device.name.isNotEmpty && devices.add(result.device);
      }
    });

    print("Starting scan");
    setState(() => _isScanning = true);

    await _flutterBlue.startScan(timeout: const Duration(seconds: 5));

    print("Stopping scan");
    _flutterBlue.stopScan();
    setState(() => _isScanning = false);

    for (BluetoothDevice device in devices) {
      print("Found device: $device");
    }

    setState(() => _scannedDevices = devices);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to your EEG unit')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _isScanning
                ? const Text("Scanning...", style: TextStyle(fontSize: 24))
                : _scannedDevices.isEmpty
                    ? const Text("No devices found.",
                        style: TextStyle(fontSize: 24))
                    : DeviceList(_scannedDevices),
            TextButton(
              onPressed: scanPeripherals,
              child: const Text('Scan!', style: TextStyle(fontSize: 32)),
            ),
          ],
        ),
      ),
    );
  }
}
