import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:reminiscence/features/data_storage/legal.dart';
import 'package:reminiscence/ui/components/message_box.dart';

class TermsOfServiceButton extends StatelessWidget {
  const TermsOfServiceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.article),
      title: const Text("Terms Of Service"),
      subtitle: Text('Review the rules and conditions for using this app.'),
      onTap: () => showTermsOfService(context),
    );
  }

  Future<void> showTermsOfService(BuildContext context) async {
    final termsOfService = await getTermsOfService();

    if (!context.mounted) {
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return MessageBox(
          title: "Terms Of Service",
          body: MarkdownBlock(data: termsOfService),
          actions: [MessageBoxButton("Dismiss")],
        );
      },
    );
  }
}
