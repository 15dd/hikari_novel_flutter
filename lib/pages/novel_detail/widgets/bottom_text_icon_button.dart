import 'package:flutter/material.dart';

class BottomTextIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function() onPressed;

  const BottomTextIconButton({super.key, required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        child: Column(
          children: [
            Icon(icon, size: 24),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
