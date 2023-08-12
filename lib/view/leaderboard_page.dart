import 'dart:math';

import 'package:app/api/api_manager.dart';
import 'package:app/model/user_info.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/widgets/leaderborad_top_item.dart';
import 'package:app/view/widgets/user_badge_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:random_avatar/random_avatar.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({Key? key}) : super(key: key);

  @override
  _LeaderBoardPageState createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  final List<UserInfo> _teamMembersList = List.empty(growable: true);
  String? _currentUserName;

  @override
  void initState() {
    super.initState();

    _loadUserName();
    _loadAllUsers();
  }

  _loadUserName() async {
    var userName = await SharedPref.instance.getValue(SharedPref.keyUserName);
    if (userName != null && userName is String) {
      setState(() {
        _currentUserName = userName;
      });
    }
  }

  void _loadAllUsers() async {
    setState(() {
      _teamMembersList.clear();
    });

    List<UserInfo> allUsers = [];
    try {
      allUsers = await ApiManager().getAllUsersByTeam(AppConstant.teamNameForCustomBuild);
    } on Exception catch (_) {
      print('failed to connect with server');
    }

    for (var user in allUsers) {
      if (user.userName != _currentUserName && mounted) {
        setState(() {
          _teamMembersList.add(user);
        });
      }
    }

    setState(() {
      _teamMembersList.sort((a, b) => (b.score ?? 0).compareTo((a.score ?? 0)));
    });
  }

  UserInfo _getCurrentUserInfo() {
    if (_currentUserName != null && _currentUserName!.isNotEmpty) {
      var user = _teamMembersList.firstWhere((element) => element.userName == _currentUserName, orElse: () => UserInfo());
      return user;
    } else {
      return UserInfo();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hallo, $_currentUserName',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5,),
                      Text('Ihr aktueller Spielstand ist: ${_getCurrentUserInfo().score ?? 0}', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black87)),
                      const SizedBox(height: 15,),
                      Text('Mach weiter mit den Aktivitäten und schalte das nächste Level frei!',
                          style: Theme.of(context).textTheme.labelMedium
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20,),
                UserBadgeView(userLevel: CommonUtil.getUserLevelByScore(_getCurrentUserInfo().score ?? 0),),
              ],
            ),
          ),
          const SizedBox(height: 30,),
          _teamMembersList.isEmpty ?
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
            child: Text('Derzeit gibt es keine anderen Teammitglieder, die angezeigt werden können!',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
          ) :
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Sehen was andere machen',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.brown)
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: max(_teamMembersList.length, 0),
              itemBuilder: (BuildContext context, int index) {
                UserInfo participant = _teamMembersList[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Card(
                      elevation: 5,
                      color: Colors.pink.shade100,
                      child: Container(
                        decoration: CommonUtil.getRectangleBoxDecoration(Colors.pink.shade100, 15),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: CommonUtil.getRectangleBoxDecoration(Colors.white.withAlpha(205), 5),
                                child: Row(
                                  children: [
                                    Text('${index + 4}.', style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 30, color: Colors.brown, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                    const SizedBox(width: 10,),
                                    Text(participant.userName ?? "", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20), textAlign: TextAlign.center,),
                                    const SizedBox(width: 10,),
                                    RandomAvatar(participant.avatarImage ?? "n/a", width: 40, height: 40)
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text('${participant.score ?? 0}',
                                style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 30, color: Colors.black54, fontWeight: FontWeight.bold), textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                );
              },
            ),
          )
        ],
      )
    );
  }
}

class HexagonalBadge extends StatelessWidget {
  final Color color;
  final Icon icon;
  final int badgeNumber;

  const HexagonalBadge({
    required this.color,
    required this.icon,
    required this.badgeNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          icon,
          Positioned(
            right: 10,
            top: 10,
            child: Badge(
              backgroundColor: Colors.white,
              child: Text(badgeNumber.toString()),
            ),
          ),
        ],
      ),
    );
  }
}