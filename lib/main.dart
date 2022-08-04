import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/view/about_page.dart';
import 'package:app/view/details_webview_page.dart';
import 'package:app/view/home_page.dart';
import 'package:app/view/leaderboard_page.dart';
import 'package:app/view/learning_details_page.dart';
import 'package:app/view/privacy_policy_page.dart';
import 'package:app/view/splash_page.dart';
import 'package:app/view/terms_conditions_page.dart';
import 'package:app/view/user_info_page.dart';
import 'package:app/view/user_profile_page.dart';
import 'package:flutter/material.dart';

const splashRoute = '/';
const homeRoute = '/home';
const userInfoRoute = '/userInfo';
const learningDetailsRoute = '/learning/details';
const detailsWebRoute = '/details/web';
const leaderboardRoute = '/leaderboard';
const profileRoute = '/profile';
const privacyPolicyRoute = '/privacy';
const termsConditionsRoute = '/tnc';
const aboutUsRoute = '/aboutUs';

void main() {
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
      title: 'Health & Fitness Pro',
      theme: ThemeData(
        primarySwatch: CommonUtil.createMaterialColor(AppColor.primary),
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
        case homeRoute:
          screen = const HomePage();
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
        case privacyPolicyRoute:
          screen = const PrivacyPolicyPage();
          break;
        case termsConditionsRoute:
          screen = const TermsConditionsPage();
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
