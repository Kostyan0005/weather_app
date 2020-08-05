import 'package:flutter/material.dart';

class TileText extends StatelessWidget {
  final String text;
  TileText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 18, height: 1.5),
    );
  }
}
