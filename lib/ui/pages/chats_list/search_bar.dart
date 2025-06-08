import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final void Function(String text)? onChanged;

  const MySearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF2E2E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
    );
  }
}
