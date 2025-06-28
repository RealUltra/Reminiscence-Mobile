import 'package:flutter/material.dart';

class OptionsList extends StatelessWidget {
  final List<String> options;
  final void Function(String) onClick;

  const OptionsList({super.key, required this.options, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: options.length,

        itemBuilder: (BuildContext context, int index) {
          final option = options[index];

          return GestureDetector(
            onTap: () => onClick(option),

            child: Container(
              padding: EdgeInsets.all(16.0),

              decoration: BoxDecoration(
                border: BoxBorder.fromLTRB(
                  bottom: BorderSide(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),

              child: Text(option),
            ),
          );
        },
      ),
    );
  }
}
