import 'package:app/model/exercise.dart';
import 'package:app/model/learning.dart';

class AppConstant {
  static const productionBuild = false;
  // static const baseURL = "http://10.0.2.2:8075"; // local
  static const baseURL = "https://kontikat.de/cardafit"; // live
  static const teamNameForCustomBuild =
      'bgf'; // bgf-internal, unisiegen-thesis, dokuworks-company1, maipham-mai

  static const waterTaskValue = 1;
  static const exerciseTaskValue = 3;
  static const stepsTaskValue = 2;
  static const breakTaskValue = 1;
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
  bool didNotificationLaunchApp = false;

  AppCache._privateConstructor();
  static final AppCache instance = AppCache._privateConstructor();
}
