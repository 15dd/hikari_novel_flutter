import 'package:flutter/material.dart';

class ItemText extends StatelessWidget {
  final String title;
  final String desc;

  const ItemText({super.key, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(title),
          Expanded(child: SizedBox.shrink()),
          Text(desc),
        ],
      ),
    );
  }
}
