import 'dart:io';
import 'dart:math';

import 'package:app/app.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/widgets/avatar_picker_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_avatar/random_avatar.dart';

import '../api/api_manager.dart';

/* Diese Klasse repräsentiert die Benutzerprofilseite in der App.*/
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

// In diesem State werden verschiedene Daten und Logik für die Benutzerprofilseite verwaltet.
class _UserProfilePageState extends State<UserProfilePage> {
  UserInfo? _userInfo;
  String? selectedValue;
  String? _avatarImage;

  SnoozeTime? _selectedSnoozeTimeVal;
  final List<SnoozeTime> _snoozeTimeItems = [
    SnoozeTime(duration: const Duration(minutes: 5), isSelected: false),
    SnoozeTime(duration: const Duration(minutes: 10), isSelected: false),
    SnoozeTime(duration: const Duration(minutes: 30), isSelected: false),
    SnoozeTime(duration: const Duration(hours: 1), isSelected: false),
    SnoozeTime(duration: const Duration(hours: 2), isSelected: false),
    SnoozeTime(duration: const Duration(hours: 3), isSelected: false),
  ];

  @override
  void initState() {
    super.initState();

    _loadUserInfo();
    _checkSnoozeTimeStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

// Eine Methode, die die Benutzerinformationen aus einer Datenbank lädt und den _userInfo-State aktualisiert.
  _loadUserInfo() async {
    UserInfo? userInfo =
        await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);

    if (userInfo != null) {
      setState(() {
        _userInfo = userInfo;
        _avatarImage = userInfo.avatarImage;
      });
    }
    if (_avatarImage != null && _avatarImage!.isNotEmpty) {
      await ApiManager().updateAvatarInfo(_avatarImage!, _avatarImage!);
    }
  }

/* *Diese Funktion nimmt die gewählte Snooze Time auf und übergibt sie und die Uhrzeit, 
   *zu dem genauen Zeitpunkt, als die Snooze Time gewählt wurde, per SharedPreference */
  void setSnoozeTime(SnoozeTime snoozeTime) async {
    setState(() {
      _selectedSnoozeTimeVal = snoozeTime;
    });

    await SharedPref.instance.saveIntValue(SharedPref.keySnoozeDuration,
        _selectedSnoozeTimeVal?.duration.inMinutes ?? 0);
    await SharedPref.instance.saveIntValue(
        SharedPref.keySnoozedAt, DateTime.now().millisecondsSinceEpoch);
  }

// Eine Methode, die aufgerufen wird, wenn der Benutzer ein neues Avatarbild auswählt, und den aktualisierten Avatar-String speichert.
  void onAvatarSelected(String? avatar) async {
    setState(() {
      _avatarImage = avatar;
    });

    await SharedPref.instance
        .saveStringValue(SharedPref.keyAvatarImage, avatar!);
    UserInfo? userInfo =
        await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    if (userInfo != null) {
      userInfo.avatarImage = avatar;
      await DatabaseHelper.instance
          .updateUser(userInfo, AppCache.instance.userDbId);
    }

    if (_avatarImage != null && _avatarImage!.isNotEmpty) {
      await ApiManager()
          .updateAvatarInfo(AppCache.instance.userServerId, _avatarImage!);
    }
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

// Wenn der LogOut Button betätigt wird, wird diese Funktion ausgelöst und der Nutzer zu LogIn Seite geleitet.
  _logoutAction() async {
    SharedPref.instance.clearCache();
    Navigator.pushNamed(context, loginRoute);
    await SharedPref.instance.clearCache();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, loginRoute, (r) => false);
    }
  }

// Wenn der EditProfile Button betätigt wird, wird diese Funktion ausgeführt und der Nutzer zur EditProfile Seite geleitet.
  _editProfileAction() async {
    Navigator.pushNamed(context, editProfileRoute, arguments: true)
        .whenComplete(() {
      _loadUserInfo();
    });
  }

  Color transparentOrange = Colors.orange.withOpacity(0);

