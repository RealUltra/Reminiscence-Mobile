import 'dart:math';

import 'package:flutter/material.dart';

class RotatingImage extends StatefulWidget {
  final Image image;

  const RotatingImage({super.key, required this.image});

  @override
  State<RotatingImage> createState() => _RotatingImageState();
}

class _RotatingImageState extends State<RotatingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.rotate(
          angle: controller.value * 2.0 * pi,
          child: child,
        );
      },
      child: widget.image,
    );
  }
}
