import 'dart:io';
import 'package:app/view/user_info_page.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/shared_preference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multiselect/multiselect.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/view/user_info_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class TimeSaver {
  static int? currentTime;
  // TODO: curentTime has to be converted to int
  static void saveCurrentTime() {
    currentTime = DateTime.now().millisecondsSinceEpoch;
    if (kDebugMode) {
      print('Current time saved: $currentTime');
    }
  }
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserInfo? _userInfo;
  String? valueChoose;
  List listItem = ["5 min", '10 min', '30 min', '60 min', '120 min', '1 Tag'];
  late String _newValue;
  int? snoozeTimeBySelect;
  String time = "";
  late bool userEditProfile;
  bool? SnoozeDecision;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _getTime();
  }

  _loadUserInfo() async {
    UserInfo? userInfo =
        await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    if (userInfo != null) {
      setState(() {
        _userInfo = userInfo;
      });
    }
  }

  _getTime() async {
    // TODO: @Justin -- implement here your code to save the value
    SharedPref.instance
        .saveStringValue(SharedPref.keySnoozeDuration, _newValue);
    // TODO: @Justin -- also save the current time to indicate that user when saved the snooze time
    SharedPref.instance
        .saveIntValue(SharedPref.keySnoozeActualTime, TimeSaver.currentTime!);
    // Send Bool
    SharedPref.instance
        .saveBoolValue(SharedPref.keySnoozeDecision, SnoozeDecision!);
  }

  // List of times that can be selected for snooze the notifications
  List<String> list = <String>[
    '5 min',
    '10 min',
    '30 min',
    '60 min',
    '120 min',
    '1 Tag'
  ];

  _logoutAction() async {
    SharedPref.instance.clearCache();
    Navigator.pushNamed(context, userInfoRoute);
  }

  // sending
  _editProfile() async {
    // TODO: @Justin -- implement here your code to send value to indicate as edit profile page
    Navigator.pushNamed(context, userInfoRoute, arguments: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double topHeight = MediaQuery.of(context).size.height / 4;
    if (kIsWeb) {
      topHeight = MediaQuery.of(context).size.height / 2.5;
    }
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Platform.isIOS
            ? SystemUiOverlayStyle.light
            : const SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.light),
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                height: topHeight,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppColor.lightPink, AppColor.lightPink],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
              ),
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(
                    top: (topHeight) - MediaQuery.of(context).size.width / 5.5),
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: MediaQuery.of(context).size.width / 5.5,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: (MediaQuery.of(context).size.width / 5.5),
                        child: ClipOval(
                            child: _userInfo?.avatarImage != null
                                ? RandomAvatar(_userInfo?.avatarImage ?? "")
                                : const Icon(
                                    Icons.person_outlined,
                                    size: 100,
                                  )),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Avatar Name: ',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.copyWith(fontSize: 18),
                        ),
                        Text(
                          _userInfo?.avatar ?? "Nicht ausgewählt",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontSize: 24),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.only(top: 30),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.person_pin_rounded,
                                  color: Colors.orangeAccent, size: 25),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                _userInfo?.fullName ?? "",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(fontSize: 20),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.male_rounded,
                                  color: Colors.orangeAccent, size: 25),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                _userInfo?.gender ?? "Nicht ausgewählt",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(fontSize: 20),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.date_range,
                                  color: Colors.orangeAccent, size: 25),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                _userInfo?.age != 0
                                    ? '${_userInfo?.age} Jahre'
                                    : 'Nicht ausgewählt',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(fontSize: 20),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.medical_services,
                                  color: Colors.orangeAccent, size: 25),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                _userInfo?.condition ?? "Nicht ausgewählt",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(fontSize: 20),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.filter_tilt_shift,
                                  color: Colors.orangeAccent, size: 25),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                _userInfo?.jobType ?? "Nicht ausgewählt",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(fontSize: 20),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.design_services,
                                  color: Colors.orangeAccent, size: 25),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  _userInfo?.designation ?? "Nicht ausgewählt",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.copyWith(fontSize: 20),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      child: DropdownButton(
                        hint:
                            const Text('Pausieren Sie die Benachrichtigungen'),
                        dropdownColor: Colors.grey,
                        icon: const Icon(Icons.arrow_drop_down),
                        value: valueChoose,
                        onChanged: (newValue) {
                          setState(() {
                            valueChoose = newValue as String?;
                            TimeSaver.saveCurrentTime();
                            debugPrint(newValue);
                            SnoozeDecision = true;
                          });
                        },
                        items: listItem.map((valueItem) {
                          return DropdownMenuItem(
                            value: valueItem,
                            child: Text(valueItem),
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) => Colors.transparent,
                            ),
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          onPressed: () {
                            _logoutAction();
                            _editProfile();
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
                                "Abmeldung".toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) => Colors.transparent,
                            ),
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          onPressed: () {
                            _editProfile();
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
                                "Profil bearbeiten".toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
