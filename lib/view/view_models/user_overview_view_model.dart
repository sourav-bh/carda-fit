import 'package:app/model/trophy.dart';
import 'package:app/model/user_activity.dart';
import 'package:app/model/user_info.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/common_util.dart';
import 'package:flutter/material.dart';

import '../../service/database_helper.dart';

/// To test change
/// Change [userInfo?.score ?? 0] at line 24, 28 to 1000

class UserOverviewViewModel extends ChangeNotifier {
  UserInfo? _userInfo;

  UserInfo? get userInfo => _userInfo;

  UserActivity? _userActivity;

  UserActivity? get userActivity => _userActivity;

  bool _loading = true;

  bool get loading => _loading;

  UserLevel? get userLevel {
    return CommonUtil.getUserLevelByScore(userInfo?.score ?? 0);
  }

  List<Trophy> get haveTrophies {
    return CommonUtil.getUserTrophyByScore(userInfo?.score ?? 0);
  }

  Trophy? get currentTrophy {
    if (haveTrophies.isEmpty) return null;
    return haveTrophies.last;
  }

  int _loginCount = 0;

  int get loginCount => _loginCount;

  Future init(BuildContext context) async {
    UserInfo? userInfo =
        await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    _userActivity = await DatabaseHelper.instance
        .getUserActivity(AppCache.instance.userDbId);
    _userInfo = userInfo;
    _loading = false;
    Future.sync(() => checkScoreToGetTrophy(context, userInfo));
    checkLastLogin(userInfo);
    notifyListeners();
  }

  Future checkLastLogin(UserInfo? userInfo) async {
    if (_userActivity == null) {
      _loginCount = 1;
      return;
    }
    _loginCount = _userActivity!.loginCount ?? 1;
    var now = DateTime.now();
    var currentDate = DateTime(now.year, now.month, now.day);
    var lastLogin = _userActivity?.lastLogin;
    if (lastLogin == null) return;
    var lastLoginTime =
        DateTime.fromMillisecondsSinceEpoch(lastLogin);
    var lastLoginDate =
        DateTime(lastLoginTime.year, lastLoginTime.month, lastLoginTime.day);
    var dif = currentDate.difference(lastLoginDate).inDays;
    if (dif >= 24) {
      _loginCount += 1;
      var update = _userActivity!.copyWith(loginCount: _loginCount);
      await DatabaseHelper.instance
          .updateUserActivity(update, _userActivity!.id!);
      return;
    }
  }

  Future checkScoreToGetTrophy(BuildContext context, UserInfo? userInfo) async {
    var lastTrophyId = _userActivity?.lastTrophyId;
    Trophy? lastTrophy;
    if (lastTrophyId != null) {
      lastTrophy =
          Trophy.trophies.where((x) => x.id == lastTrophyId).firstOrNull;
    }
    var newTrophy = _haveNewTrophy(lastTrophy, haveTrophies);
    if (newTrophy == null) return;
    var update = _userActivity!.copyWith(lastTrophyId: newTrophy.id);
    await DatabaseHelper.instance
        .updateUserActivity(update, _userActivity!.id!);
    Future.sync(() => _showNewTrophy(context, newTrophy));
  }

  Trophy? _haveNewTrophy(Trophy? lastTrophy, List<Trophy> haveTrophies) {
    var newLastTrophy = haveTrophies.lastOrNull;
    if (newLastTrophy == null) return null;
    if (lastTrophy == null || ((lastTrophy.id != newLastTrophy.id))) {
      return newLastTrophy;
    }
    return null;
  }

  Future _showNewTrophy(BuildContext context, Trophy newTrophy) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return GestureDetector(
          onTap: () {
            Navigator.of(_).pop();
          },
          child: Scaffold(
            backgroundColor: Colors.black.withOpacity(.7),
            body: Center(
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                height: 150,
                decoration:
                    CommonUtil.getRectangleBoxDecoration(Colors.white70, 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        newTrophy.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: Text(
                          newTrophy.name,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}