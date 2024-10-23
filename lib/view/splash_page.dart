import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:app/app.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/util/shared_preference.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/exercise.dart';
import '../model/exercise_steps.dart';
import '../model/learning.dart';
import '../model/user_info.dart';
import '../service/database_helper.dart';
import '../util/common_util.dart';

// Die Splah Page stellt den Ladebildschirm der App dar.
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  var _quoteIndex = 0;

  @override
  void initState() {
    super.initState();

    //**In der initState-Methode wird überprüft, ob Daten bereits in der Datenbank gespeichert sind (checkDataSaved).
    // Falls ja, wird nach einer Verzögerung zur nächsten Seite navigiert.
    //Wenn keine Daten vorhanden sind, werden Übungsdaten und Lernmaterialien aus einer Excel-Datei geladen und
    // in die Datenbank eingefügt. Dann wird auch zur nächsten Seite navigiert. */
    checkDataSaved().then((isDataSaved) {
      if (isDataSaved) {
        // Daten sind bereits gespeichert, gehe weiter zur nächsten Seite.
        Timer(const Duration(seconds: 3), () {
          _loadDataFromDatabase();
          _goToNextPage();
        });
      } else {
        // Daten sind nicht gespeichert, lade und speicher die Daten aus der Excel-Datei.
        _loadExerciseDataFromAsset();
        _quoteIndex = Random().nextInt(DataLoader.quotes.length);
        AppCache.instance.quoteIndex = _quoteIndex;

        // Gehe weiter zur nächsten Seite nach kurzer Verzögerung.
        Timer(const Duration(seconds: 3), () {
          _goToNextPage();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

//**Diese asynchrone Methode überprüft, ob Daten bereits in der Datenbank gespeichert sind, indem sie die Datenbank nach Übungen und Lerninhalten abfragt.
//*  Sie gibt einen booleschen Wert zurück, der angibt, ob Daten gespeichert sind oder nicht. */
  Future<bool> checkDataSaved() async {
    // bool check if data is saved
    final dbHelper = DatabaseHelper.instance;

    // final exercises = await dbHelper.getExercises();
    final learningContents = await dbHelper.getLearningContents();
    AppCache.instance.learningContents = learningContents;

    return/*exercises.isNotEmpty && */  learningContents.isNotEmpty;
  }

  Future<void> _loadDataFromDatabase() async {
    final dbHelper = DatabaseHelper.instance;

    // Daten aus der Datenbank abrufen
    final learningContents = await dbHelper.getLearningContents();
    AppCache.instance.learningContents = learningContents;
  }

//**Eine Methode zum Laden von Übungsdaten aus einer Excel-Datei im Assets-Ordner der App.
//Die Daten werden zeilenweise aus der Excel-Datei gelesen, analysiert und in eine lokale Datenbank eingefügt. */
  Future<void> _loadExerciseDataFromAsset() async {
    UserInfo? userInfo =
        await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    var userCondition = "";
    if (userInfo != null &&
        !CommonUtil.isNullOrEmpty(userInfo.medicalConditions)) {
      userCondition = userInfo.medicalConditions!;
    }

    ByteData data = await rootBundle.load("assets/data/material_database.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    final dbHelper = DatabaseHelper.instance;

    for (var table in excel.tables.keys) {
      Sheet? sheet = excel.tables[table];

      if (table == "Übungen") {
        String? exerciseName = "";
        int? duration = 0;
        String? url = "";
        String? condition;
        List<ExerciseStep> steps = [];

        for (int rowIndex = 1; rowIndex < (sheet?.maxRows ?? 0); rowIndex++) {
          Data? stepCell = sheet?.cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
          Data? detailsCell = sheet?.cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
          Data? durationCell = sheet?.cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex));
          Data? linkCell = sheet?.cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex));
          Data? conditionCell = sheet?.cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex));

          String stepVal = stepCell?.value.toString() ?? "";
          if (stepVal == "Start") {
            exerciseName = detailsCell?.value.toString();
            duration = int.tryParse(durationCell?.value.toString() ?? "5");
            url = linkCell?.value.toString();
            condition = conditionCell?.value.toString();
          }

          ExerciseStep step = ExerciseStep();
          step.serialNo = stepVal;
          step.name = detailsCell?.value.toString();
          step.duration = int.tryParse(durationCell?.value.toString() ?? "5");
          step.media = linkCell?.value.toString();
          steps.add(step);

          if (stepVal == "End") {
            Exercise exercise = Exercise();
            exercise.condition = condition;
            exercise.name = exerciseName;
            exercise.duration = duration;
            exercise.url = url;

            // exercise.stepsJson = json.encode(steps);
            exercise.steps = [];
            exercise.steps?.addAll(steps);

            // await dbHelper.addExercise(exercise);

            // List<Exercise> exercises = await dbHelper.getExercises();
            // // Deserialize the stepsJson field back into a list of ExerciseStep
            // exercises.forEach((exercise) {
            //   List<dynamic> stepsJson = json.decode(exercise.stepsJson!);
            //   exercise.steps =
            //       stepsJson.map((step) => ExerciseStep.fromMap(step)).toList();
            // });

            exerciseName = "";
            duration = 0;
            url = "";
            condition = "";
            steps.clear();
          }
        }
      }
    }
  }

//** Ähnlich wie _loadExerciseDataFromAsset() lädt diese Funktion Lernmaterialien aus einer Excel-Datei und fügt sie in eine lokale Datenbank ein.
// Sie liest Daten aus der Excel-Datei zeilenweise und erstellt LearningContent-Objekte. */
  Future<void> _loadLearningMaterialFromAsset() async {
    ByteData data = await rootBundle.load("assets/data/material_database.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    AppCache.instance.learningContents.clear();
    final dbHelper = DatabaseHelper.instance;

    for (var table in excel.tables.keys) {
      Sheet? sheet = excel.tables[table];

      if (table == "Lernmaterialien") {
        for (int rowIndex = 1; rowIndex < (sheet?.maxRows ?? 0); rowIndex++) {
          Data? titleCell = sheet?.cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
          Data? linkCell = sheet?.cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));

          LearningContent content = LearningContent();
          content.title = titleCell?.value.toString();
          content.contentUri = linkCell?.value.toString();

          dbHelper.addLearningContent(content);
        }
      }
    }
  }

//**Diese Methode ist für das Navigieren zur nächsten Seite der App verantwortlich.
//Sie überprüft anhand von Shared Preferences, ob ein Benutzer existiert,
//und je nach Ergebnis navigiert sie entweder zur Startseite oder zur Anmeldeseite. */
  _goToNextPage() async {
    bool isUserExist =
        await SharedPref.instance.hasValue(SharedPref.keyUserName);
    var userId = await SharedPref.instance.getValue(SharedPref.keyUserDbId);
    if (userId != null && userId is int) {
      AppCache.instance.userDbId = userId;
    }

    if (isUserExist && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, landingRoute, (r) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, loginRoute, (r) => false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightPink,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 100,
          ),
          Center(
            child: Image(
              image: const AssetImage("assets/images/transparent_logo.png"),
              width: MediaQuery.of(context).size.width / 1.5,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Text(
            'CARDA FIT',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(
            height: 120,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(DataLoader.quotes[_quoteIndex],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: <Shadow>[
                      const Shadow(
                        offset: Offset(5.0, 5.0),
                        blurRadius: 50.0,
                      ),
                    ])),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            '- ${DataLoader.quotesAuthor[_quoteIndex]}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.black54, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
