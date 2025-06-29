import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminiscence/ui/pages/search/filter.dart';
import 'package:reminiscence/ui/pages/search/filter_type.dart';

class FilterBadge extends StatelessWidget {
  final Filter filter;
  final VoidCallback? onRemove;

  const FilterBadge(this.filter, {super.key, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,

      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 12.0, 8.0),

        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16.0),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8.0,

          children: [
            Text(
              getFilterTypeText(),

              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              getFilterValueText(),

              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Icon(
              Icons.close,
              size: 14.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  String getFilterTypeText() {
    if (filter.type == FilterType.sender) {
      return "from:";
    } else if (filter.type == FilterType.attachment) {
      return "has:";
    } else if (filter.type == FilterType.sentBefore) {
      return "before:";
    } else if (filter.type == FilterType.sentOn) {
      return "during:";
    } else {
      return "after:";
    }
  }

  String getFilterValueText() {
    if (filter.type == FilterType.sender) {
      return filter.senderName!;
    } else if (filter.type == FilterType.attachment) {
      return filter.attachmentType!.name;
    } else {
      return _formatDate(filter.date!);
    }
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy').format(dt);
  }
}
