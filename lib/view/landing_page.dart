import 'dart:typed_data';

import 'package:app/main.dart';
import 'package:app/model/exercise.dart';
import 'package:app/model/exercise_steps.dart';
import 'package:app/model/learning.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/service/task_alert_service.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/view/home_page.dart';
import 'package:app/view/leaderboard_page.dart';
import 'package:app/view/task_alert_page.dart';
import 'package:app/view/user_activity_page.dart';
import 'package:app/view/user_learning_page.dart';
import 'package:app/view/user_profile_page.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<Widget> _contentPages = <Widget>[
    const HomePage(),
    const UserActivityPage(),
    const UserLearningPage(),
    const LeaderBoardPage(),
    const UserProfilePage(),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_handleTabSelection);

    super.initState();

    _loadExerciseDataFromAsset();
    _loadLearningMaterialFromAsset();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _checkIfAppLaunchedFromNotification();
  }

  _checkIfAppLaunchedFromNotification() async {
    final NotificationAppLaunchDetails? notDetails =
        await TaskAlertService.instance.getNotificationAppLaunchDetails();

    if (notDetails != null && notDetails.didNotificationLaunchApp) {
      print("notificationAppLaunchDetails: $notDetails");
      String payload = notDetails.notificationResponse?.payload ?? "2";
      int taskType = int.tryParse(payload) ?? TaskType.exercise.index;
      Navigator.pushNamed(navigatorKey.currentState!.context, taskAlertRoute,
          arguments: taskType);
    }
  }

  void _handleTabSelection() {
    setState(() {});
  }

  _loadExerciseDataFromAsset() async {
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

          if (stepVal == "End") {
            Exercise exercise = Exercise();
            exercise.condition = condition;
            exercise.name = exerciseName;
            exercise.duration = duration;
            exercise.url = url;
            exercise.steps = [];
            exercise.steps?.addAll(steps);
            exercises.add(exercise);

            steps.clear();
          }
        }

        AppCache.instance.exercises.clear();
        AppCache.instance.exercises.addAll(exercises);
        print(exercises.length);
      }
    }
  }

  _loadLearningMaterialFromAsset() async {
    ByteData data = await rootBundle.load("assets/data/material_database.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    AppCache.instance.contents.clear();
    List<LearningContent> learningContents = [];
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
          learningContents.add(content);

          AppCache.instance.contents.add(content);
          DatabaseHelper.instance.addLearningContent(content);
        }

        print(learningContents.length);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.lightPink,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _contentPages.map((Widget content) {
            return content;
          }).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (value) {
            _currentIndex = value;
            _pageController.jumpToPage(value);

            FocusScope.of(context).unfocus();
          },
          selectedFontSize: 8,
          unselectedFontSize: 8,
          iconSize: 28,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
                label: 'Home',
                icon: Icon(Icons.home,
                    color: _currentIndex == 0 ? Colors.orange : Colors.grey)),
            BottomNavigationBarItem(
                label: 'Target',
                icon: Icon(Icons.crisis_alert_sharp,
                    color: _currentIndex == 1 ? Colors.orange : Colors.grey)),
            BottomNavigationBarItem(
                label: 'Learn',
                icon: Icon(Icons.menu_book,
                    color: _currentIndex == 2 ? Colors.orange : Colors.grey)),
            BottomNavigationBarItem(
                label: 'Board',
                icon: Icon(Icons.leaderboard,
                    color: _currentIndex == 3 ? Colors.orange : Colors.grey)),
            BottomNavigationBarItem(
                label: 'Profile',
                icon: Icon(Icons.person,
                    color: _currentIndex == 4 ? Colors.orange : Colors.grey)),
          ],
        ));
  }
}
