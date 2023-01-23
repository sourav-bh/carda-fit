
import 'package:app/service/task_alert_service.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
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
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

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
  Workmanager().initialize(TaskAlertService.callbackDispatcherForBgAlert);
  runApp(const MyFitApp());
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

      return MaterialPageRoute(builder: (BuildContext context) => screen,
          settings: RouteSettings(arguments: arguments,));
    };
  }
}
