import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

class MyDatePickerDialog extends StatefulWidget {
  const MyDatePickerDialog({super.key});

  @override
  State<MyDatePickerDialog> createState() => _MyDatePickerDialogState();
}

class _MyDatePickerDialogState extends State<MyDatePickerDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        constraints: BoxConstraints(maxWidth: 400, maxHeight: 400),

        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
        ),

        child: CalendarCarousel(
          onDayPressed: (date, _) => onDatePressed(context, date),

          // HEADER
          headerTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          leftButtonIcon: Icon(
            Icons.chevron_left,
            color: Theme.of(context).iconTheme.color,
          ),
          rightButtonIcon: Icon(
            Icons.chevron_right,
            color: Theme.of(context).iconTheme.color,
          ),
          headerMargin: const EdgeInsets.symmetric(vertical: 8.0),

          // WEEKDAY LABELS
          weekdayTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),

          // DAYS TEXT STYLES
          daysTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          weekendTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
          todayTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          selectedDayTextStyle: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSecondary),

          // BACKGROUND COLORS
          todayButtonColor: Theme.of(context).colorScheme.primary,
          selectedDayButtonColor: Theme.of(context).colorScheme.secondary,
          inactiveDaysTextStyle: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).disabledColor),

          // BORDER COLORS
          todayBorderColor: Theme.of(context).colorScheme.primary,
          selectedDayBorderColor: Theme.of(context).colorScheme.secondary,
          daysHaveCircularBorder: true,

          // DISABLED STYLING
          inactiveWeekendTextStyle: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).disabledColor),

          // DOT COLOR (for event indicators)
          markedDateIconBuilder:
              (event) => Icon(
                Icons.circle,
                color: Theme.of(context).colorScheme.primary,
                size: 6,
              ),

          // Optional layout settings
          weekFormat: false,
          showOnlyCurrentMonthDate: true,
        ),
      ),
    );
  }

  void onDatePressed(BuildContext context, DateTime date) {
    Navigator.of(context).pop(date);
  }
}
