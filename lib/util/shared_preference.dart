import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static const keyUserName = "key_user_name";
  static const keyUserInfo = "key_user_info";
  static const keyAppSettings = "key_app_settings";

  SharedPref._privateConstructor();
  static final SharedPref instance = SharedPref._privateConstructor();

  saveJsonValue(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  saveStringValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  saveIntValue(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  getValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return prefs.get(key);
    }
    return null;
  }

  getJsonValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return json.decode(prefs.getString(key) ?? '');
    }
    return null;
  }

  Future<bool> hasValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  deleteValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  clearCacheWithoutSettings() async {
    deleteValue(keyUserName);
    deleteValue(keyUserInfo);
    deleteValue(keyAppSettings);
  }
}