import 'dart:async';
import 'dart:io';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:app/api/api_manager.dart';
import 'package:app/app.dart';
import 'package:app/model/exercise.dart';
import 'package:app/model/exercise_steps.dart';
import 'package:app/model/task_alert.dart';
import 'package:app/model/user_daily_target.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/widgets/exercise_summary_item.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gradient_slide_to_act/gradient_slide_to_act.dart';

// Diese Klasse übergibt Informationen über den viewMode und den taskType.
// Diese Informationen werden übergeben, damit nachvollziehbar ist welche Art von Task gefordert wird.
class TaskAlertPageData {
  int viewMode; // 1 for view only, 0 for alert
  int? taskType, taskHistoryId;

  TaskAlertPageData({
    required this.viewMode,
    this.taskType,
    this.taskHistoryId,
  });
}

//Diese Klasse erstellt die Benutzeroberfläche für die 4 vorhandenen Tasks (Wasser,Schritte,Pause,Übung)in der App.
class TaskAlertPage extends StatefulWidget {
  const TaskAlertPage({Key? key}) : super(key: key);

  @override
  _TaskAlertPageState createState() => _TaskAlertPageState();
}

//In diesem State werden Daten und Logik für die Aufgabenseite verwaltet.
class _TaskAlertPageState extends State<TaskAlertPage> {
  TaskAlertPageData? _taskPageData;
  int? _taskType;
  Timer? _timer;
  Timer? _breakAndWaterTimer;

  // hide button if exercise is not finished
  double _showHideCloseButton = 0.0;

  Exercise? _exercise;
  bool _isExerciseTask = false;
  int _currentStep = 0;
  double _timerProgress = 0;
  int _totalExerciseSec = 0;
  int _passedExerciseSec = 0;
  bool _isExerciseSummaryRead = false;
  bool _isExerciseStepStarted = false;
  bool _isBreakAndWalkTimerStarted = false;

  String? _stepNo;
  String _title = "";
  String _subTitle = "";
  String _image = '';
  String _staticImage = 'assets/animations/anim_fitness_2.gif';
  List<String> splitConditionList = List.empty(growable: true);

  int _targetTotalTimeInSec = 120;
  int _timePassedInSec = 0;

  FlutterTts flutterTts = FlutterTts();
  String _textToSpeak = "";

  bool _isTimerPaused = false;

