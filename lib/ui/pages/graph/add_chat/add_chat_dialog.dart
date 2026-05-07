import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/graph/add_chat/chats_list.dart';
import 'package:reminiscence/ui/pages/graph/add_chat/done_button.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';
import 'package:reminiscence/ui/pages/graph/add_chat/search_bar.dart';

class AddChatDialog extends StatefulWidget {
  final ReminiscenceData data;
  final ChatDto chat;
  final List<ChatDto> chats;
  final Map<int, ChartInfo> chartData;

  const AddChatDialog({
    super.key,
    required this.data,
    required this.chat,
    required this.chats,
    required this.chartData,
  });

  @override
  State<AddChatDialog> createState() => _AddChatDialogState();
}

class _AddChatDialogState extends State<AddChatDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final filteredChats = _getSearchResults();
    _sortChats(filteredChats);

    return Dialog(
      child: Container(
        padding: EdgeInsets.only(top: 16.0),
        constraints: BoxConstraints(maxWidth: 400, maxHeight: 400),

        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            MySearchBar(controller: controller),

            const SizedBox(height: 8.0),
            const Divider(),

            ChatsList(
              chat: widget.chat,
              chats: filteredChats,
              chartData: widget.chartData,
            ),

            const Divider(height: 1.0),

            DoneButton(chartData: widget.chartData),
          ],
        ),
      ),
    );
  }

  List<ChatDto> _getSearchResults() {
    final query = controller.text;

    return widget.chats
        .where(
          (c) =>
              c.title.toLowerCase().trim().contains(query.toLowerCase().trim()),
        )
        .toList();
  }

  void _sortChats(List<ChatDto> chats) {
    chats.sort((a, b) => b.messageCount.compareTo(a.messageCount));

    for (final chat in List.of(chats).reversed) {
      if (widget.chartData.containsKey(chat.id)) {
        chats.remove(chat);
        chats.insert(0, chat);
      }
    }

    chats.remove(widget.chat);
    chats.insert(0, widget.chat);
  }
}
