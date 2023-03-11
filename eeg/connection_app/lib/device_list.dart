import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceList extends StatelessWidget {
  const DeviceList(this.devices, {super.key});

  final Set<BluetoothDevice> devices;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: devices
          .map((device) =>
              Text(device.name, style: const TextStyle(fontSize: 24)))
          .toList(),
    );
  }
}