  @override
  void initState() {
    super.initState();
  }

/*Die Methode _initTts initialisiert und konfiguriert die Text-to-Speech-Funktionen in Flutter, 
indem sie verfügbare Sprachen abruft und plattformspezifische Einstellungen wie den Standard-TTS-Motor 
und Pausen zwischen Sätzen festlegt.*/
  _initTts() async {
    List<dynamic> languages = await flutterTts.getLanguages;
    print(languages);

    if (Platform.isAndroid) {
      await flutterTts.getDefaultEngine;
      await flutterTts.getDefaultVoice;
      await flutterTts.setSilence(100);
      await flutterTts.setQueueMode(1);
    }

    if (Platform.isIOS) {
      await flutterTts.setSharedInstance(true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _initTts();
    _loadIntent();
  }

//**Diese Methode wird aufgerufen, um die relevanten Daten für die Aufgabenseite zu laden.
//Sie ruft Informationen aus dem TaskAlertPageData-Objekt ab, das den Ansichtsmodus und den Aufgabentyp enthält.
//Abhängig vom Aufgabentyp werden unterschiedliche Daten geladen, z.B., Übungsdaten, Informationen zu Wassertrinken, Schritten oder Pausen.
//Die Methode enthält auch Logik zur Auswahl und Anzeige von Übungsinformationen, einschließlich der Fortschrittsdauer. */
  _loadIntent() async {
    _taskPageData =
        ModalRoute.of(context)?.settings.arguments as TaskAlertPageData;
    _taskType = _taskPageData?.taskType;

    if (_taskType == TaskType.exercise.index ||
        _taskType == TaskType.teamExercise.index) {
      List<Exercise> exerciseList = AppCache.instance.exercises;
      if (exerciseList.isEmpty) {
        await _loadExerciseDataFromAsset();
        exerciseList = AppCache.instance.exercises;
      }

      if (_taskType == TaskType.exercise.index) {
        exerciseList.shuffle();
      } else {
        // do nothing, for team exercise we are always choosing the first one
      }
      Exercise exerciseNow = exerciseList.first;

      // start the steps countdown timer
      _loadWebsiteMetaData(exerciseNow.url ?? "");

      setState(() {
        _isExerciseTask = true;
        _exercise = exerciseNow;
        _title = exerciseNow.name ?? "";
      });

      if ((exerciseNow.steps?.length ?? 0) > 1) {
        _stepNo =
            '${_exercise?.steps?.elementAt(1).serialNo} von ${(_exercise?.steps?.length ?? 0) - 2}';
        _subTitle = exerciseNow.steps?.elementAt(1).name ?? "";
        _currentStep = 1;
        _totalExerciseSec = exerciseNow.steps?.elementAt(1).duration ?? 5;
      } else {
        _totalExerciseSec = exerciseNow.duration ?? 10;
      }

      setState(() {
        _textToSpeak = '$_subTitle für ${exerciseNow.steps?.elementAt(1).duration ?? 5} Sekunden';
      });
      _passedExerciseSec = 0;
    } else if (_taskType == TaskType.water.index) {
      setState(() {
        _title = 'Trinke jetzt ein Glas Wasser!';
        _subTitle = '8 Gläser Wasser pro Tag halten den Arzt fern';
        _staticImage = 'assets/animations/anim_water.gif';
        _showHideCloseButton = 1.0;
      });
    } else if (_taskType == TaskType.steps.index) {
      setState(() {
        _title = 'Bleibe nun zwei Minuten in Bewegung!';
        _subTitle = 'Je mehr Schritte du machst, desto gesünder wirst du';
        _staticImage = 'assets/animations/anim_walking_steps.gif';

        _startBreakAndWalkTimer();
      });
    } else if (_taskType == TaskType.breaks.index) {
      setState(() {
        _title = 'Lege nun eine zweiminütige Pause ein!';
        _subTitle = 'Arbeiten Sie wie ein Mensch, nicht wie ein Roboter!';
        _staticImage = 'assets/animations/anim_break_time.gif';

        _startBreakAndWalkTimer();
      });
    } else if (_taskType == TaskType.waterWithBreak.index) {
      setState(() {
        _title =
            'Machen Sie eine kurze Pause und trinken Sie auch ein Glas Wasser!';
        _subTitle = 'Arbeiten Sie wie ein Mensch, nicht wie ein Roboter!';
        _staticImage = 'assets/animations/anim_break_time.gif';

        _startBreakAndWalkTimer();
      });
    } else if (_taskType == TaskType.walkWithExercise.index) {
      setState(() {
        _title =
            'Gehen Sie eine Weile spazieren und strecken Sie Ihre Hände ein wenig!';
        _subTitle = 'Je mehr Schritte du machst, desto gesünder wirst du';
        _staticImage = 'assets/animations/anim_break_time.gif';

        _startBreakAndWalkTimer();
      });
    }
  }

/*Die Funktion _speakStep wird verwendet, um einen gegebenen Text (_textToSpeak) in deutscher Sprache vorzulesen,
 wobei spezifische Einstellungen für Lautstärke, Sprechgeschwindigkeit und Tonhöhe berücksichtigt werden,
 während _stopSpeaking die laufende Sprachausgabe stoppt. */
  Future _speakStep() async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("de-DE");
    await flutterTts.setVolume(0.7);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(1.0);

    await flutterTts.speak(_textToSpeak);
  }

  Future _stopSpeaking() async {
    await flutterTts.stop();
  }

  void _exerciseTogglePauseResume() {
    if (_isExerciseStepStarted) {
      if (_isTimerPaused) {
        _exerciseResumeTimer();
      } else {
        _exercisePauseTimer();
      }
    }
  }

  void _exercisePauseTimer() async {
    _stopSpeaking();

    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      setState(() {
        _isTimerPaused = true;
      });
    }
  }

  void _exerciseResumeTimer() async {
    _speakStep();

    if (_isTimerPaused) {
      // Setzen Sie den Timer zurück, indem Sie _startExerciseTimer aufrufen.
      _startExerciseTimer();
      setState(() {
        _isTimerPaused = false;
      });
    }
  }

  void _breakAndWaterTogglePauseResume() {
    if (_isBreakAndWalkTimerStarted) {
      if (_isTimerPaused) {
        _breakandWaterResumeTimer();
      } else {
        _breakAndWaterPauseTimer();
      }
    }
  }

  void _breakAndWaterPauseTimer() {
    if (_breakAndWaterTimer != null && _breakAndWaterTimer!.isActive) {
      _breakAndWaterTimer!.cancel();
      setState(() {
        _isTimerPaused = true;
      });
    }
  }

