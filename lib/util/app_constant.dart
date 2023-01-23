
import 'package:app/model/exercise.dart';
import 'package:app/model/learning.dart';
import 'package:app/model/user_daily_target.dart';

class AppConstant {
  static const productionBuild = false;
  static const baseURL = "https://connect.fra.lucca.it/api/1.0";

  /* Constant values app website, support and social media urls */
  static const privacyPolicyURL = "https://www.xtragift.com/en/privacy-policy";
  static const websiteURL = "https://www.xtragift.com/";
  static const supportPhone = "+8801714110380";
  static const facebookPageURL = "https://www.facebook.com/allxtradeals/";
  static const twitterPageURL = "https://twitter.com/allxtradeals";
  static const tiktokPageURL = "https://www.tiktok.com/channel/UCUwWA64CY7jDAx37X-f0SVA";
  static const instagramPageURL = "https://www.instagram.com/company/14483436/";
  /* Constant values app website, support and social media urls */
}

class AppCache {
  String userName = 'User';
  int userId = 0;
  int quoteIndex = 0;
  DailyTarget? dailyTarget;
  List<Exercise> exercises = [];
  List<LearningContent> contents = [];

  AppCache._privateConstructor();
  static final AppCache instance = AppCache._privateConstructor();
}