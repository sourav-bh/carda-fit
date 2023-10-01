import 'dart:async';

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
import 'package:gradient_slide_to_act/gradient_slide_to_act.dart';

class TaskAlertPageData {
  int viewMode; // 1 for view only, 0 for alert
  int? taskType, taskHistoryId;

  TaskAlertPageData({required this.viewMode, this.taskType, this.taskHistoryId,});
}

class TaskAlertPage extends StatefulWidget {
  const TaskAlertPage({Key? key}) : super(key: key);

  @override
  _TaskAlertPageState createState() => _TaskAlertPageState();
}

class _TaskAlertPageState extends State<TaskAlertPage> {
  TaskAlertPageData? _taskPageData;
  int? _taskType;
  Timer? _timer;

  // hide button if exercise is not finished
  double _showHideCloseButton = 0.0;

  Exercise? _exercise;
  bool _isExerciseTask = false;
  int _currentStep = 0;
  double _timerProgress = 0;
  int _totalExerciseSec = 0;
  int _passedExerciseSec = 0;
  bool _isExerciseSummaryRead = false;

  String? _stepNo;
  String _title = "";
  String _subTitle = "";
  String _image = '';
  String _staticImage = 'assets/animations/anim_fitness_2.gif';
  List<String> splitConditionList = List.empty(growable: true);

  int _targetTotalTimeInSec = 120;
  int _timePassedInSec = 0;

  @override
  void initState() {
    // match function wether its a new day (build outside and call its inside)
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadIntent();
  }

//* Hier werden die relevanten Daten für die Task Page geladen. Zuerst werden Informationen aus dem TaskAlertPageData-Objekt abgerufen, das die Ansichtsmodusinformationen und den Typ der Aufgabe enthält. 
//  Wenn der Aufgabentyp ein Übungstyp ist (z. B. Fitnessübung oder Teamübung), werden die Übungsinformationen geladen. Andernfalls werden Informationen zu anderen Aufgabentypen (z. B. Trinken von Wasser, Schritte, Pausen) geladen.
//  Für Übungen wird eine zufällige Übung aus einer vordefinierten Liste von Übungen ausgewählt und die Details dieser Übung (Titel, Schritte, Dauer usw.) angezeigt.
//  Für andere Aufgabentypen werden entsprechende Informationen angezeigt, z. B. Trinken von Wasser oder Zeit für Pausen und Schritte. */
  _loadIntent() async {
    _taskPageData = ModalRoute.of(context)?.settings.arguments as TaskAlertPageData;
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
        _stepNo = exerciseNow.steps?.elementAt(1).serialNo;
        _subTitle = exerciseNow.steps?.elementAt(1).name ?? "";
        _currentStep = 1;
        _totalExerciseSec = exerciseNow.steps?.elementAt(1).duration ?? 5;
      } else {
        _totalExerciseSec = exerciseNow.duration ?? 10;
      }

      _passedExerciseSec = 0;

    } else if (_taskType == TaskType.water.index) {
      setState(() {
        _title = 'Trinke jetzt ein Glas Wasser!';
        _subTitle = '8 Gläser Wasser pro Tag, halten den Arzt fern';
        _staticImage = 'assets/animations/anim_water.gif';
        _showHideCloseButton = 1.0;
      });
    } else if (_taskType == TaskType.steps.index) {
      setState(() {
        _title = 'Bleib nun zwei Minuten in Bewegung!';
        _subTitle = 'Je mehr Schritte du machst, desto gesünder wirst du';
        _staticImage = 'assets/animations/anim_walking_steps.gif';

        _startBreakAndWalkTimer();
      });
    } else if (_taskType == TaskType.breaks.index) {
      setState(() {
        _title = 'Lege nun eine zwei minütige Pause ein!';
        _subTitle = 'Arbeiten Sie wie ein Mensch, nicht wie ein Roboter!';
        _staticImage = 'assets/animations/anim_break_time.gif';

        _startBreakAndWalkTimer();
      });
    } else if (_taskType == TaskType.waterWithBreak.index) {
      setState(() {
        _title = 'Machen Sie eine kurze Pause und trinken Sie auch ein Glas Wasser!';
        _subTitle = 'Arbeiten Sie wie ein Mensch, nicht wie ein Roboter!';
        _staticImage = 'assets/animations/anim_break_time.gif';

        _startBreakAndWalkTimer();
      });
    } else if (_taskType == TaskType.walkWithExercise.index) {
      setState(() {
        _title = 'Gehen Sie eine Weile spazieren und strecken Sie Ihre Hände ein wenig!';
        _subTitle = 'Je mehr Schritte du machst, desto gesünder wirst du';
        _staticImage = 'assets/animations/anim_break_time.gif';

        _startBreakAndWalkTimer();
      });
    }
  }

