import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/providers/session_data.dart';
import 'package:reminiscence/ui/providers/system_messages_provider.dart';

class MessageCard extends StatelessWidget {
  final String message;

  const MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(message, overflow: TextOverflow.ellipsis),
      deleteIcon: Icon(Icons.close),
      onDeleted: () => unmarkMessage(context),
    );

    /*
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),

      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        borderRadius: BorderRadius.circular(10),
      ),

      child: ListTile(
        leading: const Icon(Icons.info_outline),

        title: Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge,
        ),

        trailing: InkWell(
          onTap: () => unmarkMessage(context),
          child: const Icon(Icons.close),
        ),
      ),
    );
    */
  }

  Future<void> unmarkMessage(BuildContext context) async {
    final sessionData = Provider.of<SessionData>(context, listen: false);

    final systemMessagesProvider = Provider.of<SystemMessagesProvider>(
      context,
      listen: false,
    );

    await systemMessagesProvider.unmarkAsSystem(message);

    await sessionData.loadChats();
    await sessionData.loadMessageReader();
  }
}
