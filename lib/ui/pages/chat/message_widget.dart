import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/data_storage/data_storage.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/pages/chat/attachment_widget.dart';
import 'package:reminiscence/ui/pages/chat/reaction_widget.dart';
import 'package:reminiscence/ui/pages/chat/view_reactions_widget.dart';

class MessageWidget extends StatefulWidget {
  final ReminiscenceData data;
  final String? userName;
  final MessageDto message;
  final MessageDto? previousMessage;

  const MessageWidget({
    super.key,
    required this.data,
    required this.userName,
    required this.message,
    this.previousMessage,
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
    // The sender name is shown when:
    // 1. The previous message was by a different sender
    // 2. The previous message was over 5 minutes ago.

    final topPadding =
        (widget.previousMessage == null)
            ? 0.0
            : (_shouldShowSenderName() ? 16.0 : 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Visibility(
          visible: _shouldShowDivider(),
          child: _buildDivider(context),
        ),

        GestureDetector(
          onTapDown: (details) => _highlightTemporarily(),
          onTapUp: (details) => tapUp(),
          onLongPressStart: (details) => showContextMenu(context, details),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            color:
                isHighlighted
                    ? Theme.of(context).colorScheme.surfaceContainerHigh
                    : Colors.transparent,

            margin: EdgeInsets.fromLTRB(0, topPadding, 0, 0),
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            width: double.infinity,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: _shouldShowSenderName(),
                  child: _buildSenderInfo(context),
                ),
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
          ),
        ),
      ],
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

  Widget _buildDivider(BuildContext context) {
    final text = DateFormat(
      'EEEE, dd MMMM yyyy',
    ).format(DateTime.fromMillisecondsSinceEpoch(widget.message.sentAt));

    final bottomPadding =
        (widget.previousMessage == null)
            ? 24.0
            : (_shouldShowSenderName() ? 0.0 : 16.0);

    final topPadding = (widget.previousMessage == null) ? 0.0 : 24.0;

    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),

      child: Row(
        children: [
          Expanded(child: Divider(thickness: 2, color: color)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(child: Divider(thickness: 2, color: color)),
        ],
      ),
    );
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

  void _highlightTemporarily() {
    final duration = const Duration(milliseconds: 600);

    highlightStart = DateTime.now().millisecondsSinceEpoch;
    setState(() => isHighlighted = true);

    highlightTimer = Timer(duration, () {
      if (mounted) {
        setState(() => isHighlighted = false);
      }
    });
  }

  void tapUp() {
    final expectedDuration = 200;
    final actualDuration =
        DateTime.now().millisecondsSinceEpoch - highlightStart;
    final timeRemaining = max(expectedDuration - actualDuration, 0);

    if (highlightTimer != null) {
      highlightTimer!.cancel();
    }

    Timer(
      Duration(milliseconds: timeRemaining),
      () => setState(() => isHighlighted = false),
    );
  }

  Future<void> showContextMenu(
    BuildContext context,
    LongPressStartDetails details,
  ) async {
    final pinned = await isPinned(widget.message.id);

    if (!context.mounted) return;

    final result = await showMenu(
      context: context,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        MediaQuery.of(context).size.width - details.globalPosition.dx,
        MediaQuery.of(context).size.height - details.globalPosition.dy,
      ),

      items: <PopupMenuEntry>[
        PopupMenuItem(
          enabled: false, // Makes this item non-clickable
          child: Text(
            DateFormat('EEEE, dd MMMM yyyy HH:mm:ss').format(
              DateTime.fromMillisecondsSinceEpoch(widget.message.sentAt),
            ),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const PopupMenuDivider(),

        PopupMenuItem(
          value: 'viewReactions',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.emoji_emotions, size: 16.0),
              SizedBox(width: 12),
              Text(
                "View Reactions",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        PopupMenuItem(
          value: 'copyText',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.copy, size: 16.0),
              SizedBox(width: 12),
              Text("Copy Text", style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),

        PopupMenuItem(
          value: pinned ? "unpinMessage" : "pinMessage",
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.push_pin, size: 16.0),
              SizedBox(width: 12),
              Text(
                pinned ? "Unpin Message" : "Pin Message",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        PopupMenuItem(
          value: 'markAsSystem',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.stars, size: 16.0),
              SizedBox(width: 12),
              Text(
                "Mark as System Message",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );

    if (result == null || !context.mounted) {
      return;
    }

    switch (result) {
      case "viewReactions":
        {
          showDialog(
            context: context,
            barrierDismissible: true, // Dismiss on tapping outside
            builder: (BuildContext context) {
              return Dialog(
                child: ViewReactionsWidget.fromData(_getReactionsList()),
              );
            },
          );
          break;
        }

      case "copyText":
        {
          Clipboard.setData(ClipboardData(text: widget.message.content));
          break;
        }

      case "pinMessage":
        {
          await pinMessage(widget.message.id);
          break;
        }

      case "unpinMessage":
        {
          await unpinMessage(widget.message.id);
          break;
        }

      case "markAsSystem":
        {
          // Mark as system message here
        }
    }
  }

  bool _shouldShowDivider() {
    if (widget.previousMessage == null) {
      return true;
    }

    final messageDt = DateTime.fromMillisecondsSinceEpoch(
      widget.message.sentAt,
    );
    final previousMessageDt = DateTime.fromMillisecondsSinceEpoch(
      widget.previousMessage!.sentAt,
    );

    return (messageDt.day != previousMessageDt.day) ||
        (messageDt.month != previousMessageDt.month) ||
        (messageDt.year != previousMessageDt.year);
  }

  bool _shouldShowSenderName() {
    return (widget.previousMessage == null) ||
        (widget.message.senderName != widget.previousMessage!.senderName) ||
        ((widget.message.sentAt - widget.previousMessage!.sentAt) >
            senderNameExpiryTime) ||
        _shouldShowDivider();
  }

  List<dynamic> _getReactionsList() {
    final data = jsonDecode(widget.message.rawData);
    List<dynamic> reactions = data["reactions"] ?? [];
    return reactions;
  }
}
