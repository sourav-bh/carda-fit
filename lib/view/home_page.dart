import 'dart:io';
import 'dart:math';

import 'package:app/app.dart';
import 'package:app/model/learning.dart';
import 'package:app/model/task_alert.dart';
import 'package:app/model/user_daily_target.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/task_alert_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:app/view/snooze_page.dart';

import '../model/user_info.dart';

//**Dies ist eine Klasse, die die gesamte Seite für die HomePage darstellt.
// Sie enthält tägliche Fitnessziele, Lernmaterialien und Optionen zur Einstellung der Snooze-Zeit. */
class HomePage extends StatefulWidget {
  final void Function(int)? onTabSwitch;
  final void Function()? onUpdateState;

  const HomePage({Key? key, this.onTabSwitch, this.onUpdateState})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

//** Dies ist der zugehörige State für die HomePage.
//Der State enthält die Logik für das Laden von Daten und das Verwalten der Snooze-Zeit.*/
class _HomePageState extends State<HomePage> {
  final List<FitnessItemInfo> _dailyFitnessItems = List.empty(growable: true);
  final List<LearningMaterialInfo> _learningMaterials =
  List.empty(growable: true);

  SnoozeTime? _selectedSnoozeTimeVal;
  List<LearningContent> convertLearningList = [];
  bool isSelected = false;
  final List<SnoozeTime> _snoozeTimeItems = [
    SnoozeTime(duration: const Duration(minutes: 5), isSelected: false),
    SnoozeTime(duration: const Duration(minutes: 10), isSelected: false),
    SnoozeTime(duration: const Duration(minutes: 30), isSelected: false),
    SnoozeTime(duration: const Duration(hours: 1), isSelected: false),
    SnoozeTime(duration: const Duration(hours: 2), isSelected: false),
    SnoozeTime(duration: const Duration(hours: 3), isSelected: false),
  ];

  double _currentUserProgress = 0;

