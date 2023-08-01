import 'dart:math';
import 'dart:io';
import 'package:app/view/edit_profile_page.dart';
import 'package:app/view/login_page.dart';
import 'package:app/view/registration_page.dart';
import 'package:app/view/working_schedule_page.dart';
import 'package:sqflite/sqflite.dart';
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
import 'package:app/view/user_learning_page.dart';
import 'package:app/view/user_profile_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:app/view/summary_page.dart';

const splashRoute = '/';
const landingRoute = '/landing';
const homeRoute = '/home';
const registerRoute = '/register';
const loginRoute = '/login';
const activityRoute = '/activity';
const learningRoute = '/learning';
const learningDetailsRoute = '/learning/details';
const detailsWebRoute = '/details/web';
const leaderboardRoute = '/leaderboard';
const profileRoute = '/profile';
const editProfileRoute = '/profile/edit';
const taskAlertRoute = '/alert';
const aboutUsRoute = '/aboutUs';
const workingScheduleRoute = '/working/schedule';
const summaryPageRoute = '/summary/page/';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
int? timeToSnooze;
int? snoozeEndTime;
int selectedSnoozeTime = 0;
bool? isUserSnoozedNow;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    print(
        'Remote notification message data whilst in the foreground: ${message.data}');

    var currentTime = DateTime.now().millisecondsSinceEpoch;
    var snoozeTime =
        await SharedPref.instance.getValue(SharedPref.keySnoozeActualTime);
    String snoozeDuration =
        await SharedPref.instance.getValue(SharedPref.keySnoozeDuration);
    debugPrint(snoozeDuration);

    int extractNumbersAndCombine(String snoozeDuration) {
      int selectedSnoozeTime = 0;
      String currentNumber = '';

      for (int i = 0; i < snoozeDuration.length; i++) {
        if (snoozeDuration[i].contains(RegExp(r'[0-9]'))) {
          currentNumber += snoozeDuration[i];
        } else {
          if (currentNumber.isNotEmpty) {
            int num = int.tryParse(currentNumber) ?? 0;
            selectedSnoozeTime = selectedSnoozeTime * 10 + num;
            currentNumber = '';
          }
        }
      }

      if (currentNumber.isNotEmpty) {
        int num = int.tryParse(currentNumber) ?? 0;
        selectedSnoozeTime = selectedSnoozeTime * 10 + num;
      }

      return selectedSnoozeTime;
    }

    int selectedSnoozeTime = extractNumbersAndCombine(snoozeDuration);
    print('Selected Snooze Time: $selectedSnoozeTime');
    int snoozeEndTime = snoozeTime +
        (selectedSnoozeTime * 60000); // Convert snoozeMinutes to milliseconds

    print('Snooze End Time: $snoozeEndTime');
    if (currentTime >= snoozeEndTime) {
      isUserSnoozedNow = true;
    } else {
      isUserSnoozedNow = false;
    }

    SharedPref.instance
        .saveBoolValue(SharedPref.keyIsSnoozed, isUserSnoozedNow!);

    if (isUserSnoozedNow == false) {
      return;
    } else if (message.notification != null) {
      var data = message.data['text'];
      String payload = data ?? "0";
      int taskType = int.tryParse(payload) ?? TaskType.exercise.index;

      print(
          "-------> opening task alert page from FirebaseMessaging foreground listener");
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
        case summaryPageRoute:
          screen = SummaryPage();
          break;
        case workingScheduleRoute:
          screen = const WorkingSchedulePage();
          break;
        case splashRoute:
          screen = const SplashPage();
          break;
        case registerRoute:
          screen = const RegistrationPage();
          break;
        case loginRoute:
          screen = const LoginPage();
          break;
        case editProfileRoute:
          screen = const EditProfilePage();
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
