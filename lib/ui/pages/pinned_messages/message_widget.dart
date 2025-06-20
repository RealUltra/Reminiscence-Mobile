import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/pages/chat/attachment_widget.dart';
import 'package:reminiscence/ui/pages/chat/reaction_widget.dart';
import 'package:reminiscence/ui/pages/chat/view_reactions_widget.dart';

class MessageWidget extends StatefulWidget {
  final ReminiscenceData data;
  final String? userName;
  final MessageDto message;

  const MessageWidget({
    super.key,
    required this.data,
    required this.userName,
    required this.message,
  });

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  final senderNameExpiryTime = 5 * 60 * 1000; // 5 minutes in ms

  bool isHighlighted = false;
  int highlightStart = 0;
  Timer? highlightTimer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: BoxBorder.all(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          width: 0.5,
        ),
      ),

      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSenderInfo(context),

          Visibility(
            visible: widget.message.content.trim().isNotEmpty,
            child: _buildMessageContent(context),
          ),

          Visibility(
            visible: widget.message.attachments.isNotEmpty,
            child: _buildAttachments(context),
          ),

          Visibility(
            visible: _getReactionsList().isNotEmpty,
            child: _buildReactions(),
          ),
        ],
      ),
    );
  }

  Widget _buildSenderInfo(BuildContext context) {
    final isUser = widget.userName == widget.message.senderName;

    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            widget.message.senderName,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color:
                  isUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 8.0),

          Text(
            DateFormat("dd/MM/yyyy HH:mm").format(
              DateTime.fromMillisecondsSinceEpoch(widget.message.sentAt),
            ),
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return Text(
      widget.message.content,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildAttachments(BuildContext context) {
    List<Widget> children = [];

    for (final attachment in widget.message.attachments) {
      children.add(AttachmentWidget(attachment: attachment, data: widget.data));
    }

    return Column(spacing: 4.0, children: children);
  }

  Widget _buildReactions() {
    List<Widget> children = [];

    final reactions = _getReactionsList();

    for (Map<String, dynamic> reaction in ViewReactionsWidget.getReactionsInfo(
      reactions,
    )) {
      String reactionEmoji = reaction["emoji"];
      int reactionCount = reaction["actors"].length;
      bool userReacted = reaction["actors"].contains(widget.userName);

      children.add(
        ReactionWidget(
          reactionEmoji,
          numReactions: reactionCount,
          highlight: userReacted,
        ),
      );
    }

    return Row(spacing: 4.0, children: children);
  }

  List<dynamic> _getReactionsList() {
    final data = jsonDecode(widget.message.rawData);
    List<dynamic> reactions = data["reactions"] ?? [];
    return reactions;
  }
}
