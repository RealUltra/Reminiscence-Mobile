import 'package:flutter/material.dart';
import 'package:reminiscence/features/database/models/attachment_type.dart';
import 'package:reminiscence/ui/pages/search/filter.dart';
import 'package:reminiscence/ui/pages/search/filter_badge.dart';
import 'package:reminiscence/ui/pages/search/filter_type.dart';

class FiltersLayout extends StatelessWidget {
  const FiltersLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8.0,

        children: [
          const SizedBox(width: 4.0),

          FilterBadge(
            Filter(type: FilterType.sender, value: "Mirza Rameez Ahmed Baig"),
          ),
          FilterBadge(
            Filter(type: FilterType.attachment, value: AttachmentType.audio),
          ),
          FilterBadge(
            Filter(type: FilterType.sentBefore, value: DateTime.now()),
          ),
          FilterBadge(Filter(type: FilterType.sentOn, value: DateTime.now())),
          FilterBadge(
            Filter(type: FilterType.sentAfter, value: DateTime.now()),
          ),

          const SizedBox(width: 4.0),
        ],
      ),
    );
  }
}
