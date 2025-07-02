import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/pages/settings/system_messages/messages_list.dart';
import 'package:reminiscence/ui/providers/system_messages_provider.dart';

class SystemMessagesTile extends StatelessWidget {
  const SystemMessagesTile({super.key});

  @override
  Widget build(BuildContext context) {
    final systemMessagesProvider = Provider.of<SystemMessagesProvider>(context);
    final systemMessages = systemMessagesProvider.systemMessages;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),

      child: ExpansionTile(
        title: Text('System Messages'),
        leading: Icon(Icons.settings_suggest),

        children: [
          Visibility(
            visible: systemMessages.isNotEmpty,

            child: Text(
              "Tap any to unmark as system message.",

              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          MessagesList(messages: systemMessages),
        ],
      ),
    );
  }
}
