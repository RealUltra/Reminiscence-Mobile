import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final reminderNotifications = FlutterLocalNotificationsPlugin();

const notificationIdInterval = 1000;

const emailReminderBaseId = 1000;
const emailReminderOffsets = [1, 3];
// "d" for days, "h" for hours, "m" for minutes, "s" for seconds.
const emailReminderOffsetUnits = "d";

const returnReminderBaseId = 2000;
const returnReminderCount = 8;
const returnReminderInterval = 2;
// "d" for days, "h" for hours, "m" for minutes, "s" for seconds.
const returnReminderIntervalUnits = "d";

const emailReminderMessages = [
  ReminderMessage(
    "Your Instagram data may be ready",
    "Check your email, then bring the archive back to Reminiscence.",
  ),
  ReminderMessage(
    "Quick archive check",
    "Instagram may have sent your data download. Check your email when you can.",
  ),
];

const returnReminderMessages = [
  ReminderMessage(
    "Pick up where you left off",
    "Open Reminiscence when you have a quiet moment.",
  ),
  ReminderMessage(
    "Ready for a look back?",
    "Open Reminiscence and bring your Instagram memories with you.",
  ),
  ReminderMessage(
    "Your messages can wait, but not forever",
    "Come back to Reminiscence and continue setting things up.",
  ),
];

const reminderNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    "reminders",
    "Reminders",
    channelDescription: "Reminders to come back to Reminiscence.",
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  ),
);

class ReminderMessage {
  final String title;
  final String body;

  const ReminderMessage(this.title, this.body);
}

Future<void> initializeReminderNotifications() async {
  await initializeTimeZone();

  await reminderNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    ),
  );
}

Future<void> syncReturnReminderCampaign() async {
  if (!await canScheduleNotifications()) return;

  final pendingRequests =
      await reminderNotifications.pendingNotificationRequests();
  final pendingReturnReminders = pendingRequests.where(
    (request) => isReturnReminderId(request.id),
  );

  if (pendingReturnReminders.isNotEmpty) return;

  await scheduleReturnReminderBatch();
}

Future<void> restartEmailReminderCampaign() async {
  await cancelEmailReminderCampaign();
  if (!await canScheduleNotifications()) return;

  await scheduleEmailReminderCampaign();
}

Future<void> initializeTimeZone() async {
  tz_data.initializeTimeZones();

  try {
    final localTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimeZone.identifier));
  } catch (_) {
    // If timezone lookup fails, keep the timezone package's fallback location.
  }
}

Future<bool> canScheduleNotifications() async {
  final status = await Permission.notification.status;
  return status.isGranted || status.isLimited || status.isProvisional;
}

Future<void> cancelEmailReminderCampaign() async {
  for (int i = 0; i < notificationIdInterval; i++) {
    await reminderNotifications.cancel(id: emailReminderBaseId + i);
  }
}

Future<void> scheduleEmailReminderCampaign() async {
  for (int i = 0; i < emailReminderOffsets.length; i++) {
    final message = emailReminderMessages[i];

    await reminderNotifications.zonedSchedule(
      id: emailReminderBaseId + i,
      title: message.title,
      body: message.body,
      scheduledDate: localReminderDate(
        offset: emailReminderOffsets[i],
        unit: emailReminderOffsetUnits,
        hour: 10,
      ),
      notificationDetails: reminderNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "check_email",
    );
  }
}

Future<void> scheduleReturnReminderBatch() async {
  for (int i = 0; i < returnReminderCount; i++) {
    final message = returnReminderMessages[i % returnReminderMessages.length];

    await reminderNotifications.zonedSchedule(
      id: returnReminderBaseId + i,
      title: message.title,
      body: message.body,
      scheduledDate: localReminderDate(
        offset: returnReminderInterval * (i + 1),
        unit: returnReminderIntervalUnits,
        hour: 19,
      ),
      notificationDetails: reminderNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "return_to_reminiscence",
    );
  }
}

tz.TZDateTime localReminderDate({
  required int offset,
  required String unit,
  required int hour,
}) {
  final now = tz.TZDateTime.now(tz.local);

  if (unit != "d") {
    return now.add(durationFromUnit(offset, unit));
  }

  return tz.TZDateTime(tz.local, now.year, now.month, now.day + offset, hour);
}

Duration durationFromUnit(int value, String unit) {
  switch (unit) {
    case "h":
      return Duration(hours: value);
    case "m":
      return Duration(minutes: value);
    case "s":
      return Duration(seconds: value);
    default:
      throw ArgumentError.value(
        unit,
        "unit",
        'Expected "d", "h", "m", or "s".',
      );
  }
}

bool isReturnReminderId(int id) {
  return id >= returnReminderBaseId &&
      id < returnReminderBaseId + notificationIdInterval;
}
