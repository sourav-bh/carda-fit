
import 'package:app/model/exercise.dart';
import 'package:app/model/learning.dart';
import 'package:app/model/user_daily_target.dart';

class AppConstant {
  static const productionBuild = false;
  // static const baseURL = "http://10.0.2.2:8075"; // local
  static const baseURL = "https://kontikat.de/cardafit"; // live
}

class AppCache {
  String userName = 'User';
  String userServerId = '';
  int userDbId = 0;
  int quoteIndex = 0;
  List<Exercise> exercises = [];
  List<LearningContent> contents = [];
  String authToken = "";
  String fcmToken = "";

  AppCache._privateConstructor();
  static final AppCache instance = AppCache._privateConstructor();
}