import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/pages/chat/chat_page_args.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class QuickSearchSection extends StatelessWidget {
  const QuickSearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,

        child: Container(
          padding: const EdgeInsets.all(32.0),

          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),

            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8.0,

              children: [
                Text(
                  "Quick Searches",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8.0),

                _quickSearchButton(
                  context,
                  "First Message",
                  onTap: () => jumpToFirstMessage(context),
                ),
                _quickSearchButton(
                  context,
                  "Random Message",
                  onTap: () => jumpToRandomMessage(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickSearchButton(
    BuildContext context,
    String title, {
    Function()? onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap ?? () {},
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      child: Text(title),
    );
  }

  Future<void> jumpToFirstMessage(BuildContext context) async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final data = sessionData.data!;
    final chat = sessionData.chat!;

    final firstMessageId = await data.db.messageDao.getFirstMessageId(chat.id);

    if (!context.mounted) return;

    if (firstMessageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          content: Text(
            "No messages found.",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
      );

      return;
    }

    if (context.mounted) {
      _jumpToMessage(context, firstMessageId);
    }
  }

  Future<void> jumpToRandomMessage(BuildContext context) async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final data = sessionData.data!;
    final chat = sessionData.chat!;

    final randomMessageId = await data.db.messageDao.getRandomMessageId(
      chat.id,
    );

    if (!context.mounted) return;

    if (randomMessageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          content: Text(
            "No messages found.",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
      );

      return;
    }

    if (context.mounted) {
      _jumpToMessage(context, randomMessageId);
    }
  }

  Future<void> _jumpToMessage(BuildContext context, String messageId) async {
    final result =
        await Navigator.of(context).pushNamed(
              "/chat",
              arguments: ChatPageArgs(
                initialMessageId: messageId,
                disabled: true,
              ),
            )
            as String?;

    if (result == null || !context.mounted) {
      return;
    }

    Navigator.of(context).pop(messageId);
  }
}
