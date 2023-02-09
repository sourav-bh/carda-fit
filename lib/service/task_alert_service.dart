import 'dart:math';

import 'package:app/main.dart';
import 'package:app/view/task_alert_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

void _onSelectNotification(NotificationResponse details) {
  print('notification onClicked');
  if (details != null) {
    print('notification payload: $details');
  }

  String payload = details.payload ?? "2";
  int taskType = int.tryParse(payload) ?? TaskType.exercise.index;
  Navigator.pushNamed(navigatorKey.currentState!.context, taskAlertRoute, arguments: taskType);
}

class TaskAlertService {
  static const String taskWalkSteps = "task_walk_steps";
  static const String taskDrinkWater = "task_drink_water";
  static const String taskDoExercise = "task_do_exercise";
  static const String taskTakeBreak = "task_take_break";

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

  Future showNotificationWithDefaultSound(TaskType taskType) async {
    print('background notification added');

    String title = "";
    if (taskType == TaskType.steps) {
      title = 'Jetzt 100 Schritte gehen!';
    } else if (taskType == TaskType.exercise) {
      title = 'Es ist Zeit für eine schnelle Übung';
    } else if (taskType == TaskType.water) {
      title = 'Trinke jetzt ein Glas Wasser!';
    } else if (taskType == TaskType.breaks) {
      title = 'Du solltest jetzt eine Pause einlegen';
    }

    var androidSpec = const AndroidNotificationDetails(
      'DailyTaskCnlId',
      'DailyTask',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSSpec = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(android: androidSpec, iOS: iOSSpec);
    await _localNotificationsPlugin.show(Random().nextInt(9999) + 31, 'CardaFit Aufgabe',
        title, platformChannelSpecifics, payload: taskType.index.toString()
    );
  }

  void scheduleBackgroundTask() {
    print("background jobs scheduled");

    // steps
    Workmanager().registerPeriodicTask(
      "${Random().nextInt(99) + 24}",
      taskWalkSteps,
      frequency: const Duration(hours: 1),
      // initialDelay: const Duration(minutes: 45),
    );

    // water
    Workmanager().registerPeriodicTask(
      "${Random().nextInt(19) + 2}",
      taskDrinkWater,
      frequency: const Duration(hours: 1),
      // initialDelay: const Duration(minutes: 15),
    );

    // exercise
    Workmanager().registerPeriodicTask(
      "${Random().nextInt(999) + 170}",
      taskDoExercise,
      frequency: const Duration(hours: 1),
      // initialDelay: const Duration(minutes: 10),
    );

    // break
    Workmanager().registerPeriodicTask(
      "${Random().nextInt(9999) + 1500}",
      taskTakeBreak,
      frequency: const Duration(hours: 1),
      // initialDelay: const Duration(minutes: 30),
    );
  }

  // static void callbackDispatcherForBgAlert() {
  //   Workmanager().executeTask((task, inputData) {
  //     print("background task executed");
  //
  //     TaskType taskType = TaskType.exercise;
  //     // if (task == taskWalkSteps) {taskType = TaskType.steps;}
  //     // else if (task == taskDoExercise) {taskType = TaskType.exercise;}
  //     // else if (task == taskDrinkWater) {taskType = TaskType.water;}
  //     // else if (task == taskTakeBreak) {taskType = TaskType.breaks;}
  //
  //     TaskAlertService.instance.showNotificationWithDefaultSound(taskType);
  //     return Future.value(true);
  //   });
  // }

  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async {
    return await _localNotificationsPlugin.getNotificationAppLaunchDetails();
  }
}