// Hier wird mittels Größe und Gewicht der BMI berechnet und zurückgegeben.
  String _getCalculatedBmiValue(int? weight, int? height) {
    if ((weight != null && weight > 0) && (height != null && height > 0)) {
      return ((weight) / pow(((height) / 100), 2)).toStringAsFixed(1);
    } else {
      return '0.0';
    }
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
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _editProfileAction();
                    },
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text('Profil ändern'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(
                  top: (topHeight) - MediaQuery.of(context).size.width / 5.5,
                ),
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: MediaQuery.of(context).size.width / 5.5,
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipOval(
                            child: _avatarImage != null
                                ? RandomAvatar(_avatarImage ?? "")
                                : const Icon(Icons.person_outlined, size: 100),
                          ),
                          Positioned(
                            top: -5,
                            right: -15,
                            child: ElevatedButton(
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AvatarPickerDialog(
                                      selectionCallback: onAvatarSelected,
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(8),
                                backgroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Icon(Icons.edit, size: 20),
                            ),
                          ),
                        ],
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildProfileRow(
                            context: context,
                            icon: Icons.date_range,
                            label: 'Alter:',
                            value: _userInfo?.age != 0
                                ? '${_userInfo?.age} Jahre'
                                : 'Nicht ausgewählt',
                          ),
                          const SizedBox(height: 10),
                          _buildProfileRow(
                            context: context,
                            icon: Icons.male_rounded,
                            label: 'Gender:',
                            value: _userInfo?.gender ?? "Nicht ausgewählt",
                          ),
                          const SizedBox(height: 10),
                          _buildProfileRow(
                            context: context,
                            icon: Icons.line_weight,
                            label: 'BMI:',
                            value:
                                '${_getCalculatedBmiValue(_userInfo?.weight, _userInfo?.height)} '
                                '(Größe: ${_userInfo?.height} cm, Gewicht: ${_userInfo?.weight} kg)',
                          ),
                          const SizedBox(height: 10),
                          _buildProfileRow(
                            context: context,
                            icon: Icons.filter_tilt_shift,
                            label: 'Arbeitsinfo:',
                            value:
                                '${_userInfo?.jobPosition}, ${_userInfo?.jobType}',
                          ),
                          const SizedBox(height: 10),
                          _buildProfileRow(
                            context: context,
                            icon: Icons.work,
                            label: 'Arbeitstage:',
                            value: _userInfo?.workingDays ?? "Nicht ausgewählt",
                          ),
                          const SizedBox(height: 10),
                          _buildProfileRow(
                            context: context,
                            icon: Icons.schedule,
                            label: 'Arbeitszeitplan:',
                            value:
                                '${_userInfo?.workStartTime} - ${_userInfo?.workEndTime}',
                          ),
                          const SizedBox(height: 10),
                          _buildProfileRow(
                            context: context,
                            icon: Icons.medical_services,
                            label: 'Medizinische Daten:',
                            value: _userInfo?.medicalConditions ??
                                "Nicht ausgewählt",
                          ),
                          const SizedBox(height: 10),
                          _buildProfileRow(
                            context: context,
                            icon: Icons.notifications,
                            label: 'Alarme:',
                            value: CommonUtil.convertPreferredAlertNames(
                                _userInfo?.preferredAlerts ??
                                    "Nicht ausgewählt"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildProfileRow(
                              context: context,
                              icon: Icons.snooze,
                              label: 'Snooze-Alarme:',
                              value: _selectedSnoozeTimeVal != null
                                  ? '${_selectedSnoozeTimeVal!.duration.inMinutes} min'
                                  : 'Nicht festgelegt',
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                _showSnoozeTimeSelected(context);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: Icon(
                                  Icons.more_time_outlined,
                                  color: AppColor.primary,
                                ),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            _showFeedbackDialog();
                          },
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) =>
                              Colors.transparent,
                            ),
                            overlayColor: MaterialStateProperty.all(
                                Colors.transparent),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              constraints:
                              const BoxConstraints(minHeight: 40),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.feedback, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    'Rückmeldung',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _logoutActionField(context);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) =>
                              Colors.transparent,
                            ),
                            overlayColor: MaterialStateProperty.all(
                                Colors.transparent),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 40),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    'Abmeldung',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // Hilfsmethode zum Erstellen jeder Zeile im Profil.
  Widget _buildProfileRow(
      {required BuildContext context,
      required IconData icon,
      required String label,
      required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(icon, color: Colors.orangeAccent, size: 20),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        )
      ],
    );
  }

  // Diese Funktion wird aufgerufen, wenn der Benutzer sich abmelden möchte.
  _logoutActionField(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Abmeldung bestätigen'),
          content: const Text('Möchten Sie sich wirklich abmelden?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Schließt den Dialog
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () async {
                // Führt die Abmeldung durch und navigiert zur Login-Seite
                SharedPref.instance.clearCache();
                Navigator.pushNamedAndRemoveUntil(
                    context, loginRoute, (r) => false);
              },
              child: const Text('Abmelden'),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: const Text(
              'Durch Klicken des "Feedback geben" Buttons können Sie Feedback einreichen.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Schließt den Dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog() {
    String feedbackText = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Text('Feedback'),
              const SizedBox(width: 10,),
              InkWell(
                onTap: () {
                  _showInfoDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 1, vertical: 10),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info,
                          color: Colors.orangeAccent),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
          content: TextField(
            maxLines: 3,
            onChanged: (text) {
              feedbackText = text;
            },
            decoration: const InputDecoration(
              hintText: 'Geben Sie Ihr Feedback ein...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                debugPrint(feedbackText);
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () async {
                // UserInfo? userInfo = await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
                String userId = AppCache.instance.userServerId; // Add this line to get the userId
                print(userId);
                // Call the API method to send feedback
                bool success =
                    await ApiManager().sendFeedback(userId, feedbackText);

                if (success && mounted) {
                  Navigator.pop(context); // Close the dialog
                  // Optionally, show a success message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feedback erfolgreich eingereicht!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  // Handle API error or show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Fehler beim Einreichen des Feedbacks. Bitte versuchen Sie es erneut.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Einreichen'),
            ),
          ],
        );
      },
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
