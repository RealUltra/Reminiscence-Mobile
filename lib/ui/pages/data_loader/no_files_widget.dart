import 'package:flutter/material.dart';

class NoFilesWidget extends StatelessWidget {
  const NoFilesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.folder_outlined, size: 90, color: Colors.grey[600]),
        const SizedBox(height: 16),
        Text(
          "Use the \"Load New File\" button\nto load your instagram data\nand get started!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            debugPrint("Pressed");
          },
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.red.withAlpha(50)),
          ),

          child: Text(
            "Need help downloading your instagram data?\nClick here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
