import 'package:connection_app/home_screen_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

import 'device_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String usernameUUID = "85c70960-789f-405d-aca8-d84167bd0fd9";
  final String passwordUUID = "1e924c7d-f95f-4468-afc8-67372dc559fc";

  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Set<BluetoothDevice> _scannedDevices = {};
  BluetoothDevice? _device;
  bool _isScanning = false;

  EdgeInsetsGeometry padding() {
    return EdgeInsets.fromLTRB(
        0,
        200 - MediaQuery.of(context).viewInsets.bottom,
        0,
        200 - MediaQuery.of(context).viewInsets.bottom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to your EEG unit')),
      body: Center(
        child: AnimatedPadding(
          padding: EdgeInsets.fromLTRB(
              0,
              200 - MediaQuery.of(context).viewInsets.bottom / 2,
              0,
              200 - MediaQuery.of(context).viewInsets.bottom / 2),
          duration: const Duration(milliseconds: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 250,
                height: 200,
                child: _isScanning
                    ? const Text(
                        "Scanning...",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26),
                      )
                    : _scannedDevices.isEmpty
                        ? const Text(
                            "No devices found.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 26),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _device != null
                                ? [
                                    const Text(
                                      "Connect to EDUROAM:",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 26),
                                    ),
                                    // TODO: Send input from user using sendCredentials method
                                    TextField(
                                      controller: usernameController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Username',
                                      ),
                                    ),
                                    TextField(
                                      obscureText: true,
                                      controller: passwordController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Password',
                                      ),
                                    ),
                                  ]
                                : [
                                    const Text(
                                      "Found the following devices:",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 26),
                                    ),
                                    const SizedBox(height: 16),
                                    DeviceList(
                                      _scannedDevices,
                                      connectToDevice,
                                    ),
                                  ],
                          ),
              ),
              _device != null
                  ? HomeScreenButton('Send!', sendCredentials)
                  : HomeScreenButton('Scan!', scanPeripherals),
            ],
          ),
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

  void connectToDevice(BluetoothDevice device) async {
    print("Connecting to " + device.name + "...");
    await device.connect();
    print("Connected to " + device.name + "!");

    setState(() => _device = device);
  }

  void sendCredentials() async {
    BluetoothService service = (await _device!.discoverServices())[0];

    for (BluetoothCharacteristic c in service.characteristics) {
      if (c.uuid.toString() == usernameUUID) {
        await c.write(utf8.encode(usernameController.text));
      } else if (c.uuid.toString() == passwordUUID) {
        await c.write(utf8.encode(passwordController.text));
      }
    }

    _device!.disconnect();
    setState(() {
      _device = null;
    });

    usernameController.dispose();
    passwordController.dispose();
  }
}