  void _breakandWaterResumeTimer() {
    if (_isTimerPaused) {
      // Setzen Sie den Timer fort, indem Sie _startBreakAndWalkTimer nicht aufrufen,
      // sondern direkt _breakAndWaterResume aufrufen.
      _breakAndWaterResume();
      //_startBreakAndWalkTimer();
      setState(() {
        _isTimerPaused = false;
      });
    }
  }

  void _breakAndWaterResume() {
    // Hier setzt der Timer an der gestoppten Zeit fort
    _breakAndWaterTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _timePassedInSec <= _targetTotalTimeInSec) {
        setState(() {
          _timePassedInSec++;
          if (_timerProgress >= 1) {
            if (_timer != null) {
              _timer!.cancel();
              _timer = null;
            }
          } else {
            _timerProgress += 1 / _targetTotalTimeInSec;
          }
        });
      } else if (mounted) {
        setState(() {
          _showHideCloseButton = 1.0;
        });
        timer.cancel();
      }
    });
  }

//**Diese Methode wird verwendet, um Übungsdaten aus einer Excel-Tabelle zu extrahieren.
//Sie liest die Excel-Datei aus den Assets und erstellt eine Liste von Übungen, einschließlich ihrer Schritte und anderer relevanter Daten.
//Die Übungen werden basierend auf den in der Datei angegebenen Bedingungen gefiltert und im App-Cache gespeichert. */
  _loadExerciseDataFromAsset() async {
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

    List<Exercise> exercises = [];
    for (var table in excel.tables.keys) {
      Sheet? sheet = excel.tables[table];
      print(table); //sheet Name

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
          splitConditionList = userCondition.split(",");
          // Trennt den multi String in eine Liste aus einzelnen Strings.

          if (stepVal == "End") {
            Exercise exercise = Exercise();
            exercise.condition = condition;
            exercise.name = exerciseName;
            exercise.duration = duration;
            exercise.url = url;
            exercise.steps = [];
            exercise.steps?.addAll(steps);

            bool addContent = false;
            if (exercise.condition != null &&
                userCondition.isNotEmpty &&
                _checkUserConditionInDb(userCondition, exercise.condition!)) {
              // Überprüfe ob exercise.conditions mit den Inhalten der userConditionList übereinstimmt.
              addContent = true;
            } else if (userCondition.isEmpty) {
              addContent = true;
            } else {
              //  Überspringe diesen Lerninhalt, da er für die angegebene Nutzerbedingung nicht nützlich ist.
            }

            if (addContent) exercises.add(exercise);
            steps.clear();
          }
        }

        print(">>>>>>>>>excercise list: ${exercises.length}");
        AppCache.instance.exercises.clear();
        AppCache.instance.exercises.addAll(exercises);
        print(exercises.length);
      }
    }
  }

//*Die Funktion vergleicht die UserCondition des Benutzers mit den in der Datenbank gespeicherten Bedingungen und gibt true zurück,
// wenn eine der Bedingungen des Benutzers in den in der Datenbank gespeicherten Bedingungen enthalten ist. Andernfalls gibt sie false zurück. */
  bool _checkUserConditionInDb(String userCondition, String dbCondition) {
    List<String> userConditionItems = userCondition.split(",");
    for (String singleUserCondition in userConditionItems) {
      if (dbCondition.contains(singleUserCondition)) {
        return true;
      }
    }
    return false;
  }

/**Diese Methode lädt Metadaten von einer Webseite anhand einer URL mithilfe des any_link_preview-Pakets.
//Die Metadaten werden für die Anzeige von Vorschauinformationen verwendet. */
  _loadWebsiteMetaData(String url) async {
    Metadata? _metadata = await AnyLinkPreview.getMetadata(
        link: url,
        cache: const Duration(days: 7),
        proxyUrl:
            "https://i.picsum.photos/id/239/1739/1391.jpg?hmac=-Zh20gMdOuV7tHr4wGEUqACAxdvb7gkDlKKS9MIE1TU");
    print(_metadata?.title);
    print(_metadata?.image);
    if (mounted) {
      setState(() {
        _image = _metadata?.image ?? '';
      });
    }
  }

/**Diese Methode startet einen Timer für die Anzeige der Fortschrittsdauer einer Übung.
 * Der Timer wird jede Sekunde aktualisiert.
 */
  void _startExerciseTimer() {
    setState(() {
      _isExerciseStepStarted = true;
    });
    _speakStep();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {
          _passedExerciseSec += 1;
          if (_timerProgress >= 1) {
            _cancelExerciseTimer();
          } else {
            _timerProgress += 1 / _totalExerciseSec;
          }
        });
      }
    });
  }

