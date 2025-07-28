import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import 'package:reminiscence/features/data_storage/legal.dart';
import 'package:reminiscence/ui/components/message_box.dart';

class PrivacyPolicyButton extends StatelessWidget {
  const PrivacyPolicyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.lock),
      title: const Text("Privacy Policy"),
      subtitle: const Text("Learn how we use and protect your personal data."),
      onTap: () => showPrivacyPolicy(context),
    );
  }

  Future<void> showPrivacyPolicy(BuildContext context) async {
    final privacyPolicy = await getPrivacyPolicy();

    if (!context.mounted) {
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return MessageBox(
          title: "Privacy Policy",
          body: MarkdownBlock(data: privacyPolicy),
          actions: [MessageBoxButton("Dismiss")],
        );
      },
    );
  }
}
