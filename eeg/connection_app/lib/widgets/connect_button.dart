import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectButton extends StatelessWidget {
  ConnectButton({
    super.key,
  });

  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  //Set<ScanResult> scanPeripherals() {
  void scanPeripherals() {
    print("Starting scan");
    flutterBlue.startScan(timeout: const Duration(seconds: 20));

    //Set<ScanResult> scanResults = {};
    flutterBlue.scanResults.listen((results) {
      print("Scanning...");
      print("Results: $results");
      //scanResults.addAll(results);
    });

    //print("Stopping scan");
    //flutterBlue.stopScan();

    //return scanResults;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        scanPeripherals();
        //print("Results from Peripheral Scan:");
        //for (ScanResult result in scanPeripherals()) print(result.device.name);
      },
      child: const Text('Connect!'),
    );
  }
}