/**Diese Methode startet einen Timer für Aufgabentypen wie Pausen und Schritte.
 * Der Timer wird jede Sekunde aktualisiert.
 */
  void _startBreakAndWalkTimer() {
    setState(() {
      _isBreakAndWalkTimerStarted = true;
    });

    _targetTotalTimeInSec = 120;
    _timePassedInSec = 0;

    _breakAndWaterTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _timePassedInSec <= _targetTotalTimeInSec) {
        setState(() {
          _timePassedInSec++;
          if (_timerProgress >= 1) {
            if (_timer != null) {
              _timer!.cancel();
              _timer = null;
            }
          } else {
            _timerProgress += 1 / _targetTotalTimeInSec;
          }
        });
      } else if (mounted) {
        setState(() {
          _showHideCloseButton = 1.0;
        });
        timer.cancel();
      }
    });
  }

/**Diese Methode wird aufgerufen, um den Übungstimer zu beenden, wenn die aktuelle Übung abgeschlossen ist.
 */
  void _cancelExerciseTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }

    _stopSpeaking();

    if (mounted) {
      setState(() {
        _currentStep += 1;

        if ((_exercise?.steps?.isNotEmpty ?? false) &&
            (_exercise?.steps?.length ?? 0) - 1 > _currentStep) {
          _stepNo =
              '${_exercise?.steps?.elementAt(_currentStep).serialNo} von ${(_exercise?.steps?.length ?? 0) - 2}';
          _subTitle = _exercise?.steps?.elementAt(_currentStep).name ?? "";

          _textToSpeak = '$_subTitle für ${_exercise?.steps?.elementAt(_currentStep).duration ?? 5} Sekunden';

          _timerProgress = 0;
          _totalExerciseSec = _exercise?.steps?.elementAt(_currentStep).duration ?? 5;
          _passedExerciseSec = 0;
          _isExerciseStepStarted = false;
        } else if ((_exercise?.steps?.length ?? 0) - 1 == _currentStep) {
          _showHideCloseButton = 1.0;
          // else if show the button
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

/**Diese Methode wird aufgerufen, wenn der Benutzer eine Aufgabe abschließt und den Bestätigungsbutton drückt.
  *Sie aktualisiert den Fortschritt/Punkte des Benutzers und speichert die abgeschlossenen Aufgaben in den App-Daten.
  *Je nach Aufgabentyp (z. B. Wasser trinken, Schritte, Übungen) werden die entsprechenden Fortschritte/Punkte erhöht.
  */
  void onSubmitScore() async {
    int? taskHistoryId = _taskPageData?.taskHistoryId;
    if (taskHistoryId != null) {
      await DatabaseHelper.instance.updateAlertHistory(taskHistoryId);
    }

    var complTargetJson = await SharedPref.instance
        .getJsonValue(SharedPref.keyUserCompletedTargets);
    DailyTarget completedTarget;
    if (complTargetJson != null &&
        complTargetJson is String &&
        complTargetJson.isNotEmpty) {
      completedTarget = DailyTarget.fromRawJson(complTargetJson);
    } else {
      completedTarget =
          DailyTarget(breaks: 0, waterGlasses: 0, exercises: 0, steps: 0);
    }

    switch (_taskType) {
      case 0:
        completedTarget.increaseWaterConsumption(1);
        break;
      case 1:
        completedTarget.increaseStepsCount(200);
        break;
      case 2:
        completedTarget.increaseExerciseCount(1);
        break;
      case 3:
        completedTarget.increaseBreaksCount(1);
        break;
      case 4:
        completedTarget.increaseExerciseCount(1);
        break;
      case 5:
        completedTarget.increaseWaterConsumption(1);
        completedTarget.increaseBreaksCount(1);
        break;
      case 6:
        completedTarget.increaseStepsCount(200);
        completedTarget.increaseExerciseCount(1);
        break;
      default:
        break;
    }
    SharedPref.instance.saveJsonValue(
        SharedPref.keyUserCompletedTargets, completedTarget.toRawJson());

    // only add score if it's for actual task alert, not for view only mode
    if (_taskPageData?.viewMode == 0) {
      int score = DataLoader.getScoreForTask(_taskType ?? -1);
      String? userId =
          await SharedPref.instance.getValue(SharedPref.keyUserServerId);
      if (userId != null && userId.isNotEmpty) {
        await ApiManager().updateUserScore(userId, score);
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
      Navigator.pushNamedAndRemoveUntil(context, landingRoute, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.pink.shade50,
          centerTitle: false,
          title: _isExerciseTask && !_isExerciseSummaryRead
              ? const Text('')
              : const Text(''),
        ),
        backgroundColor: Colors.pink.shade50,
        body: /*_isExerciseTask && !_isExerciseSummaryRead ?
          buildExerciseSummaryView(context, (_exercise?.steps?.length ?? 0) > 0 ? _exercise?.steps?.sublist(1, (_exercise?.steps?.length ?? 0)-1) ?? [] : []) :*/
            buildMainView(context));
  }

  Widget buildMainView(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter, // Oben in der Mitte des Bildschirms
      child: ListView(
        children: <Widget>[
          Visibility(
            visible: _isExerciseTask,
            child: Text(
              _stepNo ?? "",
              style: Theme.of(context)
                  .textTheme
                  .caption
                  ?.copyWith(fontSize: 24, color: Colors.brown),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          Visibility(
            visible: _isExerciseTask,
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  Positioned(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      strokeWidth: 20,
                      backgroundColor: Colors.white,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.orange),
                      value: _timerProgress,
                    ),
                  ),
                  Center(
                    child: Text(
                      CommonUtil.formatTimeDurationToDisplay(
                          _totalExerciseSec - _passedExerciseSec),
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          ?.copyWith(fontSize: 30, color: AppColor.darkBlue),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _title,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  ?.copyWith(fontSize: 30, color: AppColor.darkBlue),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Visibility(
            visible: (_taskType == TaskType.breaks.index ||
                _taskType == TaskType.steps.index ||
                _taskType == TaskType.waterWithBreak.index ||
                _taskType == TaskType.walkWithExercise.index),
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  Positioned(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      strokeWidth: 20,
                      backgroundColor: Colors.white,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.orange),
                      value: _timerProgress,
                    ),
                  ),
                  Center(
                    child: Text(
                      CommonUtil.formatTimeDurationToDisplay(
                          _targetTotalTimeInSec - _timePassedInSec),
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          ?.copyWith(fontSize: 30, color: AppColor.darkBlue),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _subTitle,
              style:
                  Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 150,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              child: _image.isNotEmpty
                  ? Image.network(_image)
                  : Image.asset(_staticImage),
            ),
          ),
          const SizedBox(height: 20),
          Visibility(
            visible: _isExerciseTask && !_isExerciseStepStarted,
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
              child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => Colors.transparent,
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    _startExerciseTimer();
                  },
                  child: Ink(
                    decoration: const BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 50, maxWidth: 250), // min sizes for Material buttons
                      alignment: Alignment.center,
                      child: Text(
                        "Übung starten".toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  )),
            ),
          ),
          Visibility(
            visible: _isExerciseTask && _isExerciseStepStarted && _showHideCloseButton != 1.0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
              child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => Colors.transparent,
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    _exerciseTogglePauseResume();
                  },
                  child: Ink(
                    decoration: const BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 50, maxWidth: 250), // min sizes for Material buttons
                      alignment: Alignment.center,
                      child: Text(
                        _isTimerPaused
                            ? "Fortsetzen".toUpperCase()
                            : "Pause".toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  )),
            ),
          ),
          Visibility(
            visible: _isBreakAndWalkTimerStarted && _showHideCloseButton != 1.0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
              child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => Colors.transparent,
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    _breakAndWaterTogglePauseResume();
                  },
                  child: Ink(
                    decoration: const BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 50, maxWidth: 250), // min sizes for Material buttons
                      alignment: Alignment.center,
                      child: Text(
                        _isTimerPaused
                            ? "Fortsetzen".toUpperCase()
                            : "Pause".toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  )),
            ),
          ),
          Visibility(
            visible: _showHideCloseButton == 1.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
              child: GradientSlideToAct(
                text: "Schieben zum\nBestätigen",
                dragableIconBackgroundColor: Colors.greenAccent,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyText2
                    ?.copyWith(fontSize: 18),
                backgroundColor: Colors.white,
                onSubmit: () {
                  onSubmitScore();
                },
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColor.primary, AppColor.primaryLight],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pause/Resume kann so eingefügt werden

// ElevatedButton(
//   onPressed: () {
//     _togglePauseResume();
//   },
//   child: Text(_isTimerPaused ? 'Resume' : 'Pause'),
// ),
