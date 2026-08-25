import 'package:flutter/material.dart';

class TextStyles extends StatelessWidget {
  final String text;

  const TextStyles({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
