import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
// Speichert den Benutzernamen.
  static const keyUserName = "key_user_name";
//Speichert die Datenbank-ID des Benutzers.
  static const keyUserDbId = "key_user_db_id";
//Speichert die Server-ID des Benutzers.
  static const keyUserServerId = "key_user_server_id";
//Speichert das Firebase Cloud Messaging-Token des Geräts.
  static const keyDeviceToken = "key_fcm_token";
//Speichert Informationen über das Avatarbild des Benutzers 
  static const keyAvatarImage = "key_avatar_image";
//Speichert Informationen über den letzten Tag, an dem die App geöffnet wurde.
  static const keyLastAppOpenDay = "key_last_app_open_day";
//Speichert Benutzerziele.  
  static const keyUserTargets = "key_user_targets";
//Speichert Informationen über abgeschlossene Benutzerziele.
  static const keyUserCompletedTargets = "key_user_completed_targets";
//Speichert die Dauer der Snooze-Funktion in Minuten.
  static const keySnoozeDuration = "key_snooze_duration"; // in minutes
//Speichert den Zeitpunkt des letzten Snooze-Vorgangs.
  static const keySnoozedAt = "key_snoozed_at";

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

  saveDoubleValue(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(key, value);
  }

  saveBoolValue(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  getValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return prefs.get(key);
    }
    return null;
  }

  getIntValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return prefs.get(key);
    }
    return 0;
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
    deleteValue(keyUserTargets);
    deleteValue(keyDeviceToken);
    deleteValue(keyUserCompletedTargets);
    deleteValue(keyAvatarImage);
  }
}
