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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to your EEG unit')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _isScanning
                ? const Text(
                    "Scanning...",
                    style: TextStyle(fontSize: 26),
                  )
                : _scannedDevices.isEmpty
                    ? const Text(
                        "No devices found.",
                        style: TextStyle(fontSize: 26),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Found the following devices:",
                            style: TextStyle(fontSize: 26),
                          ),
                          const SizedBox(height: 16),
                          DeviceList(
                            _scannedDevices,
                            // TODO: Add function for connecting to EEG Controller
                            (name) => print("Connect to $name"),
                          ),
                        ],
                      ),
            ElevatedButton(
              onPressed: scanPeripherals,
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Scan!',
                  style: TextStyle(fontSize: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scanPeripherals() async {
    Set<BluetoothDevice> devices = {};

    _flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        result.device.name.contains("EEG_CONTROLLER") &&
            devices.add(result.device);
      }
    });

    print("Starting scan");
    setState(() => _isScanning = true);

    await _flutterBlue.startScan(timeout: const Duration(seconds: 3));

    print("Stopping scan");
    _flutterBlue.stopScan();
    setState(() => _isScanning = false);

    for (BluetoothDevice device in devices) {
      print("Found device: $device");
    }

    setState(() => _scannedDevices = devices);
  }
}
