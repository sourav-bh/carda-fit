import 'dart:math';

import 'package:app/api/api_manager.dart';
import 'package:app/main.dart';
import 'package:app/model/user_api_model.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/widgets/avatar_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_avatar/random_avatar.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({Key? key}) : super(key: key);

  @override
  _LeaderBoardPageState createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  final List<UserApiModel> _participantInfo = List.empty(growable: true);
  final TextEditingController _avatarText = TextEditingController();
  String? _avatarName;
  String? _avatarImage;

  @override
  void initState() {
    super.initState();

    _loadAvatarName();
    _loadAllUsers();
    // _participantInfo.addAll(LeaderboardParticipantInfo.generateDummyList());
  }

  _loadAvatarName() async {
    var avatarName = await SharedPref.instance.getValue(SharedPref.keyUserAvatar);
    if (avatarName != null && avatarName is String) {
      setState(() {
        _avatarName = avatarName;
      });
    }

    UserInfo? userInfo = await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    if (userInfo != null) {
      setState(() {
        _avatarImage = userInfo.avatarImage;
      });
    }
  }

  Future<bool> _checkIfUserHasAvatar() async {
    var avatarName = await SharedPref.instance.getValue(SharedPref.keyUserAvatar);
    if (avatarName != null && avatarName is String) {
      return avatarName.isNotEmpty;
    } else {
      return false;
    }
  }

  _saveAction() async {
    String avatar = _avatarText.value.text;
    SharedPref.instance.saveStringValue(SharedPref.keyUserAvatar, avatar);

    setState(() {
      _avatarName = avatar;
    });

    UserInfo? userInfo = await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    if (userInfo != null) {
      userInfo.avatar = avatar;
      userInfo.avatarImage = _avatarImage;
      await DatabaseHelper.instance.updateUser(userInfo, AppCache.instance.userDbId);

      String? userId = await SharedPref.instance.getValue(SharedPref.keyUserServerId);
      if (userId != null && userId.isNotEmpty) {
        bool? res = await ApiManager().updateAvatarInfo(userId, avatar, _avatarImage ?? "");
        if (!res) {
          const snackBar = SnackBar(content: Text('Registrierung fehlschlagen'));
          ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(snackBar);
        } else {
          // _loadAllUsers();
        }
      }
    }
  }

  void _loadAllUsers() async {
    setState(() {
      _participantInfo.clear();
    });

    List<UserApiModel> allUsers = [];
    try {
      allUsers = await ApiManager().getAllUsers();
    } on Exception catch (_) {
      print('failed to connect with server');
    }

    for (var user in allUsers) {
      setState(() {
        _participantInfo.add(user);
      });
    }

    setState(() {
      _participantInfo.sort((a, b) => (b.score ?? 0).compareTo((a.score ?? 0)));
    });
  }

  UserApiModel _getTopUserInfo(int position) {
    if (position == 0 || position > _participantInfo.length) {
      return UserApiModel();
    } else {
      return _participantInfo[position-1];
    }
  }

  UserApiModel _getCurrentUserInfo() {
    if (_avatarName != null && _avatarName!.isNotEmpty) {
      var user = _participantInfo.firstWhere((element) => element.avatarName == _avatarName, orElse: () => UserApiModel());
      return user;
    } else {
      return UserApiModel();
    }
  }

  int _getCurrentUserPosition() {
    if (_avatarName != null && _avatarName!.isNotEmpty) {
      return _participantInfo.indexWhere((element) => element.avatarName == _avatarName);
    } else {
      return -1;
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
      body: FutureBuilder<bool>(
        future: _checkIfUserHasAvatar(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting: return const CircularProgressIndicator();
            default:
              if (snapshot.data ?? false) {
                return Column(
                  children: [
                    const SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                      child: Text('Du hast den ${_getCurrentUserPosition() + 1} Platz erreicht!',
                        style: Theme.of(context).textTheme.caption?.copyWith(color: AppColor.darkBlue, fontSize: 30, fontStyle: FontStyle.normal,),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text('Mit ${_getCurrentUserInfo().score ?? 0} Punkte', style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 20, color: Colors.brown)),
                    const SizedBox(height: 20,),
                    SizedBox(
                      height: 150,
                      child: GridView.extent(
                        padding: const EdgeInsets.all(8),
                        maxCrossAxisExtent: MediaQuery.of(context).size.width/3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
                            decoration: CommonUtil.getRectangleBoxDecoration(Colors.white54, 10),
                            child: CustomPaint(
                              painter: CurvePainter(Colors.green.shade300),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('2', style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                  const SizedBox(width: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_getTopUserInfo(2).avatarName ?? "", style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 24), textAlign: TextAlign.center,),
                                      const SizedBox(width: 10,),
                                      randomAvatar(_getTopUserInfo(2).avatarImage ?? "", width: 25, height: 25),
                                    ],
                                  ),
                                  const SizedBox(width: 10,),
                                  Text('${_getTopUserInfo(2).score ?? 0}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 24, color: Colors.brown), textAlign: TextAlign.center,),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: CommonUtil.getRectangleBoxDecoration(Colors.white54, 10),
                            child: CustomPaint(
                              painter: CurvePainter(Colors.orange.shade300),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('1', style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                  const SizedBox(width: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_getTopUserInfo(1).avatarName ?? "", style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 24), textAlign: TextAlign.center,),
                                      const SizedBox(width: 10,),
                                      randomAvatar(_getTopUserInfo(1).avatarImage ?? "", width: 25, height: 25),
                                    ],
                                  ),
                                  const SizedBox(width: 10,),
                                  Text('${_getTopUserInfo(1).score ?? 0}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 24, color: Colors.brown), textAlign: TextAlign.center,),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            decoration: CommonUtil.getRectangleBoxDecoration(Colors.white54, 10),
                            child: CustomPaint(
                              painter: CurvePainter(Colors.blue.shade300),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('3', style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                  const SizedBox(width: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_getTopUserInfo(3).avatarName ?? "", style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 24), textAlign: TextAlign.center,),
                                      const SizedBox(width: 10,),
                                      randomAvatar(_getTopUserInfo(3).avatarImage ?? "", width: 25, height: 25),
                                    ],
                                  ),
                                  const SizedBox(width: 10,),
                                  Text('${_getTopUserInfo(3).score ?? 0}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 24, color: Colors.brown), textAlign: TextAlign.center,),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: max(_participantInfo.length-3, 0),
                        itemBuilder: (BuildContext context, int index) {
                          UserApiModel participant = _participantInfo[index + 3];
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
                                              Text(participant.avatarName ?? "", style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 24), textAlign: TextAlign.center,),
                                              const SizedBox(width: 10,),
                                              randomAvatar(participant.avatarImage ?? "", width: 40, height: 40)
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
                );
              } else {
                // ask to set a avatar name
                return ListView(
                  children: [
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                      child: Text('Bitte geben Sie Ihren Avatarnamen ein und wählen Sie ein Avatarbild, um die Rangliste zu sehen!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColor.darkBlue, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: CommonUtil.getRectangleBoxDecoration(Colors.white, 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _avatarText,
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.orange,
                            decoration: InputDecoration(
                              hintText: "Avatar Name",
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(width: 1, color: Colors.white12), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(width: 1, color: Colors.white12), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              fillColor: Colors.grey.shade300,
                              filled: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: CommonUtil.getRectangleBoxDecoration(Colors.white, 25),
                      child: SizedBox(
                        height: 300,
                        child: AvatarImagePickerView(
                          onItemSelected: (String? avatar) {
                            _avatarImage = avatar;
                            print("avatar selected: $avatar");
                          },
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) => Colors.transparent,),
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                          ),
                          onPressed: () {
                            _saveAction();
                          },
                          child: Ink(
                            decoration: const BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 50), // min sizes for Material buttons
                              alignment: Alignment.center,
                              child: Text("speichern".toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          )),
                    ),
                  ],
                );
              }
          }
        },
      )
    );
  }
}
