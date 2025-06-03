import 'package:flutter/material.dart';

class BulletPoint extends StatelessWidget {
  final String text;
  late final TextStyle textStyle;

  BulletPoint(this.text, {super.key, TextStyle? textStyle}) {
    this.textStyle = textStyle ?? TextStyle();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("•  ", style: textStyle.copyWith(fontSize: 20, height: 1.1)),
          Expanded(
            child: Text(
              text,
              style: textStyle.copyWith(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
