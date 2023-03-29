
import 'dart:math';

import 'package:app/service/task_alert_service.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/about_page.dart';
import 'package:app/view/task_alert_page.dart';
import 'package:app/view/details_webview_page.dart';
import 'package:app/view/home_page.dart';
import 'package:app/view/landing_page.dart';
import 'package:app/view/leaderboard_page.dart';
import 'package:app/view/learning_details_page.dart';
import 'package:app/view/splash_page.dart';
import 'package:app/view/user_activity_page.dart';
import 'package:app/view/user_info_page.dart';
import 'package:app/view/user_learning_page.dart';
import 'package:app/view/user_profile_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

const splashRoute = '/';
const landingRoute = '/landing';
const homeRoute = '/home';
const userInfoRoute = '/userInfo';
const activityRoute = '/activity';
const learningRoute = '/learning';
const learningDetailsRoute = '/learning/details';
const detailsWebRoute = '/details/web';
const leaderboardRoute = '/leaderboard';
const profileRoute = '/profile';
const taskAlertRoute = '/alert';
const aboutUsRoute = '/aboutUs';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TaskAlertService.instance.setup();
  Workmanager().initialize(callbackDispatcherForBgAlert);

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

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');

      var data = message.data['text'];
      print('remote payload data: $data');
      String payload = data ?? "2";
      int taskType = int.tryParse(payload) ?? TaskType.exercise.index;

      print("-------> opening task alert page from _onSelectNotification in Alert service");
      Navigator.pushNamed(navigatorKey.currentState!.context, taskAlertRoute, arguments: taskType);
    }
  });

  runApp(const MyFitApp());
}

void callbackDispatcherForBgAlert() {
    Workmanager().executeTask((task, inputData) {
      print("background task executed");

      if (_checkIfUserLoggedIn() == false) return Future.value(true);

      TaskType taskType = TaskType.exercise;
      if (task == TaskAlertService.taskWalkSteps) {taskType = TaskType.steps;}
      else if (task == TaskAlertService.taskDoExercise) {taskType = TaskType.exercise;}
      else if (task == TaskAlertService.taskDrinkWater) {taskType = TaskType.water;}
      else if (task == TaskAlertService.taskTakeBreak) {taskType = TaskType.breaks;}

      TaskAlertService.instance.showNotificationWithDefaultSound(taskType);
      return Future.value(true);
    });
}

_checkIfUserLoggedIn() async {
  bool isUserExist = await SharedPref.instance.hasValue(SharedPref.keyUserName);
  return isUserExist;
}

// void scheduleBackgroundTask() {
//   print("background jobs scheduled");
//
//   // steps
//   Workmanager().registerPeriodicTask(
//     "${Random().nextInt(99) + 24}",
//     TaskAlertService.taskWalkSteps,
//     frequency: const Duration(hours: 1),
//     initialDelay: const Duration(minutes: 45),
//   );
//
//   // water
//   Workmanager().registerPeriodicTask(
//     "${Random().nextInt(19) + 2}",
//     TaskAlertService.taskDrinkWater,
//     frequency: const Duration(hours: 1),
//     initialDelay: const Duration(minutes: 15),
//   );
//
//   // exercise
//   Workmanager().registerPeriodicTask(
//     "${Random().nextInt(999) + 170}",
//     TaskAlertService.taskDoExercise,
//     frequency: const Duration(hours: 1),
//   );
//
//   // break
//   Workmanager().registerPeriodicTask(
//     "${Random().nextInt(9999) + 1500}",
//     TaskAlertService.taskTakeBreak,
//     frequency: const Duration(hours: 1),
//     initialDelay: const Duration(minutes: 30),
//   );
// }

class MyFitApp extends StatefulWidget {
  const MyFitApp({Key? key}) : super(key: key);

  @override
  _MyFitAppState createState() => _MyFitAppState();
}

class _MyFitAppState extends State<MyFitApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Health & Fitness Pro',
      theme: ThemeData(
        primarySwatch: CommonUtil.createMaterialColor(AppColor.lightPink),
        textTheme: AppTextStyle.appTextTheme,
        fontFamily: 'LeagueSpartan',
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: _routes(),
      home: const SplashPage(),
    );
  }

  RouteFactory _routes() {
    return (settings) {
      final dynamic arguments = settings.arguments;
      Widget screen;
      switch (settings.name) {
        case splashRoute:
          screen = const SplashPage();
          break;
        case userInfoRoute:
          screen = const UserInfoPage();
          break;
        case landingRoute:
          screen = const LandingPage();
          break;
        case homeRoute:
          screen = const HomePage();
          break;
        case activityRoute:
          screen = const UserActivityPage();
          break;
        case learningRoute:
          screen = const UserLearningPage();
          break;
        case learningDetailsRoute:
          screen = const LearningDetailsPage();
          break;
        case detailsWebRoute:
          screen = const DetailsWebPage();
          break;
        case leaderboardRoute:
          screen = const LeaderBoardPage();
          break;
        case profileRoute:
          screen = const UserProfilePage();
          break;
        case taskAlertRoute:
          screen = const TaskAlertPage();
          break;
        case aboutUsRoute:
          screen = const AboutUsPage();
          break;
        default:
          return null;
      }

      return MaterialPageRoute(builder: (BuildContext context) => screen,
          settings: RouteSettings(arguments: arguments,));
    };
  }
}
