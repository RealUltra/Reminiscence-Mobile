import 'package:flutter/material.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/components/message_box.dart';
import 'package:reminiscence/ui/pages/graph/add_chat/chat_card.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';

class ChatsList extends StatefulWidget {
  final ChatDto chat;
  final List<ChatDto> chats;
  final Map<int, ChartInfo> chartData;

  const ChatsList({
    super.key,
    required this.chat,
    required this.chats,
    required this.chartData,
  });

  @override
  State<ChatsList> createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.surface,

        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: widget.chats.length,

          itemBuilder: (context, index) {
            final chat = widget.chats[index];
            return ChatCard(
              chat,
              checked: widget.chartData.containsKey(chat.id),
              onClick: () => onChatPressed(context, chat),
            );
          },

          separatorBuilder:
              (BuildContext context, int index) => const Divider(),
        ),
      ),
    );
  }

  Future<void> onChatPressed(BuildContext context, ChatDto chat) async {
    if (widget.chartData.containsKey(chat.id)) {
      if (chat.id != widget.chat.id) {
        setState(() => widget.chartData.remove(chat.id));
      }
      return;
    }

    final separateParticipants = await showDialog<bool?>(
      context: context,
      builder:
          (context) => MessageBox(
            title: "Separate Participants?",
            body: Text(
              "Would you like all the participants of this chat to be on a separate chart?",
              textAlign: TextAlign.center,
            ),
            actions: [
              MessageBoxButton("Yes", highlighted: false, value: true),
              MessageBoxButton("No", highlighted: true, value: false),
            ],
            actionsAxis: Axis.horizontal,
          ),
    ) ?? false;

    setState(() {
      widget.chartData[chat.id] = ChartInfo(
        chat: chat,
        separateParticipants: separateParticipants,
      );
    });
  }
}
