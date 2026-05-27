import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/chat_details/enums.dart';
import 'package:reminiscence/ui/pages/chat_details/participant_details_data.dart';
import 'package:reminiscence/ui/pages/chat_details/participants_list/participant_list_item.dart';
import 'package:reminiscence/ui/pages/chat_details/participants_list/participants_list_controls.dart';

class ParticipantsListDialog extends StatefulWidget {
  final List<ParticipantDetailsData> participants;
  final ParticipantSortOption initialSortOption;
  final bool initialSortAscending;
  final void Function(ParticipantSortOption sortOption, bool sortAscending)
  onSortChanged;

  const ParticipantsListDialog({
    super.key,
    required this.participants,
    required this.initialSortOption,
    required this.initialSortAscending,
    required this.onSortChanged,
  });

  @override
  State<ParticipantsListDialog> createState() => ParticipantsListDialogState();
}

class ParticipantsListDialogState extends State<ParticipantsListDialog> {
  late ParticipantSortOption sortOption;
  late bool sortAscending;

  @override
  void initState() {
    super.initState();

    sortOption = widget.initialSortOption;
    sortAscending = widget.initialSortAscending;
  }

  @override
  Widget build(BuildContext context) {
    final participants = _sortParticipants(widget.participants);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.only(top: 20.0),
        constraints: BoxConstraints(maxWidth: 400.0, maxHeight: 500.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),

            const SizedBox(height: 20.0),

            ParticipantsListControls(
              sortOption: sortOption,
              sortAscending: sortAscending,
              onSortOptionChanged: _setSortOption,
              onSortAscendingChanged: _setSortAscending,
            ),

            const SizedBox(height: 8.0),
            const Divider(),

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: participants.length,
                separatorBuilder: (_, _) => const Divider(height: 1.0),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: ParticipantListItem(
                      participant: participants[index],
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1.0),

            Padding(padding: EdgeInsets.all(16.0), child: _buildDoneButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        "Participants",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).pop(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        elevation: 8.0,
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
    );
  }

  void _setSortOption(ParticipantSortOption value) {
    setState(() {
      sortOption = value;
      widget.onSortChanged(sortOption, sortAscending);
    });
  }

  void _setSortAscending(bool value) {
    setState(() {
      sortAscending = value;
      widget.onSortChanged(sortOption, sortAscending);
    });
  }

  List<ParticipantDetailsData> _sortParticipants(
    List<ParticipantDetailsData> participants,
  ) {
    final sortedParticipants = List<ParticipantDetailsData>.of(participants);

    sortedParticipants.sort((a, b) {
      final comparison = _compareParticipants(a, b);

      if (sortAscending) {
        return comparison;
      }

      return -comparison;
    });

    return sortedParticipants;
  }

  int _compareParticipants(
    ParticipantDetailsData first,
    ParticipantDetailsData second,
  ) {
    if (sortOption == ParticipantSortOption.name) {
      return first.name.toLowerCase().compareTo(second.name.toLowerCase());
    }

    return first.messageCount.compareTo(second.messageCount);
  }
}
