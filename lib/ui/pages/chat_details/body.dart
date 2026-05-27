import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/attachment_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/features/database/tables/attachment_type.dart';
import 'package:reminiscence/ui/components/attachment_widget.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/components/toggle_button.dart';
import 'package:reminiscence/ui/pages/chat_details/attachment_details_data.dart';
import 'package:reminiscence/ui/pages/chat_details/chat_details_data.dart';
import 'package:reminiscence/ui/pages/chat_details/enums.dart';
import 'package:reminiscence/ui/pages/chat_details/media_grid_tile.dart';
import 'package:reminiscence/ui/pages/chat_details/participant_details_data.dart';
import 'package:reminiscence/ui/pages/chat_details/participants_list/participants_list_dialog.dart';
import 'package:reminiscence/ui/pages/data_viewer/chats_list/utils.dart';
import 'package:reminiscence/ui/providers/session_data.dart';
import 'package:url_launcher/url_launcher.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => BodyState();
}

class BodyState extends State<Body> {
  int selectedTab = 0;
  AttachmentSortOption attachmentSortOption = AttachmentSortOption.newestFirst;
  ParticipantSortOption participantSortOption = ParticipantSortOption.messages;
  bool participantSortAscending = false;

  late final Future<ChatDetailsData> detailsFuture;
  late final Future<List<int>> attachmentCountsFuture;
  late Future<List<AttachmentDetailsData>> attachmentsFuture;
  final attachmentOrderController = SelectionController<int>(1);

  final attachmentFutures = <int, Future<List<AttachmentDetailsData>>>{};

  @override
  void initState() {
    super.initState();

    detailsFuture = _loadDetails();
    attachmentsFuture = _getAttachmentsFuture();
    attachmentCountsFuture = _loadAttachmentCounts();
    attachmentOrderController.addListener(_onAttachmentOrderChanged);
  }

