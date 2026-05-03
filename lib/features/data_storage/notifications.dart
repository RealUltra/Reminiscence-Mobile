import 'package:shared_preferences/shared_preferences.dart';

const _appFirstLaunchedAtKey = "app_first_launched_at";
const _downloadPopupViewedAtKey = "download_popup_viewed_at";
const _dataLoadedAtKey = "data_loaded_at";

Future<DateTime> getAppFirstLaunchedAt() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getInt(_appFirstLaunchedAtKey);

  if (value != null) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  final now = DateTime.now();
  await prefs.setInt(_appFirstLaunchedAtKey, now.millisecondsSinceEpoch);
  return now;
}

Future<DateTime?> getDownloadPopupViewedAt() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getInt(_downloadPopupViewedAtKey);
  return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
}

Future<void> markDownloadPopupViewed() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(
    _downloadPopupViewedAtKey,
    DateTime.now().millisecondsSinceEpoch,
  );
}

Future<DateTime?> getDataLoadedAt() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getInt(_dataLoadedAtKey);
  return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
}

Future<void> markDataLoaded() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_dataLoadedAtKey, DateTime.now().millisecondsSinceEpoch);
}

Future<ReminderMode> getReminderMode() async {
  await getAppFirstLaunchedAt();

  final popupViewedAt = await getDownloadPopupViewedAt();
  final dataLoadedAt = await getDataLoadedAt();

  if (popupViewedAt != null &&
      (dataLoadedAt == null || popupViewedAt.isAfter(dataLoadedAt))) {
    return ReminderMode.checkEmail;
  }

  return ReminderMode.returnToReminiscence;
}

enum ReminderMode { checkEmail, returnToReminiscence }
