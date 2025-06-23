import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';

class AddChatDialog extends StatefulWidget {
  final ReminiscenceData data;
  final ChatDto chat;
  final List<ChatDto> chats;
  final Map<int, ChartInfo> charts;

  const AddChatDialog({
    super.key,
    required this.data,
    required this.chat,
    required this.chats,
    required this.charts,
  });

  @override
  State<AddChatDialog> createState() => _AddChatDialogState();
}

class _AddChatDialogState extends State<AddChatDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 120.0),

      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),

        child: Container(
          padding: EdgeInsets.only(top: 16.0),

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
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),

      child: TextField(
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
        onChanged: (text) {},
      ),
    );
  }

  Widget _buildChatsList(BuildContext context) {
    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.surface,

        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: widget.chats.length,
          itemBuilder: (context, index) {
            final chat = widget.chats[index];
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
      trailing:
          (widget.charts.containsKey(chat.id))
              ? Icon(Icons.check, size: 16.0)
              : null,

      onTap: () => _toggleChat(context, chat),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),

      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context, widget.charts);
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

  Future<void> _toggleChat(BuildContext context, ChatDto chat) async {
    if (widget.charts.containsKey(chat.id)) {
      if (chat.id != widget.chat.id) {
        setState(() => widget.charts.remove(chat.id));
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
      widget.charts[chat.id] = ChartInfo(
        chat: chat,
        separateParticipants: result == true,
      );
    });
  }
}
