import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/search/list_dialog/options_list.dart';
import 'package:reminiscence/ui/pages/search/list_dialog/search_bar.dart';

class ListDialog extends StatefulWidget {
  final List<String> options;

  const ListDialog({super.key, required this.options});

  @override
  State<ListDialog> createState() => _ListDialogState();
}

class _ListDialogState extends State<ListDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final filteredOptions = _getSearchResults();

    return Material(
      color: Colors.transparent,

      child: Container(
        padding: EdgeInsets.only(top: 16.0),
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 120.0),

        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MySearchBar(controller: controller),

            const SizedBox(height: 16.0),

            Divider(
              height: 1.0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),

            OptionsList(
              options: filteredOptions,
              onClick: (option) => onClick(context, option),
            ),
          ],
        ),
      ),
    );
  }

  void onClick(BuildContext context, String option) {
    Navigator.of(context).pop(option);
  }

  List<String> _getSearchResults() {
    final query = controller.text;

    return widget.options
        .where(
          (o) => o.toLowerCase().trim().contains(query.toLowerCase().trim()),
        )
        .toList();
  }
}
