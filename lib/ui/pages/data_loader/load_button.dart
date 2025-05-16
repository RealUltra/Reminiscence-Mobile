import 'package:flutter/material.dart';

class LoadDataButton extends StatefulWidget {
  const LoadDataButton({super.key});

  @override
  State<LoadDataButton> createState() => _LoadDataButtonState();
}

class _LoadDataButtonState extends State<LoadDataButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          setState(() => _isPressed = false);
        });
      },
      onTapCancel: () {
        Future.delayed(const Duration(milliseconds: 150), () {
          setState(() => _isPressed = false);
        });
      },
      child: AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                _isPressed
                    ? [Color(0xFF2a6fd4), Color(0xFF0047b3)]
                    : [Color(0xFF3a8dff), Color(0xFF005eff)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(58, 141, 255, 0.6),
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              "Load New File",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
