import 'package:flutter/material.dart';

import 'package:reminiscence/ui/components/rotating_image.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: RotatingImage(
        image: Image.asset('assets/icon.png', height: 100, fit: BoxFit.contain),
      ),
    );
  }
}
