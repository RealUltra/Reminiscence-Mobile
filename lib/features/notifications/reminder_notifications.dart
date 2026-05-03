import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import "package:reminiscence/features/data_storage/notifications.dart";

final reminderNotifications = FlutterLocalNotificationsPlugin();

const _emailReminderBaseId = 100;
const _emailReminderDays = 7;
const _returnReminderId = 2;

const _reminderNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    "reminders",
    "Reminders",
    channelDescription: "Reminders to come back to Reminiscence.",
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  ),
);

Future<void> initializeReminderNotifications() async {
  tz_data.initializeTimeZones();

  const android = AndroidInitializationSettings('@mipmap/launcher_icon');

  await reminderNotifications.initialize(
    settings: const InitializationSettings(android: android),
  );
}

Future<void> refreshReminderNotifications() async {
  final mode = await getReminderMode();

  await reminderNotifications.cancelAll();

  switch (mode) {
    case ReminderMode.checkEmail:
      await scheduleEmailReminder();
      return;

    case ReminderMode.returnToReminiscence:
      await scheduleReturnReminder();
      return;
  }
}

Future<void> scheduleEmailReminder() async {
  for (int i = 0; i < _emailReminderDays; i++) {
    await reminderNotifications.zonedSchedule(
      id: _emailReminderBaseId + i,
      title: "Waiting for your data?",
      body:
          "It may be in your email now. Come back to Reminiscence when it arrives.",
      scheduledDate: _dailyEmailReminderDate(i + 1),
      notificationDetails: _reminderNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "check_email",
    );
  }
}

Future<void> scheduleReturnReminder() async {
  final scheduledDate = _randomReturnReminderDate();
  final message = _randomReturnReminderMessage();

  await reminderNotifications.zonedSchedule(
    id: _returnReminderId,
    title: message.title,
    body: message.body,
    scheduledDate: scheduledDate,
    notificationDetails: _reminderNotificationDetails,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    payload: "return_to_reminiscence",
  );
}

tz.TZDateTime _dailyEmailReminderDate(int daysAhead) {
  final now = tz.TZDateTime.now(tz.local);
  return tz.TZDateTime(tz.local, now.year, now.month, now.day + daysAhead, 10);
}

tz.TZDateTime _randomReturnReminderDate() {
  final random = Random();
  final now = tz.TZDateTime.now(tz.local);
  final daysAhead = 4 + random.nextInt(5);

  // Schedule one return reminder 4-8 days from now, at a random time before 8 AM.
  return tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day + daysAhead,
    random.nextInt(8),
    random.nextInt(60),
  );
}

_ReminderMessage _randomReturnReminderMessage() {
  final messages = [
    _ReminderMessage(
      "A memory is waiting",
      "Come back to Reminiscence and revisit an old conversation.",
    ),
    _ReminderMessage(
      "Take a look back",
      "Open Reminiscence when you have a quiet moment.",
    ),
    _ReminderMessage(
      "Remember this?",
      "Your old messages are ready whenever you are.",
    ),
    _ReminderMessage(
      "Step back in",
      "Return to Reminiscence and rediscover something familiar.",
    ),
  ];

  return messages[Random().nextInt(messages.length)];
}

class _ReminderMessage {
  final String title;
  final String body;

  const _ReminderMessage(this.title, this.body);
}
