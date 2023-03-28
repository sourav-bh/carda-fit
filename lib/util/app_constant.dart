
import 'package:app/model/exercise.dart';
import 'package:app/model/learning.dart';
import 'package:app/model/user_daily_target.dart';

class AppConstant {
  static const productionBuild = false;
  static const baseURL = "http://10.0.2.2:8075";
}

class AppCache {
  String userName = 'User';
  int userId = 0;
  int quoteIndex = 0;
  DailyTarget? dailyTarget;
  List<Exercise> exercises = [];
  List<LearningContent> contents = [];
  String authToken = "";

  AppCache._privateConstructor();
  static final AppCache instance = AppCache._privateConstructor();
}