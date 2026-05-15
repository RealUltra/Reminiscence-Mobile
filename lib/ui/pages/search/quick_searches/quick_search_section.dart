import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/pages/chat/chat_page_args.dart';
import 'package:reminiscence/ui/pages/search/quick_searches/quick_search_tile.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class QuickSearchSection extends StatelessWidget {
  const QuickSearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20.0, 28.0, 20.0, 20.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  "Quick searches",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Material(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20.0),
                clipBehavior: Clip.antiAlias,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QuickSearchTile(
                        title: "First message",
                        onTap: () => jumpToFirstMessage(context),
                      ),
                      Divider(height: 1.0, color: colorScheme.outlineVariant),
                      QuickSearchTile(
                        title: "Random message",
                        onTap: () => jumpToRandomMessage(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_return_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        "Use the search bar above for anything more specific.",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> jumpToFirstMessage(BuildContext context) async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final data = sessionData.data!;
    final chat = sessionData.chat!;

    final firstMessageId = await data.db.messageDao.getFirstMessageId(chat.id);

    if (!context.mounted) return;

    if (firstMessageId == null) {
      _showNoMessagesSnackBar(context);
      return;
    }

    await _jumpToMessage(context, firstMessageId);
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
      _showNoMessagesSnackBar(context);
      return;
    }

    await _jumpToMessage(context, randomMessageId);
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

  void _showNoMessagesSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        content: Text(
          "No messages found.",
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }
}
