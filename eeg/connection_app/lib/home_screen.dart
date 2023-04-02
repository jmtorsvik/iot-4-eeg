import 'package:connection_app/home_screen_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

import 'device_list.dart';
import 'home_screen_text.dart';

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
                    ? const HomeScreenText("Scanning...")
                    : _scannedDevices.isEmpty
                        ? const HomeScreenText("No devices found.")
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _device != null
                                ? [
                                    const HomeScreenText("Connect to EDUROAM:"),
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
                                    const HomeScreenText(
                                        "Found the following devices:"),
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

    setState(() => _isScanning = true);

    await _flutterBlue.startScan(timeout: const Duration(seconds: 3));

    _flutterBlue.stopScan();
    setState(() => _isScanning = false);

    setState(() => _scannedDevices = devices);
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();

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
