import 'package:flutter/material.dart';

import 'package:reminiscence/ui/pages/data_loader/body.dart';

class LoadDataButton extends StatefulWidget {
  final BodyState parent;

  const LoadDataButton({super.key, required this.parent});

  @override
  State<LoadDataButton> createState() => _LoadDataButtonState();
}

class _LoadDataButtonState extends State<LoadDataButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.parent.loadNewData(context);
      },

      child: Container(
        width: double.infinity,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Theme.of(context).colorScheme.primary,
        ),

        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(
              "Load New File",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
