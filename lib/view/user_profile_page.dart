import 'dart:io';
import 'dart:math';

import 'package:app/app.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/widgets/avatar_picker_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_avatar/random_avatar.dart';

import '../api/api_manager.dart';
/* */
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

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

  _loadUserInfo() async {
    UserInfo? userInfo = await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    String? userAvatar = await SharedPref.instance.getValue(SharedPref.keyAvatarImage);
    if (userInfo != null) {
      setState(() {
        _userInfo = userInfo;
        _avatarImage = userAvatar;
      });
    }
  }

  void setSnoozeTime(SnoozeTime snoozeTime) async {
    setState(() {
      _selectedSnoozeTimeVal = snoozeTime;
    });

    await SharedPref.instance.saveIntValue(SharedPref.keySnoozeDuration,
        _selectedSnoozeTimeVal?.duration.inMinutes ?? 0);
    await SharedPref.instance.saveIntValue(
        SharedPref.keySnoozedAt, DateTime.now().millisecondsSinceEpoch);
  }

  void onAvatarSelected(String? avatar) async {
    setState(() {
      _avatarImage = avatar;
    });

    await SharedPref.instance.saveStringValue(SharedPref.keyAvatarImage, avatar!);
    UserInfo? userInfo = await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    if (userInfo != null) {
      userInfo.avatarImage = avatar;
      await DatabaseHelper.instance.updateUser(userInfo, AppCache.instance.userDbId);
    }

    if (_avatarImage != null && _avatarImage!.isNotEmpty) {
      await ApiManager().updateAvatarInfo(AppCache.instance.userServerId, _avatarImage!);
    }
  }

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

  _logoutAction() async {
    SharedPref.instance.clearCache();
    Navigator.pushNamed(context, loginRoute);
    await SharedPref.instance.clearCache();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, loginRoute, (r) => false);
    }
  }

  _editProfileAction() async {
    Navigator.pushNamed(context, editProfileRoute, arguments: true);
  }

  Color transparentOrange = Colors.orange.withOpacity(0);

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
                            right: -10,
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
                              child: Icon(Icons.edit, size: 20),
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(8),
                                primary: Colors.white,
                                elevation: 0,
                              ),
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
                                '(Größe: ${_userInfo?.weight} kg, Gewicht: ${_userInfo?.height} cm)',
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
                            value: _userInfo?.preferredAlerts ??
                                "Nicht ausgewählt",
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 30),
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
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Container(
                            constraints: const BoxConstraints(
                                minHeight:
                                    40), // min sizes for Material buttons
                            alignment: Alignment.center,
                            child: Text(
                              "Abmeldung".toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
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

  // Helper method to build each row in the profile
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
