import 'package:flutter/material.dart';

class HomeScreenButton extends StatelessWidget {
  const HomeScreenButton(this.text, this.onPressed, {super.key});

  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}
