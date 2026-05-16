import 'package:shared_preferences/shared_preferences.dart';

const _dataLoadsKey = "data_loads";
const _reviewRequestCountKey = "review_request_count";
const _lastReviewRequestKey = "last_review_request";

Future<int> getDataLoads({SharedPreferences? prefs}) async {
  prefs ??= await SharedPreferences.getInstance();
  await prefs.reload();
  return prefs.getInt(_dataLoadsKey) ?? 0;
}

Future<int> setDataLoads(int loads, {SharedPreferences? prefs}) async {
  prefs ??= await SharedPreferences.getInstance();
  await prefs.setInt(_dataLoadsKey, loads);
  return loads;
}

Future<void> incrementDataLoads({SharedPreferences? prefs}) async {
  prefs ??= await SharedPreferences.getInstance();
  final currentLoads = await getDataLoads(prefs: prefs);
  await setDataLoads(currentLoads + 1, prefs: prefs);
}

Future<int> getReviewRequestCount({SharedPreferences? prefs}) async {
  prefs ??= await SharedPreferences.getInstance();
  await prefs.reload();
  return prefs.getInt(_reviewRequestCountKey) ?? 0;
}

Future<int> setReviewRequestCount(int count, {SharedPreferences? prefs}) async {
  prefs ??= await SharedPreferences.getInstance();
  await prefs.setInt(_reviewRequestCountKey, count);
  return count;
}

Future<void> incrementReviewRequestCount({SharedPreferences? prefs}) async {
  prefs ??= await SharedPreferences.getInstance();
  final currentCount = await getReviewRequestCount(prefs: prefs);
  await setReviewRequestCount(currentCount + 1, prefs: prefs);
}

Future<DateTime?> getLastReviewRequest({SharedPreferences? prefs}) async {
  prefs ??= await SharedPreferences.getInstance();
  await prefs.reload();

  final timestamp = prefs.getInt(_lastReviewRequestKey);
  if (timestamp == null) return null;

  return DateTime.fromMillisecondsSinceEpoch(timestamp);
}

Future<void> setLastReviewRequest(
  DateTime dateTime, {
  SharedPreferences? prefs,
}) async {
  prefs ??= await SharedPreferences.getInstance();
  await prefs.setInt(_lastReviewRequestKey, dateTime.millisecondsSinceEpoch);
}