//*Hier werden wieder Daten aus einer Excel-Tabelle extrahiert. Die Funktion liest die Übungsdaten aus der Datei aus und erstellt eine Liste von Übungsinformationen, einschließlich Schritten und anderen relevanten Daten.
// Die Übungen werden basierend auf den in der Datei angegebenen Bedingungen gefiltert, um nur relevante Übungen zu behalten. Zudem werden sie in der App-Cache gespeichert.
// */
  _loadExerciseDataFromAsset() async {
    UserInfo? userInfo = await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    var userCondition = "";
    if (userInfo != null && !CommonUtil.isNullOrEmpty(userInfo.medicalConditions)) {
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
          Data? stepCell = sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
          Data? detailsCell = sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
          Data? durationCell = sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex));
          Data? linkCell = sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex));
          Data? conditionCell = sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex));

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
          // split the multi String in to a List of single Strings

          if (stepVal == "End") {
            Exercise exercise = Exercise();
            exercise.condition = condition;
            exercise.name = exerciseName;
            exercise.duration = duration;
            exercise.url = url;
            exercise.steps = [];
            exercise.steps?.addAll(steps);

            bool addContent = false;
            if (exercise.condition != null && userCondition.isNotEmpty &&
                _checkUserConditionInDb(userCondition, exercise.condition!)) {
              //check if exercise.conditions match with items of the userConditionList
              addContent = true;
            } else if (userCondition.isEmpty) {
              addContent = true;
            } else {
              // skip this learning content, since it is not useful for the user condition specified
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
/* */
  _loadWebsiteMetaData(String url) async {
    Metadata? _metadata = await AnyLinkPreview.getMetadata(
        link: url, cache: const Duration(days: 7),
        proxyUrl: "https://i.picsum.photos/id/239/1739/1391.jpg?hmac=-Zh20gMdOuV7tHr4wGEUqACAxdvb7gkDlKKS9MIE1TU");
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
    _targetTotalTimeInSec = 120;
    _timePassedInSec = 0;

    Timer.periodic(const Duration(seconds: 1), (timer) {
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

    if (mounted) {
      setState(() {
        _currentStep += 1;

        if ((_exercise?.steps?.isNotEmpty ?? false) &&
            (_exercise?.steps?.length ?? 0) - 1 > _currentStep) {
          _stepNo = _exercise?.steps?.elementAt(_currentStep).serialNo;
          _subTitle = _exercise?.steps?.elementAt(_currentStep).name ?? "";

          _timerProgress = 0;
          _totalExerciseSec = _exercise?.steps?.elementAt(_currentStep).duration ?? 5;
          _passedExerciseSec = _totalExerciseSec;
          _startExerciseTimer();
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

    var complTargetJson = await SharedPref.instance.getJsonValue(SharedPref.keyUserCompletedTargets);
    DailyTarget completedTarget;
    if (complTargetJson != null &&
        complTargetJson is String && complTargetJson.isNotEmpty) {
      completedTarget = DailyTarget.fromRawJson(complTargetJson);
    } else {
      completedTarget = DailyTarget(breaks: 0, waterGlasses: 0, exercises: 0, steps: 0);
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
    SharedPref.instance.saveJsonValue(SharedPref.keyUserCompletedTargets, completedTarget.toRawJson());

    // only add score if it's for actual task alert, not for view only mode
    if (_taskPageData?.viewMode == 0) {
      int score = DataLoader.getScoreForTask(_taskType ?? -1);
      String? userId = await SharedPref.instance.getValue(SharedPref.keyUserServerId);
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
          title: _isExerciseTask && !_isExerciseSummaryRead ? const Text('Zusammenfassung') : const Text(''),
        ),
        backgroundColor: Colors.pink.shade50,
        body: _isExerciseTask && !_isExerciseSummaryRead ?
          buildExerciseSummaryView(context, (_exercise?.steps?.length ?? 0) > 0 ? _exercise?.steps?.sublist(1, (_exercise?.steps?.length ?? 0)-1) ?? [] : []) :
          buildMainView(context)
    );
  }

  Widget buildMainView(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Visibility(
              visible: _isExerciseTask,
              child: Text(_stepNo ?? "",
                style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 36, color: Colors.brown),
                textAlign: TextAlign.center,
              )),
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
                    CommonUtil.formatTimeDurationToDisplay(_passedExerciseSec),
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        ?.copyWith(fontSize: 30, color: AppColor.darkBlue),
                    textAlign: TextAlign.center,
                  ))
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(_title,
              style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 30, color: AppColor.darkBlue),
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
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                      value: _timerProgress,
                    ),
                  ),
                  Center(child: Text(
                    CommonUtil.formatTimeDurationToDisplay(_targetTotalTimeInSec - _timePassedInSec),
                    style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 30, color: AppColor.darkBlue),
                    textAlign: TextAlign.center,
                  ))
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _subTitle,
              style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            color: Colors.transparent,
            height: 150,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                child: _image.isNotEmpty
                    ? Image.network(_image)
                    : Image.asset(_staticImage,)),
          ),
          Opacity(
            opacity: _showHideCloseButton,
            // showButton if exercise done
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GradientSlideToAct(
                  // width: 400,
                  text: "Schieben zum\nBestätigen",
                  dragableIconBackgroundColor: Colors.greenAccent,
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(fontSize: 18),
                  backgroundColor: Colors.white,
                  onSubmit: () {
                    onSubmitScore();
                    // Future.delayed(const Duration(seconds: 1), () {
                    //   Navigator.of(context).pop();
                    //   Navigator.pushNamedAndRemoveUntil(navigatorKey.currentState!.context, landingRoute, (r) => false);
                    // },);
                  },
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColor.primary,
                        AppColor.primaryLight,
                      ]),
                ),
              ),
            ),
          ),
        ],
      );
  }

  Widget buildExerciseSummaryView(BuildContext context, List<ExerciseStep> steps) {
    return ListView(
      // crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Text(
            'Übung: ${steps.isNotEmpty ? steps[0].name ?? "" : ""}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColor.orange),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                ExerciseStep step = steps[index];
                return ExerciseSummaryItemView(itemData: step,);
              },
              separatorBuilder: (context, index) {
                return const Divider(endIndent: 0, color: Colors.transparent);
              },
              itemCount: steps.length,
              scrollDirection: Axis.vertical,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
          child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => Colors.transparent,),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                setState(() {
                  _isExerciseSummaryRead = true;
                });
                _startExerciseTimer();
              },
              child: Ink(
                decoration: const BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius:
                  BorderRadius.all(Radius.circular(10)),
                ),
                child: Container(
                  constraints: const BoxConstraints(
                      minHeight:
                      50), // min sizes for Material buttons
                  alignment: Alignment.center,
                  child: Text(
                    "Weiter".toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              )),
        ),
      ],
    );
  }
}
