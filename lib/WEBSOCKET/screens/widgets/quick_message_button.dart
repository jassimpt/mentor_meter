import 'package:flutter/material.dart';

class QuickMessageButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const QuickMessageButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(0, 32),
        side: BorderSide(color: Colors.blue.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
