import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/chat_details/participant_details_data.dart';
import 'package:reminiscence/ui/pages/data_viewer/chats_list/utils.dart';

class ParticipantListItem extends StatelessWidget {
  final ParticipantDetailsData participant;

  const ParticipantListItem({super.key, required this.participant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            participant.name,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            "${formatNumber(participant.messageCount)} messages",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
