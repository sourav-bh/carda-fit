import 'dart:ffi';
import 'dart:io';

import 'package:app/api/api_manager.dart';
import 'package:app/app.dart';
import 'package:app/model/task_alert.dart';
import 'package:app/model/user_daily_target.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/splash_page.dart';
import 'package:app/view/task_alert_page.dart';
import 'package:excel/excel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Die `main`-Methode ist der Einstiegspunkt der Anwendung. Diese Klasse initialisiert die Flutter-App und konfiguriert Firebase.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Hier wird die präferierte Bildschirmorientierung auf vertikal gesetzt und somit die horizontale Bildschirmansicht blockiert.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  AppCache.instance.didNotificationLaunchApp =
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  _checkIfItsANewDay();
  _setupFireBase();
  await initLocalNotificationPlugin();

  // final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  // String? payload = notificationAppLaunchDetails?.notificationResponse?.payload;
  // print('payload from on launch from notification click= $payload');
  // Widget homePage = CommonUtil.isNullOrEmpty(payload)
  //     ? const SplashPage()
  //     : TaskAlertPage(taskType: int.tryParse(payload!) ?? TaskType.exercise.index);
  // runApp(CardaFitApp(home: const SplashPage()));

  runApp(const CardaFitApp());
}

//**Diese Funktion konfiguriert Firebase Cloud Messaging (FCM) in der App.
//Sie fordert Benutzerberechtigungen für das Empfangen von Benachrichtigungen an, abonniert ein FCM-Thema ('team'), ruft das FCM-Token ab und aktualisiert es auf dem Server, wenn der Benutzer angemeldet ist.
//Die Funktion registriert auch Handler für das Verarbeiten von FCM-Nachrichten im Vordergrund und im Hintergrund der App. */
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

  FirebaseMessaging.onMessage.listen(foregroundHandler);
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
}

//**Dies ist der Handler für eingehende FCM-Benachrichtigungen, wenn die App im Vordergrund läuft.
//Der Handler überprüft, ob der Benutzer Benachrichtigungen snoozed hat und erstellt dann einen Eintrag in der lokalen Datenbank für die empfangene Benachrichtigung.
//Je nach Bedingungen öffnet er die TaskAlertPage, um dem Benutzer Details zur Benachrichtigung anzuzeigen. */
Future<void> foregroundHandler(RemoteMessage message) async {
  print(
      'Remote notification message data whilst in the foreground: ${message.data}');

  int snoozeDuration =
      await SharedPref.instance.getIntValue(SharedPref.keySnoozeDuration);
  int snoozedAt =
      await SharedPref.instance.getIntValue(SharedPref.keySnoozedAt);
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  bool isUserSnoozedNow = currentTime - snoozedAt <= snoozeDuration * 60 * 1000;

  String title = message.data["title"];
  String desc = message.data["message"];
  int alertType = int.parse(message.data["text"]);

  AlertHistory alertHistory = AlertHistory(
      dbId: 0,
      title: title,
      description: desc,
      taskType: TaskType.values[alertType],
      taskStatus: isUserSnoozedNow ? TaskStatus.snoozed : TaskStatus.pending,
      taskCreatedAt: CommonUtil.getCurrentTimeAsDbFormat(),
      completedAt: "");

  int alertHistoryId =
      await DatabaseHelper.instance.addAlertHistory(alertHistory);
  debugPrint(
      "-------> Alert history item saved in DB from foreground listener: $alertHistoryId");

  if (isUserSnoozedNow) {
    return; // don't show the alert as user set a snooze time currently
  } else {
    await SharedPref.instance.deleteValue(SharedPref.keySnoozeDuration);
    await SharedPref.instance.deleteValue(SharedPref.keySnoozedAt);

    // mark all previous history items as missed alerts, for the same type of task
    await DatabaseHelper.instance
        .batchUpdateAlertHistoryItemAsMissed(alertType);

    // if (message.notification != null) {
    var data = message.data['text'];
    String payload = data ?? "0";
    int taskType = int.tryParse(payload) ?? TaskType.exercise.index;

    if (CardaFitApp.navigatorKey.currentContext != null &&
        CardaFitApp.navigatorKey.currentContext!.mounted) {
      TaskAlertPageData alertPageData = TaskAlertPageData(
          viewMode: 0, taskType: taskType, taskHistoryId: alertHistoryId);

      debugPrint(
          "-------> opening task alert page from FirebaseMessaging foreground listener");
      Navigator.pushNamed(
          CardaFitApp.navigatorKey.currentContext!, taskAlertRoute,
          arguments: alertPageData);
    }
    // }
  }
}

