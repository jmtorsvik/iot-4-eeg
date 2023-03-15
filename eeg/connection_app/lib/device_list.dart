import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceList extends StatelessWidget {
  const DeviceList(this.devices, this.onPressed, {super.key});

  final Set<BluetoothDevice> devices;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: devices
          .map(
            (device) => TextButton(
              onPressed: () => onPressed(device.name),
              child: Text(
                device.name,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          )
          .toList(),
    );
  }
}
