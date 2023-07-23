import 'dart:math';
import 'dart:io';

import 'package:app/api/api_manager.dart';
import 'package:app/util/app_constant.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
int snoozeTime = SharedPref.instance.getValue(SharedPref.keySnoozeActualTime);
var snoozeDuration = SharedPref.instance.getValue(SharedPref.keySnoozeDuration);
int? timeToSnooze;
int? snoozeEndTime;

// class TimeSaver {
//   static int? currentTime;
//   static void saveCurrentTime() {
//     snoozeTime = DateTime.now().millisecondsSinceEpoch;
//     if (kDebugMode) {
//       print('Current time saved: $snoozeTime');
//     }
//   }
//
//   int addMinutesToCurrentTime(int minutesToAdd) {
//     if (snoozeTime != null) {
//       return snoozeTime + (minutesToAdd * 60 * 1000);
//     } else {
//       return 0; // Return 0 or some default value if currentTime is null
//     }
//   }
//
//   int? whenSnoozeEnds(int snoozeDurationInMinutes) {
//     snoozeEndTime =
//         (DateTime.now().millisecondsSinceEpoch + snoozeDurationInMinutes);
//     SharedPref.instance
//         .saveIntValue(SharedPref.keySnoozeEndTime, snoozeEndTime!);
//     return snoozeEndTime;
//   }
//
//   // Function to check if the snooze period is over
//   Future<bool> isSnoozeOver() async {
//     int? snoozeEndTime =
//         await SharedPref.instance.getValue(SharedPref.keySnoozeEndTime);
//     if (snoozeEndTime != null &&
//         snoozeEndTime <= DateTime.now().millisecondsSinceEpoch) {
//       // Snooze period is over
//       return true;
//     } else {
//       // Snooze period is not over yet
//       return false;
//     }
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await TaskAlertService.instance.setup();

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

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    // print(
    //     'Remote notification message data whilst in the foreground: ${message.data}');
    // // TODO: @Justin -- implement here your code to get the value from shared pref
    // bool snoozeBool =
    //     SharedPref.instance.getValue(SharedPref.keySnoozeDecision);
    // TimeSaver timeSaver = TimeSaver();
    // bool isSnoozeOver = await timeSaver.isSnoozeOver();
    // // TODO: @Justin -- check the start time and duration with the current time
    // //Conditions must have a static type of 'bool'. Try changing the condition.
    // while (snoozeBool == true) {
    //   if (snoozeDuration == '5 min') {
    //     timeToSnooze = timeSaver.addMinutesToCurrentTime(5);
    //     print('The time to Snooze is: $timeToSnooze');
    //   } else if (snoozeDuration == '10 min') {
    //     timeToSnooze = timeSaver.addMinutesToCurrentTime(10);
    //     print('The time to Snooze is: $timeToSnooze');
    //   } else if (snoozeDuration == '30 min') {
    //     timeToSnooze = timeSaver.addMinutesToCurrentTime(30);
    //     print('The time to Snooze is: $timeToSnooze');
    //   } else if (snoozeDuration == '60 min') {
    //     timeToSnooze = timeSaver.addMinutesToCurrentTime(60);
    //     print('The time to Snooze is: $timeToSnooze');
    //   } else if (snoozeDuration == '120 min') {
    //     timeToSnooze = timeSaver.addMinutesToCurrentTime(60 * 2);
    //     print('The time to Snooze is: $timeToSnooze');
    //   } else if (snoozeDuration == '1 Tag') {
    //     timeToSnooze = timeSaver.addMinutesToCurrentTime(60 * 24);
    //     print('The time to Snooze is: $timeToSnooze');
    //   } else {
    //     snoozeBool = false;
    //   }
    // }
    // if (isSnoozeOver == false) {
    //   return;
    // } else
      if (message.notification != null) {
      var data = message.data['text'];
      String payload = data ?? "0";
      int taskType = int.tryParse(payload) ?? TaskType.exercise.index;

      print(
          "-------> opening task alert page from FirebaseMessaging foregorund listener");
      Navigator.pushNamed(navigatorKey.currentState!.context, taskAlertRoute,
          arguments: taskType);
    }
  });

  runApp(const MyFitApp());
}

_checkIfUserLoggedIn() async {
  bool isUserExist = await SharedPref.instance.hasValue(SharedPref.keyUserName);
  return isUserExist;
}

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

      return MaterialPageRoute(
          builder: (BuildContext context) => screen,
          settings: RouteSettings(
            arguments: arguments,
          ));
    };
  }
}
