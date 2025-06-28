import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final TextEditingController? controller;
  const MySearchBar({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),

          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),

          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),

        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
