import 'dart:io';

import 'package:app/api/api_manager.dart';
import 'package:app/app.dart';
import 'package:app/model/exercise.dart';
import 'package:app/model/exercise_steps.dart';
import 'package:app/model/learning.dart';
import 'package:app/model/task_alert.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/home_page.dart';
import 'package:app/view/leaderboard_page.dart';
import 'package:app/view/task_alert_page.dart';
import 'package:app/view/user_activity_page.dart';
import 'package:app/view/user_learning_page.dart';
import 'package:app/view/user_profile_page.dart';
import 'package:excel/excel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//**Diese Klasse stellt die LandingPage der App dar. 
//Sie enthält eine Navigationsleiste (BottomNavigationBar) und einen PageView, um zwischen verschiedenen Ansichten zu wechseln. */
class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

//**Dies ist der zugehörige State für die LandingPage. 
//Hier wird die Logik für das Navigieren zwischen den Tabs und das Laden von Daten aus Excel-Dateien behandelt.
//Wichtige Teile dieses States sind: */
class _LandingPageState extends State<LandingPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<Widget> _contentPages = [];

  @override
  void initState() {
    _contentPages.add(HomePage(onTabSwitch: _switchFromHomeToAnotherTab));
    _contentPages.add(const UserActivityPage());
    _contentPages.add(const UserLearningPage());
    _contentPages.add(const LeaderBoardPage());
    _contentPages.add(const UserProfilePage());

//Ein PageController, der die Seitenansicht für die verschiedenen Tabs steuert.
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_handleTabSelection);

    super.initState();

    _loadExerciseDataFromAsset();
    _loadLearningMaterialFromAsset();
    // loading everything from the excel file

    if (AppCache.instance.didNotificationLaunchApp) {
      AppCache.instance.didNotificationLaunchApp = false;
      _handleOnNotificationClick();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // _checkIfAllowedToUseTheApp();
  }

  // _checkIfAllowedToUseTheApp() async {
  //   bool isActive = await ApiManager().checkIfTeamIsActive(AppConstant.teamNameForCustomBuild);

  //   if (!isActive && mounted) {
  //     showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           content: Container(
  //             width: 300,
  //             height: 175,
  //             padding: const EdgeInsets.all(20),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Text("Fehler!",
  //                   style: Theme.of(context).textTheme.titleLarge,
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 const SizedBox(height: 20,),
  //                 Expanded(
  //                   child: Text("Die Gültigkeit Ihres Kontos ist abgelaufen. Bitte wenden Sie sich an den Administrator Ihrer Organisation.",
  //                     style: Theme.of(context).textTheme.bodyLarge,
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               child: const Text("OK", style: TextStyle(color: AppColor.orange),),
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 exit(0);
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  void _handleTabSelection() {
    setState(() {});
  }

//**Diese Funktion wird aufgerufen, wenn der Benutzer auf eine Benachrichtigung klickt, um eine Aktion auszulösen. */
  Future<void> _handleOnNotificationClick() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();

    String? payload = notificationAppLaunchDetails?.notificationResponse?.payload;
    print('payload from on launch from notification click= $payload');

    if (!CommonUtil.isNullOrEmpty(payload)) {
      int taskHistoryId = int.tryParse(payload!) ?? 0;
      AlertHistory? alertHistory = await DatabaseHelper.instance.getAlertHistory(taskHistoryId);
      int taskType = alertHistory?.taskType.index ?? TaskType.exercise.index;

      if (mounted) {
        TaskAlertPageData alertPageData = TaskAlertPageData(viewMode: 0, taskType: taskType, taskHistoryId: taskHistoryId);

        print("-------> opening task alert page from _handleMessage for push notification onClicked from background");
        Navigator.pushNamed(context, taskAlertRoute, arguments: alertPageData);
      }
    }
  }

//**Diese Funktion wird aufgerufen, um von der Startseite zu einer anderen Seite zu wechseln.
// Sie aktualisiert den ausgewählten Tab und scrollt zur entsprechenden Seite. */
  void _switchFromHomeToAnotherTab(int tab) {
    _currentIndex = tab;
    _pageController.jumpToPage(tab);

    FocusScope.of(context).unfocus();
  }

//**Diese Funktion lädt Übungsdaten aus einer Excel-Datei im Asset-Ordner und speichert sie in der App. 
//Sie erstellt eine Liste von Übungen, wobei die Übungen nach medizinischen Bedingungen gefiltert werden.
//Die Übungen werden in AppCache.instance.exercises gespeichert. */
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

            bool addContent = false;
            if (exercise.condition != null && userCondition.isNotEmpty &&
                !exercise.condition!.contains(userCondition)) {
              addContent = true;
            } else if (userCondition.isEmpty) {
              addContent = true;
            } else {
              // Überspringe den Lerninhalt, da er für die angegebene Nutzerbedingung nicht nützlich ist.
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

//**Diese Funktion lädt Lernmaterialien aus einer Excel-Datei im Asset-Ordner und speichert sie in der App.
//Sie erstellt eine Liste von Lerninhalten und speichert sie in AppCache.instance.contents. */
  _loadLearningMaterialFromAsset() async {
    ByteData data = await rootBundle.load("assets/data/material_database.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    AppCache.instance.learningContents.clear();
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

          AppCache.instance.learningContents.add(content);
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
                icon: Icon(Icons.score,
                    color: _currentIndex == 3 ? Colors.orange : Colors.grey)),
            BottomNavigationBarItem(
                label: 'Profile',
                icon: Icon(Icons.person,
                    color: _currentIndex == 4 ? Colors.orange : Colors.grey)),
          ],
        ));
  }
}
