import 'package:app/app.dart';
import 'package:app/model/user_daily_target.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/widgets/user_activity_item.dart';
import 'package:flutter/material.dart';

//Diese Klasse repräsentiert eine Seite in der App, auf der Benutzer sich ihre täglichen Aktivitätsziele und deren Fortschritt anzeigen lassen können.
class UserActivityPage extends StatefulWidget {
  const UserActivityPage({Key? key}) : super(key: key);

  @override
  _UserActivityPageState createState() => _UserActivityPageState();
}

//In diesem State werden Daten und Logik für die Seite zur Anzeige von Aktivitätszielen und deren Fortschritt verwaltet.
class _UserActivityPageState extends State<UserActivityPage> {
  DailyTarget? _dailyTarget;
  DailyTarget? _completedJobs;
  WalkingSpeed? _walkingSpeedValue = WalkingSpeed.medium;

  @override
  void initState() {
    super.initState();

    _loadUserInfo();
  }

  _loadUserInfo() async {
    int userDbId = await SharedPref.instance.getValue(SharedPref.keyUserDbId);
    UserInfo? userInfo = await DatabaseHelper.instance.getUserInfo(userDbId);
    if (userInfo != null) {
      setState(() {
        if (userInfo.walkingSpeed == "slow") {
          _walkingSpeedValue = WalkingSpeed.slow;
        } else if (userInfo.walkingSpeed == 'fast') {
          _walkingSpeedValue = WalkingSpeed.fast;
        } else {
          _walkingSpeedValue = WalkingSpeed.medium;
        }
      });
    }

    print(_walkingSpeedValue);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadDailyTarget();
  }

// Diese Funktion lädt die täglichen Aktivitätsziele und abgeschlossenen Aufgaben aus den Shared Preferences und aktualisiert den Zustand des Widgets.
  _loadDailyTarget() async {
    var targetJson = await SharedPref.instance.getJsonValue(SharedPref.keyUserTargets);
    if (targetJson != null && targetJson is String && targetJson.isNotEmpty) {
      setState(() {
        _dailyTarget = DailyTarget.fromRawJson(targetJson);
      });
    }

    var completedJson = await SharedPref.instance.getJsonValue(SharedPref.keyUserCompletedTargets);
    if (completedJson != null && completedJson is String && completedJson.isNotEmpty) {
      setState(() {
        _completedJobs = DailyTarget.fromRawJson(completedJson);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.lightPink,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/user_activity_banner.jpg",
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitHeight,
              color: AppColor.lightPink,
              colorBlendMode: BlendMode.darken,
              opacity: const AlwaysStoppedAnimation(1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Aktivität heute",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColor.darkBlue, fontSize: 30, fontStyle: FontStyle.normal,)
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, alertHistoryRoute);
                    },
                    child: Row(
                      children: [
                        Text("",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColor.darkBlue, fontSize: 20, fontStyle: FontStyle.normal,)
                        ),
                        const Icon(Icons.list_alt, color: AppColor.primary, size: 30,)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserActivityItemView(
                      icon: Icons.directions_walk,
                      title: "Schritt",
                      subTitle:
                          "${_completedJobs?.steps ?? 0}/${_dailyTarget?.steps ?? 0}",
                      highlightColor: Colors.purple,
                      shadeColor: Colors.purple.shade100,
                      progressValue: ((_completedJobs?.steps ?? 0) /
                          (_dailyTarget?.steps ?? 1))),
                  UserActivityItemView(
                      icon: Icons.sports_gymnastics,
                      title: "Übung",
                      subTitle:
                          "${_completedJobs?.exercises ?? 0}/${_dailyTarget?.exercises ?? 0}",
                      highlightColor: Colors.orange,
                      shadeColor: Colors.orange.shade100,
                      progressValue: ((_completedJobs?.exercises ?? 0) /
                          (_dailyTarget?.exercises ?? 1))),
                  UserActivityItemView(
                      icon: Icons.local_drink_rounded,
                      title: "Wasser",
                      subTitle:
                          "${_completedJobs?.waterGlasses ?? 0}/${_dailyTarget?.waterGlasses ?? 0}",
                      highlightColor: Colors.lightBlue,
                      shadeColor: Colors.lightBlue.shade100,
                      progressValue: ((_completedJobs?.waterGlasses ?? 0) /
                          (_dailyTarget?.waterGlasses ?? 1))),
                  UserActivityItemView(
                      icon: Icons.timer,
                      title: "Pause",
                      subTitle:
                          "${_completedJobs?.breaks ?? 0}/${_dailyTarget?.breaks ?? 0}",
                      highlightColor: Colors.red,
                      shadeColor: Colors.red.shade100,
                      progressValue: ((_completedJobs?.breaks ?? 0) /
                          (_dailyTarget?.breaks ?? 1))),
                ],
              ),
            ),
          ],
        ));
  }
}
