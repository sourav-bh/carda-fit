import 'dart:math';

import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:workmanager/workmanager.dart';

void _onSelectNotification(NotificationResponse details) {
  print('notification onClicked');
  if (details != null) {
    print('notification payload: $details');
  }
  Navigator.pushNamed(navigatorKey.currentState!.context, taskAlertRoute);
}

class TaskAlertService {
  TaskAlertService._privateConstructor();
  static final TaskAlertService instance = TaskAlertService._privateConstructor();

  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> setup() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings();

    const initSettings = InitializationSettings(android: androidSetting, iOS: iosSetting);

    await _localNotificationsPlugin.initialize(initSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,).then((_) {
      print('setupPlugin: setup success');
    }).catchError((Object error) {
      print('Error: $error');
    });
  }

  addNotification(int id, String title, String body, int endTime, String channelId, String channelName) async {
    print('foreground notification added');
    tzData.initializeTimeZones();
    final scheduleTime = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, endTime);

    final androidDetail = AndroidNotificationDetails(channelId, channelName);
    final iosDetail = DarwinNotificationDetails(threadIdentifier: channelId);
    final noticeDetail = NotificationDetails(
      iOS: iosDetail,
      android: androidDetail,
    );

    await _localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduleTime,
      noticeDetail,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Future showNotificationWithDefaultSound() async {
    print('background notification added');

    // Show a notification after every 15 minute with the first
    // appearance happening a minute after invoking the method
    var androidSpec = const AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        importance: Importance.max,
        priority: Priority.high,
    );
    var iOSSpec = DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(android: androidSpec, iOS: iOSSpec);
    await _localNotificationsPlugin.show(Random().nextInt(99) + 2, 'GeeksforGeeks',
        'Your are one step away to connect with GeeksforGeeks',
        platformChannelSpecifics, payload: 'Default_Sound'
    );
  }

  void scheduleBackgroundTask() {
    Workmanager().registerPeriodicTask(
      "${Random().nextInt(99) + 2}",
      "createTaskAlert",
      frequency: const Duration(minutes: 15), // Minimum frequency is 15 minute set by Android.
    );
  }

  static void callbackDispatcherForBgAlert() {
    Workmanager().executeTask((task, inputData) {
      TaskAlertService.instance.showNotificationWithDefaultSound();
      return Future.value(true);
    });
  }

  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async {
    return await _localNotificationsPlugin.getNotificationAppLaunchDetails();
  }
}