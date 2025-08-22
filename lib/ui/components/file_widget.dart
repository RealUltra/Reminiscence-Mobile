import 'package:flutter/material.dart';

class FileWidget extends StatelessWidget {
  final String fileName;

  const FileWidget(this.fileName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(16.0),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8.0),

        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),

      child: Row(
        spacing: 16.0,

        children: [
          Icon(
            Icons.insert_drive_file,
            color: Theme.of(context).colorScheme.primary,
            size: 32.0,
          ),

          Expanded(
            child: Text(
              fileName,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
