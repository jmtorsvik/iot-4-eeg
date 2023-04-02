import 'package:flutter/material.dart';

class HomeScreenText extends StatelessWidget {
  const HomeScreenText(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 26),
    );
  }
}
