import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final void Function(String text)? onChanged;

  const MySearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
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
      onChanged: onChanged,
    );
  }
}
