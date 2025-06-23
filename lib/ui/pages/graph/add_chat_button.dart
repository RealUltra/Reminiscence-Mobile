import 'package:flutter/material.dart';

class AddChatButton extends StatefulWidget {
  const AddChatButton({super.key});

  @override
  State<AddChatButton> createState() => _AddChatButtonState();
}

class _AddChatButtonState extends State<AddChatButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => _buildDialog(context),
        );
      },
    );
  }

  Widget _buildDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),

      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildSearchBar(context)],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
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
      onChanged: (text) {},
    );
  }
}
