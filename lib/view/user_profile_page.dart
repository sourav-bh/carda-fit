import 'dart:async';
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
import 'package:random_avatar/random_avatar.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserInfo? _userInfo;
  String? selectedValue;
  bool? isUserSnoozedNow = false;
  Timer? _snoozeTimer;
  int selectedSnoozeTime = 0;
  int? snoozeEndTime; // Speichert das Ende der Snooze-Dauer als Millisekunden seit Epoch

  @override
  void initState() {
    super.initState();
    _loadUserInfo();

    getSnoozeStatus();
    // Start the timer to check snooze status every 1 minute
    _snoozeTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      checkSnoozeStatus();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _snoozeTimer?.cancel();
  }

  void checkSnoozeStatus() async {
    bool? isUserSnoozedNow = await SharedPref.instance.getValue(SharedPref.keyIsSnoozed);
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (isUserSnoozedNow != null && isUserSnoozedNow && currentTime >= snoozeEndTime!) {
      setState(() {
        isUserSnoozedNow = false;
        selectedValue = null;
      });
      // TODO: @Justin -- Add code here to handle resuming notifications.
    }
  }

  _loadUserInfo() async {
    UserInfo? userInfo = await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    if (userInfo != null) {
      setState(() {
        _userInfo = userInfo;
      });
    }
  }
    
  int extractNumbersAndCombine(String selectedValue) {
    int selectedSnoozeTime = 0;
    String currentNumber = '';

    for (int i = 0; i < selectedValue.length; i++) {
      if (selectedValue[i].contains(RegExp(r'[0-9]'))) {
        currentNumber += selectedValue[i];
      } else {
        if (currentNumber.isNotEmpty) {
          int num = int.tryParse(currentNumber) ?? 0;
          selectedSnoozeTime = selectedSnoozeTime * 10 + num;
          currentNumber = '';
        }
      }
    }

    if (currentNumber.isNotEmpty) {
      int num = int.tryParse(currentNumber) ?? 0;
      selectedSnoozeTime = selectedSnoozeTime * 10 + num;
    }

    return selectedSnoozeTime;
  }

  _saveSnoozeTime() async {
    await SharedPref.instance.saveStringValue(SharedPref.keySnoozeDuration, selectedValue!);
    await SharedPref.instance.saveIntValue(SharedPref.keySnoozeActualTime, DateTime.now().millisecondsSinceEpoch);
  }

  // List of times that can be selected for snooze the notifications
  List<String> items = <String>['5 min', '10 min', '30 min', '60 min', '120 min', '1440 min'];

  // Get the snooze status from SharedPref
  Future<void> getSnoozeStatus() async {
    bool? isUserSnoozedNow = await SharedPref.instance.getValue(SharedPref.keyIsSnoozed);
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (isUserSnoozedNow != null && isUserSnoozedNow) {
      setState(() {
        selectedValue = "Benachrichtigungen sind stummgeschaltet";
      });
    }
  }

  _logoutAction() async {
    await SharedPref.instance.clearCache();
    Navigator.pushNamedAndRemoveUntil(context, loginRoute, (r) => false);
  }

  _editProfileAction() async {
    Navigator.pushNamed(context, editProfileRoute, arguments: true);
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
                          'Nutzername: ',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.copyWith(fontSize: 18),
                        ),
                        Text(
                          _userInfo?.userName ?? "Nicht ausgewählt",
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
                                _userInfo?.medicalConditions ?? "Nicht ausgewählt",
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
                                  _userInfo?.jobPosition ?? "Nicht ausgewählt",
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
                      child: DropdownButton<String>(
                        hint: const Text('Pausieren Sie die Benachrichtigungen'),
                        dropdownColor: Colors.grey,
                        icon: const Icon(Icons.arrow_drop_down),
                        value: selectedValue,
                        onChanged: (newValue) {
                          setState(() {
                            selectedValue = newValue;
                            selectedSnoozeTime = extractNumbersAndCombine(newValue!);
                            snoozeEndTime = DateTime.now().millisecondsSinceEpoch + (selectedSnoozeTime * 60000);
                            _saveSnoozeTime();
                            isUserSnoozedNow = true;
                          });
                        },
                        items: items.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
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
                            _editProfileAction();
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