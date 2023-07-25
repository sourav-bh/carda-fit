import 'dart:io';
import 'dart:math';
import 'package:app/api/api_manager.dart';
import 'package:app/main.dart';
import 'package:app/model/user_api_model.dart';
import 'package:app/model/user_daily_target.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/shared_preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multiselect/multiselect.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Gender? _genderValue;
  JobType? _jobTypeValue;
  UserInfo? _userInfo;
  bool? editProfile;
  final TextEditingController _nameText = TextEditingController();
  final TextEditingController _ageText = TextEditingController();
  final TextEditingController _weightText = TextEditingController();
  final TextEditingController _heightText = TextEditingController();
  final TextEditingController _designationText = TextEditingController();

  List<String> conditionItems = <String>[
    'Wählen Sie Ihre Problemzonen',
    'Herz',
    'Beine',
    'Knie',
    'Schulter',
    'Nacken',
    'Rücken',
    'Arme',
    'Hände',
    'Bauch',
    'Augen',
  ];

  String conditionValue = "Wählen Sie Ihre Problemzonen";
  String? userInfoPageTitle;

  List<String> selected = [];

  @override
  void initState() {
    super.initState();
    // _loadData();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //
  //   // TODO: @Justin -- implement here your code to receive value,
  //   editProfile = ModalRoute.of(context)?.settings.arguments as bool?;
  //   setState(() {
  //     if (editProfile ?? false) {
  //       userInfoPageTitle = 'Profil bearbeiten';
  //     } else {
  //       userInfoPageTitle = 'Registrierung';
  //     }
  //   });
  //   //  if it is a edit profile page or just a registration page
  // }

  void _loadData() async {
    UserInfo? userInfo =
        await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    while (editProfile = true) {
      if (userInfo != null) {
        setState(() {
          _ageText.text = userInfo.age.toString();
          _nameText.text = userInfo.fullName ?? '';
          _weightText.text = userInfo.weight.toString();
          _heightText.text = userInfo.height.toString();
          _designationText.text = userInfo.designation ?? '';
          if (userInfo.gender == "Männlich") {
            _genderValue = Gender.Mannlich;
          } else if (userInfo.gender == 'Weiblich') {
            _genderValue = Gender.Weiblich;
          } else if (userInfo.gender == 'Divers') {
            _genderValue = Gender.Divers;
          }
          if (userInfo.jobType == "Vollzeit") {
            _jobTypeValue = JobType.Vollzeit;
          } else if (userInfo.gender == 'Teilzeit') {
            _jobTypeValue = JobType.Teilzeit;
          } else if (userInfo.gender == 'Außendienst') {
            _jobTypeValue = JobType.HomeOffice;
          }
          selected = userInfo.condition!.replaceAll(" ", "").split(',');
          // condition.join(', ');

          // ageText missing to display
          //debugPrint(userInfo.age.toString());
        });
      }
    }
  }

  void _saveAction() async {
    String name = _nameText.value.text;
    if (name.isEmpty) {
      const snackBar = SnackBar(content: Text('Name ist obligatorisch'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      int age = int.tryParse(_ageText.value.text) ?? 0;
      int weight = int.tryParse(_weightText.value.text) ?? 0;
      int height = int.tryParse(_heightText.value.text) ?? 0;
      String designation = _designationText.value.text;

      UserInfo userInfo = UserInfo();
      userInfo.fullName = name;
      if (_genderValue != null)
        userInfo.gender = _genderValue.toString().split('.').last;
      userInfo.age = age;
      userInfo.weight = weight;
      userInfo.height = height;
      userInfo.designation = designation;
      if (_jobTypeValue != null)
        userInfo.jobType = _jobTypeValue.toString().split('.').last;
      if (conditionValue != conditionItems.first)
        userInfo.condition = conditionValue;

      // Sourav - here you need to save the selected dropdown value (user condition)
      // create another userInfo property for saving the condition.
      // Also don't forget to update the database columns for that new property.
      int userDbId = await DatabaseHelper.instance.addUser(userInfo);
      SharedPref.instance.saveStringValue(SharedPref.keyUserName, name);
      AppCache.instance.userName = name;
      SharedPref.instance.saveIntValue(SharedPref.keyUserDbId, userDbId);
      AppCache.instance.userDbId = userDbId;

      String? userServerId;
      try {
        var userModel = UserApiModel(
            userName: name,
            deviceToken: AppCache.instance.fcmToken,
            score: Random().nextInt(100) + 10);
        userServerId = await ApiManager().registerUser(userModel);
      } on Exception catch (_) {
        print('failed to connect with server');
      }

      if (userServerId != null) {
        SharedPref.instance
            .saveStringValue(SharedPref.keyUserServerId, userServerId);
        AppCache.instance.userServerId = userServerId;
      } else {
        const snackBar = SnackBar(content: Text('Registrierung fehlschlagen'));
        ScaffoldMessenger.of(navigatorKey.currentState!.context)
            .showSnackBar(snackBar);
      }

      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, workingScheduleRoute, (r) => false);
    }
  }

  void _createUserTargets(UserInfo userInfo) {
    int steps = 7500;
    int exercises = 12;
    int waterGlasses = 8;
    int breaks = 8;

    // double bmi;
    // if (userInfo.weight != null && userInfo.weight! > 0 && userInfo.height != null && userInfo.height! > 0) {
    //   bmi = userInfo.weight! / (userInfo.height!/100);
    // }

    if (userInfo.age != null) {
      int age = userInfo.age!;
      String gender = userInfo.gender ?? "Divers";

      if (age > 18 && age < 35) {
        steps = gender == "Mannlich" ? 7500 : 7000;
      } else if (age > 35 && age < 50) {
        steps = gender == "Mannlich" ? 6840 : 6400;
        exercises = 10;
      } else if (age > 50) {
        steps = gender == "Mannlich" ? 5910 : 5750;
        exercises = 8;
      }
    }

    if ((userInfo.jobType ?? "") == "Teilzeit") {
      exercises = exercises ~/ 2;
      waterGlasses = 4;
      breaks = 4;
    }

    _createUserTargets(userInfo);

    DailyTarget dailyTarget = DailyTarget(
        steps: steps,
        exercises: exercises,
        waterGlasses: waterGlasses,
        breaks: breaks);
    SharedPref.instance
        .saveJsonValue(SharedPref.keyUserTargets, dailyTarget.toRawJson());
  }

  double getSmallDiameter(BuildContext context) {
    return MediaQuery.of(context).size.width * 2 / 3;
  }

  double getBigDiameter(BuildContext context) {
    return MediaQuery.of(context).size.width * 7 / 8;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.lightPink,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: Platform.isIOS
              ? SystemUiOverlayStyle.light
              : const SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.light),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 110,
                left: -getSmallDiameter(context) / 3,
                child: Container(
                    width: getSmallDiameter(context),
                    height: getSmallDiameter(context),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.lightOrange,
                    )),
              ),
              Positioned(
                bottom: 50,
                right: -getSmallDiameter(context) / 3,
                child: Container(
                  width: getSmallDiameter(context),
                  height: getSmallDiameter(context),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.lightBlue,
                  ),
                ),
              ),
              // IconButton(
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              //   icon: const Icon(Icons.arrow_back),
              // ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 0),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 70, bottom: 10),
                        child: Text(
                          "userInfoPageTitle!",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.black, fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: CommonUtil.getRectangleBoxDecoration(
                                  Colors.white, 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      'NAME',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.copyWith(fontSize: 16),
                                    ),
                                  ),
                                  TextField(
                                    controller: _nameText,
                                    keyboardType: TextInputType.text,
                                    cursorColor: Colors.orange,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color:
                                                Colors.white12), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color:
                                                Colors.white12), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      fillColor: Colors.grey.shade300,
                                      filled: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 10),
                                    child: Text(
                                      'ALTER',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.copyWith(fontSize: 16),
                                    ),
                                  ),
                                  TextField(
                                    controller: _ageText,
                                    keyboardType: TextInputType.number,
                                    cursorColor: Colors.orange,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color:
                                                Colors.white12), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color:
                                                Colors.white12), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      fillColor: Colors.grey.shade300,
                                      filled: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 10),
                                    child: Text(
                                      'GESCHLECHT',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.copyWith(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: CupertinoSlidingSegmentedControl<
                                        Gender>(
                                      groupValue: _genderValue,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      children: const {
                                        Gender.Mannlich: Text('Männlich'),
                                        Gender.Weiblich: Text('Weiblich'),
                                        Gender.Divers: Text('Divers'),
                                      },
                                      onValueChanged: (groupValue) {
                                        setState(() {
                                          _genderValue = groupValue;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 10),
                                    child: Text(
                                      'Medizinische Beeinträchtigungen'
                                          .toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.copyWith(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    child: DropDownMultiSelect(
                                        //elevation: 10,
                                        //borderRadius: BorderRadius.circular(20.0),
                                        onChanged: (List<String> condition) {
                                          setState(() {
                                            selected = condition;
                                            conditionValue =
                                                condition.join(', ');
                                            print(selected);
                                          });
                                        },
                                        // ignore: prefer_const_literals_to_create_immutables
                                        options: conditionItems,
                                        selectedValues: selected,
                                        whenEmpty: 'Select Something'),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(15),
                              decoration: CommonUtil.getRectangleBoxDecoration(
                                  Colors.white, 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      'GEWICHT (kg)',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.copyWith(fontSize: 16),
                                    ),
                                  ),
                                  TextField(
                                    controller: _weightText,
                                    keyboardType: TextInputType.number,
                                    cursorColor: Colors.orange,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color:
                                                Colors.white12), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color:
                                                Colors.white12), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      fillColor: Colors.grey.shade300,
                                      filled: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 10),
                                    child: Text(
                                      'HEIGHT (cm)',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.copyWith(fontSize: 16),
                                    ),
                                  ),
                                  TextField(
                                    controller: _heightText,
                                    keyboardType: TextInputType.number,
                                    cursorColor: Colors.orange,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color:
                                                Colors.white12), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color:
                                                Colors.white12), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      fillColor: Colors.grey.shade300,
                                      filled: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(15),
                              decoration: CommonUtil.getRectangleBoxDecoration(
                                  Colors.white, 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0, bottom: 10),
                                    child: Text(
                                      'ARBEITSZEITMODELL',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.copyWith(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: CupertinoSlidingSegmentedControl<
                                        JobType>(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      groupValue: _jobTypeValue,
                                      children: const {
                                        JobType.Vollzeit: Text('Vollzeit'),
                                        JobType.Teilzeit: Text('Teilzeit'),
                                        JobType.HomeOffice: Text('Außendienst'),
                                      },
                                      onValueChanged: (groupValue) {
                                        setState(() {
                                          _jobTypeValue = groupValue;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 10),
                                    child: Text(
                                      'BERUFPOSITION',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.copyWith(fontSize: 16),
                                    ),
                                  ),
                                  TextField(
                                    controller: _designationText,
                                    keyboardType: TextInputType.text,
                                    cursorColor: Colors.orange,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color:
                                                Colors.white12), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color:
                                                Colors.white12), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      fillColor: Colors.grey.shade300,
                                      filled: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                        child: TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) =>
                                    Colors.transparent,
                              ),
                              overlayColor:
                                  MaterialStateProperty.all(Colors.transparent),
                            ),
                            onPressed: () {
                              _saveAction();
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
                                  "speichern".toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
