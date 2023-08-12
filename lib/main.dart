import 'package:app/api/api_manager.dart';
import 'package:app/app.dart';
import 'package:app/model/task_alert.dart';
import 'package:app/model/user_daily_target.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/shared_preference.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await TaskAlertService.instance.setup();

  _checkIfItsANewDay();
  _setupFireBase();

  runApp(CardaFitApp());
}

_setupFireBase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('Permission granted: ${settings.authorizationStatus}');

  messaging.subscribeToTopic('team');
  String? token = await messaging.getToken();
  print('FCM token: $token');
  if (token != null && token.isNotEmpty) {
    AppCache.instance.fcmToken = token;
    String? userId =
    await SharedPref.instance.getValue(SharedPref.keyUserServerId);
    if (userId != null && userId.isNotEmpty) {
      await ApiManager().updateDeviceToken(userId, token);
    }
  }

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  FirebaseMessaging.onMessage.listen(foregroundHandler);
}

Future<void> foregroundHandler(RemoteMessage message) async {
  print('Remote notification message data whilst in the foreground: ${message.data}');

  int snoozeDuration = await SharedPref.instance.getIntValue(SharedPref.keySnoozeDuration);
  int snoozedAt = await SharedPref.instance.getIntValue(SharedPref.keySnoozedAt);
  int currentTime = DateTime.now().millisecondsSinceEpoch;

  bool isUserSnoozedNow = currentTime - snoozedAt > snoozeDuration * 60 * 1000;

  if (isUserSnoozedNow == false) {
    await SharedPref.instance.deleteValue(SharedPref.keySnoozeDuration);
    await SharedPref.instance.deleteValue(SharedPref.keySnoozedAt);

    return; // don't show the alert as user set a snooze time currently
  } else if (message.notification != null) {
    var data = message.data['text'];
    String payload = data ?? "0";
    int taskType = int.tryParse(payload) ?? TaskType.exercise.index;

    if (CardaFitApp.navigatorKey.currentContext != null && CardaFitApp.navigatorKey.currentContext!.mounted) {
      debugPrint("-------> opening task alert page from FirebaseMessaging foreground listener");
      Navigator.pushNamed(CardaFitApp.navigatorKey.currentContext!, taskAlertRoute, arguments: taskType);
    }
  }
}

Future<void> backgroundHandler(RemoteMessage message) async {
  print('Remote notification message data whilst in the background: ${message.data}');

  //TODO: handle all background alerts here
}

_checkIfUserLoggedIn() async {
  bool isUserExist = await SharedPref.instance.hasValue(SharedPref.keyUserName);
  return isUserExist;
}

_checkIfItsANewDay() async {
  String? lastOpenDay = await SharedPref.instance.getValue(SharedPref.keyLastAppOpenDay);
  String currentDay = DateFormat('yMd').format(DateTime.now());
  if (lastOpenDay != currentDay) {
    await SharedPref.instance.saveStringValue(SharedPref.keyLastAppOpenDay, currentDay);
    DailyTarget completedTarget = DailyTarget(breaks: 0, waterGlasses: 0, exercises: 0, steps: 0);
    SharedPref.instance.saveJsonValue(SharedPref.keyUserCompletedTargets, completedTarget.toRawJson());
  }
}