//**Dies ist der Handler für eingehende FCM-Benachrichtigungen, wenn die App im Hintergrund läuft.
//Der Handler überprüft ähnlich wie der foregroundHandler, ob der Benutzer Benachrichtigungen snoozed hat und erstellt einen Eintrag in der lokalen Datenbank.
//Falls die Benachrichtigung nicht gesnoozed wurde, zeigt der Handler eine lokale Benachrichtigung an. */
Future<void> backgroundHandler(RemoteMessage message) async {
  print(
      'Remote notification message data whilst in the background: ${message.data}');

  int snoozeDuration =
      await SharedPref.instance.getIntValue(SharedPref.keySnoozeDuration);
  int snoozedAt =
      await SharedPref.instance.getIntValue(SharedPref.keySnoozedAt);
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  bool isUserSnoozedNow = currentTime - snoozedAt <= snoozeDuration * 60 * 1000;

  String title = message.data["title"];
  String desc = message.data["message"];
  int alertType = int.parse(message.data["text"]);

  AlertHistory alertHistory = AlertHistory(
      dbId: 0,
      title: title,
      description: desc,
      taskType: TaskType.values[alertType],
      taskStatus: isUserSnoozedNow ? TaskStatus.snoozed : TaskStatus.pending,
      taskCreatedAt: CommonUtil.getCurrentTimeAsDbFormat(),
      completedAt: "");

  if (!isUserSnoozedNow) {
    // Markiert alle vorherigen Verlaufselemente als verpasste Alarme für denselben Aufgabentypen.
    await DatabaseHelper.instance
        .batchUpdateAlertHistoryItemAsMissed(alertType);
  } else {
    debugPrint('Marking previous history items as missed alerts');

    // Nutzer hat Snooze (Schlummern) aktiviert, daher Alarm nicht zeigen.
    debugPrint('User is snoozed, not showing the alert');
    return;
  }

  int alertHistoryId =
      await DatabaseHelper.instance.addAlertHistory(alertHistory);
  debugPrint(
      "-------> Alert history item saved in DB from background listener: $alertHistoryId");

  // Print statements
  await SharedPref.instance.deleteValue(SharedPref.keySnoozeDuration);
  await SharedPref.instance.deleteValue(SharedPref.keySnoozedAt);

  // Zeigt die Alarm-Benachrichtigung.
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('carda_fit', 'CardaFit',
          channelDescription: 'CardaFit Alerts',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');

  const DarwinNotificationDetails iOSNotificationDetails =
      DarwinNotificationDetails(
    presentAlert:
        true, // Spielt einen Alarm, wenn die Benachrichtigung angezeigt wird und die Anwendung im Vordergrund ist (nur ab iOS 10).
    presentSound:
        true, // Spielt einen Ton ab, wenn die Benachrichtigung angezeigt wird und die Anwendung im Vordergrund ist (nur ab iOS 10).
  );

  const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails, iOS: iOSNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
      alertType, title, desc, notificationDetails,
      payload: alertHistoryId.toString());
}

//**Diese Funktion überprüft, ob der Benutzer in der App angemeldet ist.
//Sie prüft das Vorhandensein eines Benutzernamens in den Shared Preferences. */
_checkIfUserLoggedIn() async {
  bool isUserExist = await SharedPref.instance.hasValue(SharedPref.keyUserName);
  return isUserExist;
}

//**Diese Funktion überprüft, ob ein neuer Tag angebrochen ist.
//Sie vergleicht den zuletzt geöffneten Tag mit dem aktuellen Tag und setzt die täglichen Ziele zurück, wenn ein neuer Tag beginnt. */
_checkIfItsANewDay() async {
  String? lastOpenDay =
      await SharedPref.instance.getValue(SharedPref.keyLastAppOpenDay);
  String currentDay = DateFormat('yMd').format(DateTime.now());
  if (lastOpenDay != currentDay) {
    await SharedPref.instance
        .saveStringValue(SharedPref.keyLastAppOpenDay, currentDay);
    DailyTarget completedTarget =
        DailyTarget(breaks: 0, waterGlasses: 0, exercises: 0, steps: 0);
    SharedPref.instance.saveJsonValue(
        SharedPref.keyUserCompletedTargets, completedTarget.toRawJson());

    // TODO: clear all previous alert history items as it's a new day
    await DatabaseHelper.instance.clearAlertHistoryTable();
  }
}

//**Diese Funktion initialisiert das lokale Benachrichtigungsplugin (flutterLocalNotificationsPlugin).
//Sie fordert auch Berechtigungen für Benachrichtigungen auf verschiedenen Plattformen (Android/iOS) an
// und konfiguriert die Initialisierungseinstellungen für die Benachrichtigungen. */
Future<void> initLocalNotificationPlugin() async {
  _requestPermissions();

  const AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const DarwinInitializationSettings initSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  final InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid, iOS: initSettingsIOS, macOS: null);

  await flutterLocalNotificationsPlugin.initialize(initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse);
}

//**Diese Funktion fordert Benachrichtigungsberechtigungen für Android und iOS an, falls erforderlich. */
Future<void> _requestPermissions() async {
  if (Platform.isIOS || Platform.isMacOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  } else if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? grantedNotificationPermission =
        await androidImplementation?.requestNotificationsPermission();
  }
}

