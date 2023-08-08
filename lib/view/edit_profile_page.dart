import 'dart:io';

import 'package:app/api/api_manager.dart';
import 'package:app/main.dart';
import 'package:app/model/user_info.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/task_alert_page.dart';
import 'package:app/view/widgets/avatar_picker_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:random_avatar/random_avatar.dart';

enum EditProfilePageViewState {
  bioInfo,
  workInfo,
  medicalConditionAndAlert,
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  EditProfilePageViewState _viewState = EditProfilePageViewState.bioInfo;

  final TextEditingController _ageText = TextEditingController();
  final TextEditingController _weightText = TextEditingController();
  final TextEditingController _heightText = TextEditingController();
  final TextEditingController _designationText = TextEditingController();

  Gender? _genderValue;
  JobType? _jobTypeValue;
  List<bool> _selectedWeekdays =
      List.filled(CommonUtil.weekdayNames.length, false);
  String? _startTime = '';
  String? _endTime = '';

  final List<String> _conditionItems = [
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
  List<String> _selectedConditions = [];

  final List<TaskType?> _alertTypes = [
    TaskType.breaks,
    TaskType.exercise,
    TaskType.steps,
    TaskType.water
  ];
  List<TaskType> _selectedAlerts = [];
  List<MultiSelectItem<TaskType?>> _items = [];
  bool _isMergeAlertSelected = false;

  @override
  void initState() {
    super.initState();
    _items = _alertTypes
        .map((animal) => MultiSelectItem<TaskType?>(animal, animal?.name ?? ""))
        .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _loadData();
  }

  List<bool> convertStringToListOfBools(String value) {
    return value.split(',').map((item) => item == 'true').toList();
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primaryLight, // header background color
              onPrimary: Colors.black, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.orange, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != TimeOfDay.now()) {
      setState(() {
        _startTime =
            CommonUtil.convert12HourTimeTo24HourFormat(context, pickedTime);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primaryLight, // header background color
              onPrimary: Colors.black, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.orange, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != TimeOfDay.now()) {
      setState(() {
        _endTime =
            CommonUtil.convert12HourTimeTo24HourFormat(context, pickedTime);
      });
    }
  }

  void _nextAction() async {
    if (_viewState == EditProfilePageViewState.bioInfo) {
      _updateViewState(EditProfilePageViewState.workInfo);
    } else if (_viewState == EditProfilePageViewState.workInfo) {
      _updateViewState(EditProfilePageViewState.medicalConditionAndAlert);
    } else if (_viewState ==
        EditProfilePageViewState.medicalConditionAndAlert) {
      _submitAction();
      Navigator.pushNamedAndRemoveUntil(context, profileRoute, (r) => false);
    } else {
      _updateViewState(EditProfilePageViewState.bioInfo);
    }
  }

  void _loadData() async {
    String? userId =
        await SharedPref.instance.getValue(SharedPref.keyUserServerId);

    UserInfo? userRes;
    try {
      userRes = await ApiManager().getUser(userId ?? "");
    } on Exception catch (_) {
      print('failed to connect with server');
    }

    if (mounted) {
      if (userRes != null) {
        _ageText.text = userRes.age.toString();
        if (userRes.gender == "Männlich") {
          _genderValue = Gender.Mannlich;
        } else if (userRes.gender == 'Weiblich') {
          _genderValue = Gender.Weiblich;
        } else if (userRes.gender == 'Divers') {
          _genderValue = Gender.Divers;
        }
        _weightText.text = userRes.weight.toString();
        _heightText.text = userRes.height.toString();
        _designationText.text = userRes.jobPosition ?? '';
        if (userRes.jobType == "Vollzeit") {
          _jobTypeValue = JobType.Vollzeit;
        } else if (userRes.gender == 'Teilzeit') {
          _jobTypeValue = JobType.Teilzeit;
        } else if (userRes.gender == 'Außendienst') {
          _jobTypeValue = JobType.HomeOffice;
        }
        // String? userWorkingDays = userRes.workingDays;
        // if (userWorkingDays != null) {
        //   _selectedWeekdays = convertStringToListOfBools(userWorkingDays);
        // }
        _startTime = userRes.workStartTime.toString();
        _endTime = userRes.workEndTime = toString();
        _selectedConditions =
            userRes.medicalConditions!.replaceAll(" ", "").split(',');
        _selectedAlerts = userRes.preferredAlerts!
            .replaceAll(" ", "")
            .split(',')
            .cast<TaskType>();
        // load values in the text fields and other form elements
        // in userRes.x are the value sto check -> wie schonmal gemacht
      } else {
        const snackBar = SnackBar(content: Text('Daten wurden nicht geladen'));
        ScaffoldMessenger.of(navigatorKey.currentState!.context)
            .showSnackBar(snackBar);
      }
    }
  }

  void _submitAction() async {
    int age = int.tryParse(_ageText.value.text) ?? 0;
    int weight = int.tryParse(_weightText.value.text) ?? 0;
    int height = int.tryParse(_heightText.value.text) ?? 0;
    String designation = _designationText.value.text;

    String conditionValue = "";
    for (String condition in _selectedConditions) {
      conditionValue += condition;
      conditionValue += ', ';
    }

    String? userId =
        await SharedPref.instance.getValue(SharedPref.keyUserServerId);

    var userInfo = UserInfo(
      id: userId,
      age: age,
      gender:
          _genderValue != null ? _genderValue.toString().split('.').last : "",
      weight: weight,
      height: height,
      jobPosition: designation,
      jobType:
          _jobTypeValue != null ? _jobTypeValue.toString().split('.').last : "",
      workingDays: CommonUtil.getWeekDaySelectionStr(_selectedWeekdays),
      workStartTime: _startTime,
      workEndTime: _endTime,
      medicalConditions: conditionValue.isNotEmpty
          ? conditionValue.substring(0, conditionValue.length - 2)
          : "",
      preferredAlerts: CommonUtil.getPreferredAlertStr(_selectedAlerts),
      isMergedAlertSet: _isMergeAlertSelected,
    );

    // Retrieve the existing avatarImage and userName from the previous UserInfo
    String? avatarImage =
        await SharedPref.instance.getValue(SharedPref.keyAvatarImage);
    String? userName =
        await SharedPref.instance.getValue(SharedPref.keyUserName);

    // Set the retrieved values to the new userInfo
    userInfo.avatarImage = avatarImage;
    userInfo.userName = userName;

    int userDbId = await SharedPref.instance.getValue(SharedPref.keyUserDbId);
    DatabaseHelper.instance.updateUser(userInfo, userDbId);

    bool isApiSuccess = false;
    try {
      isApiSuccess = await ApiManager().updateUser(userInfo);
    } on Exception catch (_) {
      print('failed to connect with server');
    }

    if (mounted) {
      if (isApiSuccess) {
        const snackBar = SnackBar(
            content: Text('Das Profil wurde erfolgreich aktualisiert!'));
        ScaffoldMessenger.of(navigatorKey.currentState!.context)
            .showSnackBar(snackBar);
      } else {
        const snackBar =
            SnackBar(content: Text('Profil aktualisieren fehlgeschlagen!'));
        ScaffoldMessenger.of(navigatorKey.currentState!.context)
            .showSnackBar(snackBar);
      }
      Navigator.pushNamedAndRemoveUntil(context, landingRoute, (r) => false);
    }
  }

  void _updateViewState(EditProfilePageViewState viewState) {
    setState(() {
      _viewState = viewState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text('Profil ändern', style: Theme.of(context).textTheme.displayMedium,),
        ),
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
                left: -CommonUtil.getSmallDiameter(context) / 3,
                child: Container(
                    width: CommonUtil.getSmallDiameter(context),
                    height: CommonUtil.getSmallDiameter(context),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.lightOrange,
                    )),
              ),
              Positioned(
                bottom: 50,
                right: -CommonUtil.getSmallDiameter(context) / 3,
                child: Container(
                  width: CommonUtil.getSmallDiameter(context),
                  height: CommonUtil.getSmallDiameter(context),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.lightBlue,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 0),
                    children: <Widget>[
                      buildMainBody(context, _viewState),
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
                              _nextAction();
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
                                  "Weiter".toUpperCase(),
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

  Container buildMainBody(
      BuildContext context, EditProfilePageViewState viewState) {
    if (viewState == EditProfilePageViewState.bioInfo) {
      return buildBioInfoView(context);
    } else if (viewState == EditProfilePageViewState.workInfo) {
      return buildWorkInfoView(context);
    } else if (viewState == EditProfilePageViewState.medicalConditionAndAlert) {
      return buildMedCondAndAlertInfoView(context);
    } else {
      return buildBioInfoView(context);
    }
  }

  Container buildBioInfoView(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(15),
            decoration: CommonUtil.getRectangleBoxDecoration(Colors.white, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Bitte geben Sie unten Ihre biologischen Daten ein\n(optional)',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _ageText,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.orange,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.white12),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.white12),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    fillColor: Colors.grey.shade300,
                    filled: true,
                    labelText: 'Alter',
                    labelStyle: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Geschlecht',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: CupertinoSlidingSegmentedControl<Gender>(
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
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: _weightText,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.orange,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.white12),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.white12),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    fillColor: Colors.grey.shade300,
                    filled: true,
                    labelText: 'Gewicht (kg)',
                    labelStyle: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: _heightText,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.orange,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.white12),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.white12),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    fillColor: Colors.grey.shade300,
                    filled: true,
                    labelText: 'Größe (cm)',
                    labelStyle: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container buildWorkInfoView(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(15),
            decoration: CommonUtil.getRectangleBoxDecoration(Colors.white, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Bitte geben Sie unten Ihre arbeitsbezogenen Informationen und Ihren Wochenplan ein\n(optional)',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _designationText,
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.orange,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.white12),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.white12),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    fillColor: Colors.grey.shade300,
                    filled: true,
                    labelText: 'Berufposition',
                    labelStyle: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: Text(
                    'Arbeitszeitmodell',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: CupertinoSlidingSegmentedControl<JobType>(
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
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: Text(
                    'Arbeitszeitplan',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ToggleButtons(
                        onPressed: (int index) {
                          setState(() {
                            _selectedWeekdays[index] =
                                !_selectedWeekdays[index];
                          });
                        },
                        selectedColor: AppColor.orange,
                        borderRadius: BorderRadius.circular(10),
                        isSelected: _selectedWeekdays,
                        constraints:
                            const BoxConstraints(minWidth: 55, minHeight: 50),
                        children: [
                          for (int i = 1; i <= 5; i++)
                            Text(
                              CommonUtil.weekdayNames[i - 1],
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: Text(
                    'Arbeitszeiten',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CommonUtil.isNullOrEmpty(_startTime)
                          ? 'Startzeit wählen'
                          : 'Startzeit: $_startTime',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500, fontSize: 17),
                    ),
                    IconButton(
                        onPressed: () {
                          _selectStartTime(context);
                        },
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: AppColor.orange,
                          size: 30,
                        ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CommonUtil.isNullOrEmpty(_endTime)
                          ? 'Endzeit wählen'
                          : 'Endzeit: $_endTime',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500, fontSize: 17),
                    ),
                    IconButton(
                        onPressed: () {
                          _selectEndTime(context);
                        },
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: AppColor.orange,
                          size: 30,
                        ))
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container buildMedCondAndAlertInfoView(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(15),
            decoration: CommonUtil.getRectangleBoxDecoration(Colors.white, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Bitte geben Sie unten Ihre medizinischen Bedingungen und die Auswahl der Ausschreibungen\n(optional)',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    'Medizinische Beeinträchtigungen',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16),
                  ),
                ),
                SizedBox(
                  child: MultiSelectDialogField<String>(
                    items: _conditionItems
                        .map((e) => MultiSelectItem(e, e))
                        .toList(),
                    listType: MultiSelectListType.CHIP,
                    onConfirm: (values) {
                      _selectedConditions = values;
                      print(_selectedConditions);
                    },
                    title: const Text("Wählen Sie ein Element"),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(
                        color: Colors.white12,
                        width: 1,
                      ),
                    ),
                    selectedColor: AppColor.orange,
                    buttonText: const Text('Wählen Sie ein Element'),
                    buttonIcon: const Icon(Icons.filter_list),
                    checkColor: AppColor.orange,
                    itemsTextStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16, color: Colors.black),
                    selectedItemsTextStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  child: MultiSelectChipField<TaskType?>(
                    items: _items,
                    title: Text(
                      'Alarme auswählen',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 16),
                    ),
                    headerColor: Colors.white,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    selectedChipColor: AppColor.orange,
                    selectedTextStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16, color: Colors.white),
                    onTap: (values) {
                      _selectedAlerts = values.whereType<TaskType>().toList();
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: MergeSemantics(
                    child: ListTile(
                      title: Text(
                        'Zusammenführen von Alarmen wie Wasser mit Pausen und Schritte mit Bewegung',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      trailing: CupertinoSwitch(
                        value: _isMergeAlertSelected,
                        activeColor: AppColor.primary,
                        thumbColor: Colors.white,
                        trackColor: Colors.black26,
                        onChanged: (bool value) {
                          setState(() {
                            _isMergeAlertSelected = value;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _isMergeAlertSelected = !_isMergeAlertSelected;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
