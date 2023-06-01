import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static const keyUserName = "key_user_name";
  static const keyUserDbId = "key_user_db_id";
  static const keyUserServerId = "key_user_server_id";
  static const keyUserAvatar = "key_user_avatar";
  static const keyUserTargets = "key_user_targets";
  static const keyUserComplTargets = "key_user_completed_targets";
  static const keyDeviceToken = "key_fcm_token";

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

  clearCache() async {
    deleteValue(keyUserName);
    deleteValue(keyUserDbId);
    deleteValue(keyUserServerId);
    deleteValue(keyUserAvatar);
    deleteValue(keyUserTargets);
    deleteValue(keyDeviceToken);
  }
}
