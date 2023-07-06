import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app/main.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/shared_preference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:multiselect/multiselect.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserInfo? _userInfo;
  String? valueChoose;
  List listItem = ["5 min", '10 min', '30 min', '60 min', '120 min', '1 Tag'];
  final _prefs = SharedPreferences.getInstance();
  late Future<String> _newValue;

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

  // don't know how to safe my String in SharedPreference
  _getTime() async {
    final SharedPreferences prefs = await _prefs;

    final String? newValue = (prefs.getString('newValue'));
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

  _editProfile() async {
    Navigator.pushNamed(context, userInfoRoute);
    UserInfo? userInfo =
        await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
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
                                ? randomAvatar(_userInfo?.avatarImage ?? "")
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
                            debugPrint(newValue);
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
