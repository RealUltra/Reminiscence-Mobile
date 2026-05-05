import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _privacyPolicyAssetPath = "assets/legal/privacy_policy.md";
const _termsOfServiceAssetPath = "assets/legal/terms_of_service.md";
const _privacyPolicyKeyPrefix = "privacy_policy";
const _termsOfServiceKeyPrefix = "terms_of_service";
const _shownKeySuffix = "shown";

Future<String> getPrivacyPolicy() {
  return rootBundle.loadString(_privacyPolicyAssetPath);
}

Future<String> getTermsOfService() {
  return rootBundle.loadString(_termsOfServiceAssetPath);
}

String getLastUpdated(String input) {
  final regex = RegExp("\\*\\*Last Updated:\\*\\* (\\d{4}-\\d{2}-\\d{2})");
  final match = regex.firstMatch(input);
  if (match == null) {
    return "";
  }
  return match.group(1)!;
}

Future<bool> privacyPolicyShown() async {
  final prefs = await SharedPreferences.getInstance();
  final privacyPolicy = await getPrivacyPolicy();
  final lastUpdated = getLastUpdated(privacyPolicy);
  final key = getPrivacyPolicyShownKey(lastUpdated);
  return prefs.getBool(key) ?? false;
}

Future<bool> termsOfServiceShown() async {
  final prefs = await SharedPreferences.getInstance();
  final termsOfService = await getTermsOfService();
  final lastUpdated = getLastUpdated(termsOfService);
  final key = getTermsOfServiceShownKey(lastUpdated);
  return prefs.getBool(key) ?? false;
}

Future<void> markPrivacyPolicyAsShown() async {
  final prefs = await SharedPreferences.getInstance();
  final privacyPolicy = await getPrivacyPolicy();
  final lastUpdated = getLastUpdated(privacyPolicy);
  final key = getPrivacyPolicyShownKey(lastUpdated);
  await prefs.setBool(key, true);
}

Future<void> markTermsOfServiceAsShown() async {
  final prefs = await SharedPreferences.getInstance();
  final termsOfService = await getTermsOfService();
  final lastUpdated = getLastUpdated(termsOfService);
  final key = getTermsOfServiceShownKey(lastUpdated);
  await prefs.setBool(key, true);
}

String getPrivacyPolicyShownKey(String lastUpdated) {
  return "${_privacyPolicyKeyPrefix}_${lastUpdated}_$_shownKeySuffix";
}

String getTermsOfServiceShownKey(String lastUpdated) {
  return "${_termsOfServiceKeyPrefix}_${lastUpdated}_$_shownKeySuffix";
}
