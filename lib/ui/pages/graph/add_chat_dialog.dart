import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';

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
    return Material(
      color: Colors.transparent,

      child: Container(
        padding: EdgeInsets.only(top: 16.0),
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),

        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSearchBar(context),
            const SizedBox(height: 8.0),
            const Divider(),
            _buildChatsList(context),
            const Divider(height: 1.0),
            _buildDoneButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),

          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),

          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),

        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildChatsList(BuildContext context) {
    final filteredChats = _getSearchResults();
    _sortChats(filteredChats);

    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.surface,

        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: filteredChats.length,

          itemBuilder: (context, index) {
            final chat = filteredChats[index];
            return _buildChatCard(context, chat);
          },

          separatorBuilder:
              (BuildContext context, int index) => const Divider(),
        ),
      ),
    );
  }

  Widget _buildChatCard(BuildContext context, ChatDto chat) {
    return ListTile(
      minTileHeight: 0.0,

      title: Text(chat.title, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(
        "${chat.messageCount} messages",
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),

      trailing:
          (widget.chartData.containsKey(chat.id))
              ? Icon(Icons.check, size: 16.0)
              : null,

      onTap: () => chatPressed(context, chat),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),

      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context, widget.chartData);
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 8,
        ),

        child: SizedBox(
          width: double.infinity,
          child: Text(
            "Done",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> chatPressed(BuildContext context, ChatDto chat) async {
    if (widget.chartData.containsKey(chat.id)) {
      if (chat.id != widget.chat.id) {
        setState(() => widget.chartData.remove(chat.id));
      }
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Separate Participants?"),
            content: Text(
              "Would you like all the participants of this chat to be on a separate chart?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
    );

    setState(() {
      widget.chartData[chat.id] = ChartInfo(
        chat: chat,
        separateParticipants: result == true,
      );
    });
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
