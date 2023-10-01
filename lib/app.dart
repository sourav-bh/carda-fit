import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/view/about_page.dart';
import 'package:app/view/alert_history_page.dart';
import 'package:app/view/details_webview_page.dart';
import 'package:app/view/edit_profile_page.dart';
import 'package:app/view/home_page.dart';
import 'package:app/view/landing_page.dart';
import 'package:app/view/leaderboard_page.dart';
import 'package:app/view/login_page.dart';
import 'package:app/view/registration_page.dart';
import 'package:app/view/splash_page.dart';
import 'package:app/view/task_alert_page.dart';
import 'package:app/view/user_activity_page.dart';
import 'package:app/view/user_learning_page.dart';
import 'package:app/view/user_profile_page.dart';
import 'package:flutter/material.dart';

const splashRoute = '/';
const landingRoute = '/landing';
const homeRoute = '/home';
const registerRoute = '/register';
const loginRoute = '/login';
const activityRoute = '/activity';
const learningRoute = '/learning';
const detailsWebRoute = '/details/web';
const leaderboardRoute = '/leaderboard';
const profileRoute = '/profile';
const editProfileRoute = '/profile/edit';
const taskAlertRoute = '/alert';
const alertHistoryRoute = '/alert/history';
const aboutUsRoute = '/aboutUs';

class CardaFitApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const CardaFitApp({super.key});

  @override
  _CardaFitAppState createState() => _CardaFitAppState();
}

class _CardaFitAppState extends State<CardaFitApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: CardaFitApp.navigatorKey,
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

// Die RouteFactory beinhaltet die Routen die mit einem Navigation Call aufgerufen werden können.
  RouteFactory _routes() {
    return (settings) {
      final dynamic arguments = settings.arguments;
      Widget screen;
      switch (settings.name) {
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
        case alertHistoryRoute:
          screen = const AlertHistoryPage();
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