//**Dieser Handler wird aufgerufen, wenn eine lokale Benachrichtigung auf iOS empfangen wird.
//Ähnlich wie foregroundHandler und backgroundHandler überprüft dieser Handler,
//ob der Benutzer die Benachrichtigung gesnoozed hat, erstellt einen Eintrag in der Datenbank und zeigt eine lokale Benachrichtigung an. */
_onDidReceiveLocalNotificationInIos(id, title, body, payload) async {
  print('Remote firebase message whilst for iOS');

  int snoozeDuration =
      await SharedPref.instance.getIntValue(SharedPref.keySnoozeDuration);
  int snoozedAt =
      await SharedPref.instance.getIntValue(SharedPref.keySnoozedAt);
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  bool isUserSnoozedNow = currentTime - snoozedAt <= snoozeDuration * 60 * 1000;

  int alertType = int.parse(payload);

  AlertHistory alertHistory = AlertHistory(
      dbId: 0,
      title: title,
      description: body,
      taskType: TaskType.values[alertType],
      taskStatus: isUserSnoozedNow ? TaskStatus.snoozed : TaskStatus.pending,
      taskCreatedAt: CommonUtil.getCurrentTimeAsDbFormat(),
      completedAt: "");

  if (!isUserSnoozedNow) {
    // Markiert alle vorherigen Verlaufselemente als verpasste Alarme für denselben Aufgabentypen.
    await DatabaseHelper.instance
        .batchUpdateAlertHistoryItemAsMissed(alertType);
  }

  int alertHistoryId =
      await DatabaseHelper.instance.addAlertHistory(alertHistory);
  debugPrint(
      "-------> Alert history item saved in DB from background listener: $alertHistoryId");

  if (isUserSnoozedNow) {
    return; // den Alarm nicht zeigen, da der Nutzer Schlummerzeit (snooze time) eingestellt hat.
  } else {
    await SharedPref.instance.deleteValue(SharedPref.keySnoozeDuration);
    await SharedPref.instance.deleteValue(SharedPref.keySnoozedAt);

    // show the alert notification
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('carda_fit', 'CardaFit',
            channelDescription: 'CardaFit Alerts',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails(
      presentAlert:
          true, // Spielt einen Alarm, wenn die Benachrichtigung angezeigt wird und die Anwendung im Vordergrund ist (nur ab iOS 10).
      presentSound:
          true, // Spielt einen Ton ab, wenn die Benachrichtigung angezeigt wird und die Anwendung im Vordergrund ist (nur ab iOS 10).
    );

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iOSNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        alertType, title, body, notificationDetails,
        payload: alertHistoryId.toString());
  }
}

void _onDidReceiveNotificationResponse(NotificationResponse response) async {
  if (response.payload != null) {
    // Handle notification payload
    int taskHistoryId = int.tryParse(response.payload!) ?? 0;
    // Navigate to the specific task alert page
    _navigateToTaskPage(taskHistoryId);
  }
}

void _navigateToTaskPage(int taskHistoryId) async {
  print('Navigating to task page with history ID: $taskHistoryId');
  // Ensure Navigator is ready and context is mounted
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    AlertHistory? alertHistory =
        await DatabaseHelper.instance.getAlertHistory(taskHistoryId);
    if (alertHistory != null) {
      int taskType = alertHistory.taskType.index;
      if (CardaFitApp.navigatorKey.currentState?.context != null) {
        Navigator.pushNamed(
            CardaFitApp.navigatorKey.currentState!.context, taskAlertRoute,
            arguments: TaskAlertPageData(
                viewMode: 0, taskType: taskType, taskHistoryId: taskHistoryId));
      }
    } else {
      print('Alert history not found for ID: $taskHistoryId');
    }
  });
}

//**Dieser Handler wird aufgerufen, wenn eine lokale Benachrichtigung auf iOS empfangen wird,  */
void _onDidReceiveLocalNotification(NotificationResponse details) async {
  print('Remote firebase message _onDidReceiveLocalNotification');

  // Nur für iOS-Plattform handhaben.
  if (!Platform.isIOS) return;

  String? payload = details.payload;
  print('payload from on launch from notification click= $payload');

  if (!CommonUtil.isNullOrEmpty(payload)) {
    int taskHistoryId = int.tryParse(payload!) ?? 0;
    AlertHistory? alertHistory =
        await DatabaseHelper.instance.getAlertHistory(taskHistoryId);
    int taskType = alertHistory?.taskType.index ?? TaskType.exercise.index;

    if (CardaFitApp.navigatorKey.currentContext != null &&
        CardaFitApp.navigatorKey.currentContext!.mounted) {
      TaskAlertPageData alertPageData = TaskAlertPageData(
          viewMode: 0, taskType: taskType, taskHistoryId: taskHistoryId);

      print(
          "-------> opening task alert page from _handleMessage for push notification onClicked from background in iOS");
      Navigator.pushNamed(
          CardaFitApp.navigatorKey.currentContext!, taskAlertRoute,
          arguments: alertPageData);
    }
  }
}
