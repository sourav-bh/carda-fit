import 'dart:async';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:app/api/api_manager.dart';
import 'package:app/main.dart';
import 'package:app/model/exercise.dart';
import 'package:app/model/exercise_steps.dart';
import 'package:app/model/task.dart';
import 'package:app/model/user_daily_target.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/util/shared_preference.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:intl/intl.dart';

enum TaskType {
  water,
  steps,
  exercise,
  breaks,
  teamExercise,
}

class TaskAlertPage extends StatefulWidget {
  const TaskAlertPage({Key? key}) : super(key: key);

  @override
  _TaskAlertPageState createState() => _TaskAlertPageState();
}

class _TaskAlertPageState extends State<TaskAlertPage> {
  final GlobalKey<SlideActionState> _key = GlobalKey();
  int? _taskType;
  Exercise? _exercise;
  bool _isExerciseTask = false;
  int _currentStep = 0;
  Timer? _timer;
  double _progress = 0;
  int _totalSeconds = 0;
  int _secondsPassed = 0;
  double _showButton = 0.0;
  int _timeLeft = 120;
  bool _showTimer = false;
  Duration duration = Duration();
  double? _progressCountDown;

  // hide button if exercise is not finished

  String? _stepNo;
  String _title = "";
  String _subTitle = "";
  String _image = '';
  String _staticImage = 'assets/animations/anim_fitness_2.gif';
  List<String> splitConditionList = List.empty(growable: true);

  /// not sure about this

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

  _loadIntent() async {
    _taskType = ModalRoute.of(context)?.settings.arguments as int;

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
      print(exerciseNow.toRawJson());

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
        _totalSeconds = exerciseNow.steps?.elementAt(1).duration ?? 5;
      } else {
        _totalSeconds = exerciseNow.duration ?? 10;
      }

      _secondsPassed = _totalSeconds;
      _startTimer();
    } else if (_taskType == TaskType.water.index) {
      setState(() {
        _showTimer = false;
        _title = 'Trinke jetzt ein Glas Wasser!';
        _subTitle = '8 Gläser Wasser pro Tag, halten den Arzt fern';
        _staticImage = 'assets/animations/anim_water.gif';
        _showButton = 1.0;
      });
    } else if (_taskType == TaskType.steps.index) {
      setState(() {
        _showTimer = true;
        _title = 'Bleib nun zwei Minuten in Bewegung!';
        _subTitle = 'Je mehr Schritte du machst, desto gesünder wirst du';
        _staticImage = 'assets/animations/anim_walking_steps.gif';
        _startCountDown();
      });
    } else if (_taskType == TaskType.breaks.index) {
      setState(() {
        _showTimer = true;
        _title = 'Lege nun eine zwei minütige Pause ein!';
        _subTitle = 'Arbeiten Sie wie ein Mensch, nicht wie ein Roboter!';
        _staticImage = 'assets/animations/anim_break_time.gif';
        _startCountDown();
      });
    }
  }

  //newTimer

  void _startCountDown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && _timeLeft > 0) {
        setState(() {
          _timeLeft--;
          if (_progress >= 1) {
            _cancelTimer();
          } else {
            _progress += 1 / _timeLeft;
          }
        });
      } else if (mounted) {
        setState(() {
          _showButton = 1.0;
        });
        timer.cancel();
      }
    });
  }

  _loadExerciseDataFromAsset() async {
    UserInfo? userInfo =
        await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    var userCondition = "";
    if (userInfo != null &&
        userInfo.condition != null &&
        userInfo.condition!.isNotEmpty) {
      userCondition = userInfo.condition ?? "";
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
            if (exercise.condition != null &&
                userCondition.isNotEmpty &&
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

  bool _checkUserConditionInDb(String userCondition, String dbCondition) {
    List<String> userConditionItems = userCondition.split(",");
    //if (dbCondition.contains(userConditionItems)) {}
    // no good solution found
    // for(var item in nums){
    //if(item['a'] == a && item['b'] == b){
    //print(item['c']); // => 29
    return false;
  }

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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {
          _secondsPassed -= 1;
          if (_progress >= 1) {
            _cancelTimer();
          } else {
            _progress += 1 / _totalSeconds;
          }
        });
      }
    });
  }

  void _cancelTimer() {
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

          _progress = 0;
          _totalSeconds =
              _exercise?.steps?.elementAt(_currentStep).duration ?? 5;
          _secondsPassed = _totalSeconds;
          _startTimer();
        } else if ((_exercise?.steps?.length ?? 0) - 1 == _currentStep) {
          _showButton = 1.0;
          // else if show the button
        }
        ;
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

  void onSubmitScore() async {
    var complTargetJson =
        await SharedPref.instance.getJsonValue(SharedPref.keyUserComplTargets);
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
        completedTarget.increaseStepsCount(100);
        break;
      case 2:
        completedTarget.increaseExerciseCount(1);
        break;
      case 3:
        completedTarget.increaseBreaksCount(1);
        break;
      default:
        break;
    }
    SharedPref.instance.saveJsonValue(
        SharedPref.keyUserComplTargets, completedTarget.toRawJson());

    int score = DataLoader.getScoreForTask(_taskType ?? -1);
    String? userId =
        await SharedPref.instance.getValue(SharedPref.keyUserServerId);
    if (userId != null && userId.isNotEmpty) {
      await ApiManager().updateUserScore(userId, score);
      Navigator.of(navigatorKey.currentState!.context).pop();
      Navigator.pushNamedAndRemoveUntil(
          navigatorKey.currentState!.context, landingRoute, (r) => false);
    } else {
      Navigator.of(navigatorKey.currentState!.context).pop();
      Navigator.pushNamedAndRemoveUntil(
          navigatorKey.currentState!.context, landingRoute, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.pink.shade50,
          centerTitle: false,
          title: const Text(''),
        ),
        backgroundColor: Colors.pink.shade50,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Visibility(
                visible: _isExerciseTask,
                child: Text(
                  _stepNo ?? "",
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.copyWith(fontSize: 36, color: Colors.brown),
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
                        value: _progress,
                      ),
                    ),
                    Center(
                        child: Text(
                      CommonUtil.formatDuration(_secondsPassed),
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
              visible: _showTimer,
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
                        value: _progress,
                      ),
                    ),
                    Center(
                        child: Text(
                      CommonUtil.formatDuration(_timeLeft),
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _subTitle,
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    ?.copyWith(fontSize: 20),
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
                      : Image.asset(
                          _staticImage,
                        )),
            ),
            Opacity(
              opacity: _showButton,
              // showButton if exercise done
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SlideAction(
                    key: _key,
                    text: 'Schieben zum\nBestätigen',
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.copyWith(fontSize: 18),
                    sliderButtonIconSize: 20,
                    onSubmit: () {
                      onSubmitScore();
                      // Future.delayed(const Duration(seconds: 1), () {
                      //   Navigator.of(context).pop();
                      //   Navigator.pushNamedAndRemoveUntil(navigatorKey.currentState!.context, landingRoute, (r) => false);
                      // },);
                    },
                    innerColor: AppColor.primaryLight,
                    outerColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