  @override
  void initState() {
    super.initState();
    _checkSnoozeButtonStatus();
    _dailyFitnessItems.addAll(FitnessItemInfo.generateDummyList());

    _checkSnoozeTimeStatus();

    _loadCurrentProgress();
    _loadLearningContent();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // In der _HomePageState-Klasse
  void onUpdateState() {
    setState(() {
      _checkSnoozeButtonStatus();
      _checkSnoozeTimeStatus();
      // Fügen Sie weitere Aktualisierungen hinzu, falls erforderlich
    });
  }

/* *Diese Funktion nimmt die gewählte Snooze Time auf und übergibt sie und die Uhrzeit,
   *zu dem genauen Zeitpunkt, als die Snooze Time gewählt wurde, per SharedPreference */
  void setSnoozeTime(SnoozeTime snoozeTime) async {
    setState(() {
      _selectedSnoozeTimeVal = snoozeTime;
      isSelected = true;
    });

    await SharedPref.instance.saveIntValue(SharedPref.keySnoozeDuration,
        _selectedSnoozeTimeVal?.duration.inMinutes ?? 0);
    await SharedPref.instance.saveIntValue(
        SharedPref.keySnoozedAt, DateTime.now().millisecondsSinceEpoch);
  }

/* *Diese Funktion wird genutzt, um zu überprüfen ob deer Nutzer eine Snooze Time gesetzt  hat
   *Hier wird die gewählte Snooze Dauer, Zeit zu der Snooze aktiviert wurde und entscheidet basierend
   *auf der aktuellen Zeit, ob die Snooze Time noch läuft oder schon abgelaufen ist.
   * */
  _checkSnoozeTimeStatus() async {
    int snoozeDuration =
    await SharedPref.instance.getIntValue(SharedPref.keySnoozeDuration);
    int snoozedAt =
    await SharedPref.instance.getIntValue(SharedPref.keySnoozedAt);
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    if (currentTime - snoozedAt > snoozeDuration * 60 * 1000) {
      setState(() {
        _selectedSnoozeTimeVal = null;
      });

      await SharedPref.instance.deleteValue(SharedPref.keySnoozeDuration);
      await SharedPref.instance.deleteValue(SharedPref.keySnoozedAt);
    } else {
      setState(() {
        _selectedSnoozeTimeVal = SnoozeTime(
            duration: Duration(minutes: snoozeDuration), isSelected: true);
      });
    }
  }

  _checkSnoozeButtonStatus() async {
    int snoozeDuration =
    await SharedPref.instance.getIntValue(SharedPref.keySnoozeDuration);
    int snoozedAt =
    await SharedPref.instance.getIntValue(SharedPref.keySnoozedAt);
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    if (currentTime - snoozedAt <= snoozeDuration * 60 * 1000) {
      // Snooze-Zeit ist aktiv
      setState(() {
        isSelected = true; // Button ist orange
      });
    } else {
      // Snooze-Zeit ist abgelaufen
      setState(() {
        isSelected = false; // Button ist transparent
      });
    }
  }

//**Diese Funktion lädt Lerninhalte in die _learningMaterials-Liste.
//Wenn die Liste AppCache.instance.contents nicht leer ist, wird der erste Lerninhalt ausgewählt
//und in die Liste _learningMaterials hinzugefügt. */
  _loadLearningContent() async {
    if (AppCache.instance.learningContents.isNotEmpty) {
      var info = await LearningMaterialInfo.copyContentFromLink(
          AppCache.instance.learningContents.first);
      if (mounted) {
        setState(() {
          _learningMaterials.add(info);
        });
      }
    }
  }

//**Diese Funktion lädt den aktuellen Fortschritt des Benutzers.
//Sie ruft die abgeschlossenen Aufgaben des Benutzers aus den SharedPreferences ab und berechnet den Fortschritt.
//Der Fortschritt wird in Prozent berechnet und in der Variable _currentUserProgress gespeichert. */
  _loadCurrentProgress() async {
    var completedJson = await SharedPref.instance
        .getJsonValue(SharedPref.keyUserCompletedTargets);
    if (completedJson != null &&
        completedJson is String &&
        completedJson.isNotEmpty) {
      var completedJobs = DailyTarget.fromRawJson(completedJson);
      var totalTaskValues = AppConstant.waterTaskValue +
          AppConstant.exerciseTaskValue +
          AppConstant.stepsTaskValue +
          AppConstant.breakTaskValue;
      double percentagePerTask = 100 / (totalTaskValues * 8);
      setState(() {
        _currentUserProgress = (min(completedJobs.waterGlasses ?? 0, 8) *
            percentagePerTask) +
            (min(completedJobs.exercises ?? 0, 8) * percentagePerTask) +
            ((min(completedJobs.steps ?? 0, 800) / 100) * percentagePerTask) +
            (min(completedJobs.breaks ?? 0, 8) * percentagePerTask);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: AppColor.lightPink,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: -10,
            child: Image.asset(
              "assets/images/healthy_day.jpeg",
              height: 180,
              color: AppColor.lightPink,
              colorBlendMode: BlendMode.darken,
              opacity: const AlwaysStoppedAnimation(.5),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ListView(
              children: [
                Visibility(
                    visible: true,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      // Zitat
                                      TextSpan(
                                        text: DataLoader.quotes[
                                        AppCache.instance.quoteIndex],
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                          color: AppColor.darkBlue,
                                          fontSize: 24,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                      // Zitatautor
                                      TextSpan(
                                        text:
                                        '\n${DataLoader.quotesAuthor[AppCache.instance.quoteIndex]}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                          color: Colors.black54,
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    // _showSnoozeTimeSelected(context);
                                    Navigator.pushNamed(context, snoozeRoute);
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => SnoozePage(
                                    //         onUpdateState: onUpdateState),
                                    //   ),
                                    // );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 20),
                                    decoration:
                                    CommonUtil.getRectangleBoxDecoration(
                                        _selectedSnoozeTimeVal != null
                                            ? Colors.orangeAccent
                                            : Colors.white70,
                                        10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.snooze,
                                              size: 20, color: Colors.black),
                                          const SizedBox(height: 0),
                                          Text(_selectedSnoozeTimeVal != null
                                              ? '${_selectedSnoozeTimeVal!.duration.inMinutes} min'
                                              : 'Snooze'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                      ),
                    )
                ),
                GestureDetector(
                  onTap: () {
                    widget.onTabSwitch?.call(1);
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    padding: const EdgeInsets.all(15),
                    decoration: CommonUtil.getRectangleBoxDecoration(Colors.white70, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.crisis_alert_rounded,
                              color: Colors.black54,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text("Tagesziele"),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                widget.onTabSwitch?.call(1);
                              },
                              child: const Icon(Icons.more_horiz),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Schritt für Schritt erreichen Sie Ihr Ziel",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColor.darkBlue,
                            fontSize: 20,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Sie machen sich heute gut, machen Sie weiter, um Ihre Tagesziele zu erreichen!",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                child: LinearProgressIndicator(
                                  value: _currentUserProgress / 100,
                                  color: Colors.pink,
                                  backgroundColor: Colors.white,
                                  minHeight: 20,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "${_currentUserProgress.round()} %",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  padding: const EdgeInsets.all(15),
                  decoration:
                  CommonUtil.getRectangleBoxDecoration(Colors.white70, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.recommend_outlined,
                            color: Colors.black54,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text("Empfehlungen"),
                          const Spacer(),
                          GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, alertHistoryRoute);
                              },
                              child: Text(
                                "Alarmverlauf",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                  color: AppColor.orange,
                                  fontSize: 18,
                                  fontStyle: FontStyle.normal,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Glaube an die Magie der Regelmäßigkeit, lass sie uns heute rocken",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColor.darkBlue,
                            fontSize: 20,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 100,
                        decoration: CommonUtil.getRectangleBoxDecoration(Colors.white12, 10),
                        child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) {
                              FitnessItemInfo item = _dailyFitnessItems[index];
                              return GestureDetector(
                                child: ClipOval(
                                  child: SizedBox.fromSize(
                                    // 45 is for 3x15 gap between the items and 62 is for 30 + 32 padding + margin of the parent & this view
                                    size: Size.fromRadius((deviceWidth-45-62)/8),
                                    child: Container(
                                        color: Colors.white,
                                        child: Image.asset(item.image, fit: BoxFit.cover,)
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  TaskAlertPageData alertPageData = TaskAlertPageData(viewMode: 1, taskType: item.taskType.index);
                                  print("-------> opening task alert page from on home page item click");
                                  Navigator.pushNamed(context, taskAlertRoute, arguments: alertPageData);
                                },
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const Divider(endIndent: 15, color: Colors.transparent);
                            },
                            // itemCount: _homeFeed?.popularProducts?.length ?? 0,
                            itemCount: _dailyFitnessItems.length,
                            scrollDirection: Axis.horizontal),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  padding: const EdgeInsets.all(15),
                  decoration:
                  CommonUtil.getRectangleBoxDecoration(Colors.white70, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.menu_book,
                            color: Colors.black54,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text("Lernmaterialien"),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              // switch tab
                              widget.onTabSwitch?.call(2);
                              // CommonUtil.testApi();
                            },
                            child: Text(
                              "Alles",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                color: AppColor.orange,
                                fontSize: 18,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Lernen Sie die Dinge in Ihrem eigenen Tempo, das Leben ist kein Wettlauf",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColor.darkBlue,
                            fontSize: 20,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          LearningMaterialInfo material =
                          _learningMaterials[index];
                          return GestureDetector(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.all(10),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      child: Image.network(
                                        material.thumbnail ?? "",
                                        fit: BoxFit.fitHeight,
                                      )),
                                ),
                                Expanded(
                                  child: Container(
                                    margin:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          material.title.trim(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(fontSize: 20),
                                          maxLines: 2,
                                        ),
                                        Text(
                                          material.description.trim(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          maxLines: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  margin: const EdgeInsets.all(10),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppColor.darkBlue,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, detailsWebRoute,
                                  arguments:
                                  _learningMaterials.first.originalContent);
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(
                              endIndent: 0, color: Colors.transparent);
                        },
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _learningMaterials.length,
                        scrollDirection: Axis.vertical,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnoozeTimeSelected(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.transparent,
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(
                        left: 20, top: 65, right: 20, bottom: 20),
                    margin: const EdgeInsets.only(top: 45),
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 10),
                              blurRadius: 10),
                        ]),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            children: [
                              for (var snoozeTime in _snoozeTimeItems)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  child: FilterChip(
                                    label: Text(
                                        '${(snoozeTime.duration.inMinutes)} min'),
                                    labelStyle:
                                    const TextStyle(color: Colors.white),
                                    selected: snoozeTime.isSelected,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        for (var i = 0;
                                        i < _snoozeTimeItems.length;
                                        i += 1) {
                                          _snoozeTimeItems[i].isSelected =
                                          false;
                                        }
                                        snoozeTime.isSelected =
                                        !(snoozeTime.isSelected);
                                        setSnoozeTime(snoozeTime);
                                      });
                                    },
                                    elevation: 5,
                                    pressElevation: 10,
                                    backgroundColor: AppColor.darkGrey,
                                    selectedColor: AppColor.orange,
                                    showCheckmark: true,
                                    checkmarkColor: Colors.white,
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'OK',
                                  style:
                                  Theme.of(context).textTheme.titleMedium,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 20,
                    right: 20,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 45,
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(45)),
                          child: Icon(
                            Icons.snooze,
                            color: AppColor.primary,
                            size: 40,
                          )),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }
}