  @override
  void dispose() {
    attachmentOrderController.removeListener(_onAttachmentOrderChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: FutureBuilder(
          future: detailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || snapshot.data == null) {
              return _buildEmptyDetails("Could not load chat details.");
            }

            return _buildDetails(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildDetails(ChatDetailsData details) {
    final sessionData = Provider.of<SessionData>(context, listen: false);

    return FutureBuilder(
      future: attachmentsFuture,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final attachments = _sortAttachments(snapshot.data ?? []);

        if (selectedTab == 0) {
          return _buildMediaDetails(
            details: details,
            attachments: attachments,
            loading: loading,
            data: sessionData.data!,
          );
        }

        return _buildAttachmentDetails(
          details: details,
          attachments: attachments,
          loading: loading,
          data: sessionData.data!,
        );
      },
    );
  }

  Widget _buildMediaDetails({
    required ChatDetailsData details,
    required List<AttachmentDetailsData> attachments,
    required bool loading,
    required ReminiscenceData data,
  }) {
    final numRows = (attachments.length / 3).ceil();

    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: 1 + (loading || attachments.isEmpty ? 1 : numRows),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader(details);
        }

        if (loading) {
          return _buildLoadingAttachments();
        }

        if (attachments.isEmpty) {
          return _buildEmptyDetails("Nothing here yet.");
        }

        return _buildMediaRow(
          attachments: attachments.skip((index - 1) * 3).take(3).toList(),
          allAttachments: attachments,
          startIndex: (index - 1) * 3,
          data: data,
        );
      },
    );
  }

  Widget _buildAttachmentDetails({
    required ChatDetailsData details,
    required List<AttachmentDetailsData> attachments,
    required bool loading,
    required ReminiscenceData data,
  }) {
    if (selectedTab == 1) {
      return _buildLinkDetails(
        details: details,
        attachments: attachments,
        loading: loading,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: 1 + (loading || attachments.isEmpty ? 1 : attachments.length),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader(details);
        }

        if (loading) {
          return _buildLoadingAttachments();
        }

        if (attachments.isEmpty) {
          return _buildEmptyDetails("Nothing here yet.");
        }

        final attachment = attachments[index - 1];

        return _buildFileItem(attachment, data, showDivider: index > 1);
      },
    );
  }

  Widget _buildLinkDetails({
    required ChatDetailsData details,
    required List<AttachmentDetailsData> attachments,
    required bool loading,
  }) {
    const columnCount = 3;
    final rowCount = (attachments.length / columnCount).ceil();

    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: 1 + (loading || attachments.isEmpty ? 1 : rowCount),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader(details);
        }

        if (loading) {
          return _buildLoadingAttachments();
        }

        if (attachments.isEmpty) {
          return _buildEmptyDetails("Nothing here yet.");
        }

        final startIndex = (index - 1) * columnCount;
        final rowAttachments =
            attachments.skip(startIndex).take(columnCount).toList();

        return _buildLinkRow(
          rowAttachments,
          columnCount: columnCount,
          rowIndex: index - 1,
        );
      },
    );
  }

  Widget _buildHeader(ChatDetailsData details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(details),

        const SizedBox(height: 18.0),

        _buildParticipantsPreview(details),

        const SizedBox(height: 22.0),

        _buildSectionTitle("Attachments"),
        _buildTabs(),
        const SizedBox(height: 8.0),
        _buildAttachmentSortControl(),
        const SizedBox(height: 12.0),
      ],
    );
  }

  Widget _buildProfileHeader(ChatDetailsData details) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            details.chat.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12.0),

          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildHeaderMetric(
                Icons.people_alt_outlined,
                "${formatNumber(details.participants.length)} participants",
              ),
              _buildHeaderMetric(
                Icons.chat_bubble_outline_rounded,
                "${formatNumber(details.messageCount)} messages",
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          _buildDateRow(
            icon: Icons.first_page_rounded,
            title: "First message",
            value: _formatDateTime(details.firstMessageSentAt),
          ),
          const SizedBox(height: 8.0),
          _buildDateRow(
            icon: Icons.history_rounded,
            title: "Last message",
            value: _formatDateTime(details.lastMessageSentAt),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMetric(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6.0,
        children: [
          Icon(
            icon,
            size: 16.0,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.0, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10.0),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsPreview(ChatDetailsData details) {
    final participants = details.participants;
    final participantNames = participants.take(4).map((p) => p.name).join(", ");

    return InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: () => _showParticipants(details),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.groups_2_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 28.0,
            ),

            const SizedBox(width: 14.0),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Participants",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    participantNames.isEmpty
                        ? "No participants"
                        : participantNames,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8.0),

            Text(
              formatNumber(participants.length),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return FutureBuilder(
      future: attachmentCountsFuture,
      builder: (context, snapshot) {
        final counts = snapshot.data;

        return Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            _buildAttachmentTab(
              icon: Icons.photo_library_outlined,
              label: "Media",
              count: counts?[0],
              selected: selectedTab == 0,
              onTap: () => _changeTab(0),
            ),
            _buildAttachmentTab(
              icon: Icons.link_rounded,
              label: "Links",
              count: counts?[1],
              selected: selectedTab == 1,
              onTap: () => _changeTab(1),
            ),
            _buildAttachmentTab(
              icon: Icons.insert_drive_file_outlined,
              label: "Files",
              count: counts?[2],
              selected: selectedTab == 2,
              onTap: () => _changeTab(2),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttachmentSortControl() {
    attachmentOrderController.setSelectedQuietly(
      attachmentSortOption == AttachmentSortOption.oldestFirst ? 0 : 1,
    );

    return SizedBox(
      width: 150.0,
      child: ToggleButton(
        values: [
          ToggleButtonValue(
            icon: Icons.arrow_upward_rounded,
            title: "Ascending",
          ),
          ToggleButtonValue(
            icon: Icons.arrow_downward_rounded,
            title: "Descending",
          ),
        ],
        controller: attachmentOrderController,
        decoration: _buildToggleButtonDecoration(),
      ),
    );
  }

  BoxDecoration _buildToggleButtonDecoration() {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }

  void _onAttachmentOrderChanged() {
    setState(() {
      attachmentSortOption =
          attachmentOrderController.selected == 0
              ? AttachmentSortOption.oldestFirst
              : AttachmentSortOption.newestFirst;
    });
  }

  Widget _buildAttachmentTab({
    required IconData icon,
    required String label,
    required int? count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999.0),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 13.0, vertical: 9.0),
        decoration: BoxDecoration(
          color:
              selected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(999.0),
          border: Border.all(
            color:
                selected
                    ? colorScheme.primary.withValues(alpha: 0.32)
                    : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 7.0,
          children: [
            Icon(
              icon,
              size: 18.0,
              color:
                  selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color:
                    selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (selected && count != null)
              _buildAttachmentCountBadge(count, selected),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentCountBadge(int count, bool selected) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
      decoration: BoxDecoration(
        color:
            selected
                ? colorScheme.onPrimaryContainer.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Text(
        formatNumber(count),
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color:
              selected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMediaRow({
    required List<AttachmentDetailsData> attachments,
    required List<AttachmentDetailsData> allAttachments,
    required int startIndex,
    required ReminiscenceData data,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.0),
      child: Row(
        spacing: 4.0,
        children: [
          for (final (index, attachment) in attachments.indexed)
            Expanded(
              child: MediaGridTile(
                key: ValueKey(attachment.attachment.id),
                attachment: attachment,
                allAttachments: allAttachments,
                index: startIndex + index,
                data: data,
              ),
            ),

          for (int i = attachments.length; i < 3; i++)
            const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildLinkRow(
    List<AttachmentDetailsData> attachments, {
    required int columnCount,
    required int rowIndex,
  }) {
    return Padding(
      key: ValueKey(
        "links_${rowIndex}_${attachments.map((a) => a.attachment.id).join("_")}",
      ),
      padding: EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.0,
        children: [
          for (final attachment in attachments)
            Expanded(
              key: ValueKey(attachment.attachment.id),
              child: _buildLinkThumbnail(attachment.attachment.uri),
            ),

          for (int i = attachments.length; i < columnCount; i++)
            const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildLinkThumbnail(String link) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.0),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: InkWell(
            onTap: () => _openLink(link),
            child: AnyLinkPreview.builder(
              key: ValueKey(link),
              link: link,
              cache: const Duration(days: 1),
              placeholderWidget: _buildLinkThumbnailPlaceholder(
                Icons.link_rounded,
              ),
              errorWidget: _buildLinkThumbnailPlaceholder(
                Icons.link_off_rounded,
              ),
              itemBuilder: (context, metadata, imageProvider, svgImage) {
                if (svgImage != null) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      Padding(padding: EdgeInsets.all(16.0), child: svgImage),
                    ],
                  );
                }

                if (imageProvider != null) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }

                return _buildLinkThumbnailPlaceholder(Icons.link_rounded);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkThumbnailPlaceholder(IconData icon) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Center(
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 30.0,
        ),
      ),
    );
  }

  Widget _buildFileItem(
    AttachmentDetailsData attachment,
    ReminiscenceData data, {
    required bool showDivider,
  }) {
    return Column(
      children: [
        if (showDivider) const Divider(height: 1.0),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 8.0,
                children: [
                  Icon(
                    Icons.insert_drive_file_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 18.0,
                  ),
                  Expanded(
                    child: Text(
                      _getAttachmentTitle(attachment.attachment),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2.0),
              Text(
                _getAttachmentSubtitle(attachment),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              AttachmentWidget(attachment: attachment.attachment, data: data),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingAttachments() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyDetails(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _changeTab(int tab) {
    setState(() {
      selectedTab = tab;
      attachmentsFuture = _getAttachmentsFuture();
    });
  }

  Future<void> _openLink(String link) async {
    final uri = Uri.tryParse(link);

    if (uri == null) {
      return;
    }

    await launchUrl(uri);
  }

  Future<ChatDetailsData> _loadDetails() async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final chat = sessionData.chat!;

    final messageTimestampsFuture = sessionData.data!.db.messageDao
        .getMessageTimestamps(chat.id);
    final participantsFuture = _loadParticipants();

    final messageTimestamps = await messageTimestampsFuture;
    final participants = await participantsFuture;

    return ChatDetailsData.fromTimestamps(
      chat: chat,
      messageTimestamps: messageTimestamps,
      participants: participants,
    );
  }

  Future<List<ParticipantDetailsData>> _loadParticipants() async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final chat = sessionData.chat!;
    final participants = <ParticipantDetailsData>[];

    for (final participant in chat.participants) {
      final timestamps = await sessionData.data!.db.messageDao
          .getMessageTimestamps(chat.id, senderName: participant);

      participants.add(
        ParticipantDetailsData.fromTimestamps(
          name: participant,
          timestamps: timestamps,
        ),
      );
    }

    participants.sort((a, b) => b.messageCount.compareTo(a.messageCount));
    return participants;
  }

  Future<List<AttachmentDetailsData>> _loadAttachments() async {
    return _loadAttachmentsForTab(selectedTab);
  }

  Future<List<AttachmentDetailsData>> _loadAttachmentsForTab(int tab) async {
    final sessionData = Provider.of<SessionData>(context, listen: false);

    final messages = await sessionData.data!.db.messageDao
        .getMessagesWithAttachments(
          sessionData.chat!.id,
          _getAttachmentTypesForTab(tab),
        );

    final attachments = _getAttachmentDetails(messages, tab);

    return attachments;
  }

  Future<List<AttachmentDetailsData>> _getAttachmentsFuture() {
    attachmentFutures[selectedTab] ??= _loadAttachments();
    return attachmentFutures[selectedTab]!;
  }

  Future<List<AttachmentDetailsData>> _getAttachmentsFutureForTab(int tab) {
    attachmentFutures[tab] ??= _loadAttachmentsForTab(tab);
    return attachmentFutures[tab]!;
  }

  Future<List<int>> _loadAttachmentCounts() async {
    final attachments = await Future.wait([
      _getAttachmentsFutureForTab(0),
      _getAttachmentsFutureForTab(1),
      _getAttachmentsFutureForTab(2),
    ]);

    return attachments.map((attachments) => attachments.length).toList();
  }

  List<AttachmentDetailsData> _sortAttachments(
    List<AttachmentDetailsData> attachments,
  ) {
    final sortedAttachments = List<AttachmentDetailsData>.of(attachments);

    sortedAttachments.sort((a, b) {
      if (attachmentSortOption == AttachmentSortOption.oldestFirst) {
        return a.sentAt.compareTo(b.sentAt);
      }

      return b.sentAt.compareTo(a.sentAt);
    });

    return sortedAttachments;
  }

  List<AttachmentDetailsData> _getAttachmentDetails(
    List<MessageDto> messages,
    int tab,
  ) {
    final details = <AttachmentDetailsData>[];
    final attachmentTypes = _getAttachmentTypesForTab(tab);

    for (final message in messages) {
      for (final attachment in message.attachments) {
        if (!attachmentTypes.contains(attachment.type)) {
          continue;
        }

        details.add(
          AttachmentDetailsData(
            attachment: attachment,
            senderName: message.senderName,
            sentAt: DateTime.fromMillisecondsSinceEpoch(message.sentAt),
          ),
        );
      }
    }

    return details;
  }

  List<AttachmentType> _getAttachmentTypesForTab(int tab) {
    if (tab == 0) {
      return [AttachmentType.photo, AttachmentType.video];
    } else if (tab == 1) {
      return [AttachmentType.link];
    }

    return [AttachmentType.file];
  }

  Future<void> _showParticipants(ChatDetailsData details) async {
    await showDialog(
      context: context,
      builder:
          (context) => ParticipantsListDialog(
            participants: details.participants,
            initialSortOption: participantSortOption,
            initialSortAscending: participantSortAscending,
            onSortChanged: (sortOption, sortAscending) {
              participantSortOption = sortOption;
              participantSortAscending = sortAscending;
            },
          ),
    );
  }

  String _getAttachmentTitle(AttachmentDto attachment) {
    final fileName = p.basename(attachment.uri);

    if (fileName.trim().isEmpty) {
      return attachment.type.name;
    }

    return fileName;
  }

  String _getAttachmentSubtitle(AttachmentDetailsData attachment) {
    final sentAt = DateFormat("dd/MM/yyyy HH:mm").format(attachment.sentAt);

    return "${attachment.senderName} - $sentAt";
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return "None";
    }

    return DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
  }
}
