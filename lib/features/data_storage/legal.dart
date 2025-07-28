import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getPrivacyPolicy() {
  return rootBundle.loadString("assets/legal/privacy_policy.txt"); 
}

Future<String> getTermsOfService() {
  return rootBundle.loadString("assets/legal/terms_of_service.txt"); 
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
  final key = "privacy_policy_${lastUpdated}_shown";
  return prefs.getBool(key) ?? false;
}

Future<bool> termsOfServiceShown() async {
  final prefs = await SharedPreferences.getInstance();
  final termsOfService = await getTermsOfService();
  final lastUpdated = getLastUpdated(termsOfService);
  final key = "terms_of_service_${lastUpdated}_shown";
  return prefs.getBool(key) ?? false;
}

Future<void> markPrivacyPolicyAsShown() async {
  final prefs = await SharedPreferences.getInstance();
  final privacyPolicy = await getPrivacyPolicy();
  final lastUpdated = getLastUpdated(privacyPolicy);
  final key = "privacy_policy_${lastUpdated}_shown";
  await prefs.setBool(key, true);
}

Future<void> markTermsOfServiceAsShown() async {
  final prefs = await SharedPreferences.getInstance();
  final termsOfService = await getTermsOfService();
  final lastUpdated = getLastUpdated(termsOfService);
  final key = "terms_of_service_${lastUpdated}_shown";
  await prefs.setBool(key, true);
}