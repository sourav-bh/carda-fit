import 'package:app/model/exercise.dart';
import 'package:app/model/learning.dart';

//**Die AppConstant-Klasse enthält Konstanten, die in der gesamten Anwendung verwendet werden, 
//um bestimmte Einstellungen oder Verhaltensweisen festzulegen. */
class AppConstant {
  static const productionBuild = false;
  // static const baseURL = "http://10.0.2.2:8075"; // local
  static const baseURL = "https://kontikat.de/cardafit"; // live
  static const teamNameForCustomBuild = 'bgf'; // bgf-internal, unisiegen-thesis, dokuworks-company1, maipham-mai

  static const waterTaskValue = 1;
  static const exerciseTaskValue = 3;
  static const stepsTaskValue = 2;
  static const breakTaskValue = 1;
}

//**Die AppCache-Klasse dient dazu, Daten im Anwendungsverlauf zu speichern und
// sie zwischen verschiedenen Teilen der Anwendung zugänglich zu machen. 
//Sie wird oft verwendet, um temporäre Daten wie Benutzersitzungen oder zwischengespeicherte Informationen zu verwalten. */
class AppCache {
  String userName = 'User';
  String userServerId = '';
  int userDbId = 0;
  int quoteIndex = 0;
  List<Exercise> exercises = [];
  List<LearningContent> learningContents = [];
  String authToken = "";
  String fcmToken = "";
  bool didNotificationLaunchApp = false;

  AppCache._privateConstructor();
  static final AppCache instance = AppCache._privateConstructor();
}
