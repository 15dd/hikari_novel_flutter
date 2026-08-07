import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final bool? bold;

  const IconText({super.key, required this.icon, required this.text, this.color, this.bold});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: color, fontWeight: bold == true ? FontWeight.bold : null),
        ),
      ],
    );
  }
}
