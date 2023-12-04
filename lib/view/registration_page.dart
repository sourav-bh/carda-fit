import 'dart:io';

import 'package:app/api/api_manager.dart';
import 'package:app/app.dart';
import 'package:app/model/task_alert.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/widgets/avatar_picker_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:random_avatar/random_avatar.dart';

// Ein Enum zur Darstellung der verschiedenen Ansichtszustände der Registrierungsseite, wie "Mandatory Info", "Optional Bio Info" usw.
enum RegisterPageViewState {
  mandatoryInfo,
  optionalOneBioInfo,
  optionalTwoWorkInfo,
  optionalThreeConditionAlert,
  allInfoToSubmit,
}

//**Diese Klasse stellt die Hauptseite der Registrierung dar.
//Sie enthält verschiedene Formularelemente und Schritte für die Registrierung. */
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

//**Dies ist der zugehörige State für die RegistrationPage.
//Hier werden die Logik und die Zustände für die Registrierung verwaltet. */
class _RegistrationPageState extends State<RegistrationPage> {
  final _mandatoryFormKey = GlobalKey<FormState>();
  final _alertTypeFormKey = GlobalKey<FormState>();
  RegisterPageViewState _viewState = RegisterPageViewState.mandatoryInfo;

  final TextEditingController _userNameText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();
  final TextEditingController _confirmPasswordText = TextEditingController();

  final TextEditingController _ageText = TextEditingController();
  final TextEditingController _weightText = TextEditingController();
  final TextEditingController _heightText = TextEditingController();
  final TextEditingController _designationText = TextEditingController();
  final TextEditingController _keywordAPI = TextEditingController();

  Gender? _genderValue;
  WalkingSpeed? _walkingSpeedValue = WalkingSpeed.medium;
  JobType? _jobTypeValue;
  String? _avatarImage;
  List<String> keywords = [];
  List<String> apiResults = [];

  bool _obscureText = true, _confirmObscureText = true;
  IconData _iconVisible = Icons.visibility_off;

  IconData _confirmIconVisible = Icons.visibility_off;
  final List<bool> _selectedWeekdays =
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

  List<MultiSelectItem<TaskType?>> _items = [];
  final List<TaskType?> _alertTypes = [
    TaskType.breaks,
    TaskType.exercise,
    TaskType.steps,
    TaskType.water,
    TaskType.walkWithExercise,
    TaskType.waterWithBreak
  ];
  List<TaskType> _selectedAlerts = [];

  int _stepIndex = 0;
  String _nextButtonText = "Weiter";

  @override
  void initState() {
    super.initState();

    _items = _alertTypes
        .map((alertType) => MultiSelectItem<TaskType?>(
            alertType, CommonUtil.getTaskAlertName(alertType)))
        .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

//**Diese Funktion wird aufgerufen, wenn auf den "Weiter"-Button geklickt wird. Sie steuert den Fortschritt des Registrierungsprozesses,
// indem sie je nach aktuellem Zustand des Registrierungsformulars zur nächsten Ansicht wechselt oder die Registrierung abschließt. */
  void _nextAction() async {
    if (_viewState == RegisterPageViewState.mandatoryInfo) {
      if (_mandatoryFormKey.currentState!.validate()) {
        if (await _checkUserNameAvailability()) {
          _updateViewState(RegisterPageViewState.optionalOneBioInfo, 1);
        } else {
          // show error that username is not available
          const snackBar =
              SnackBar(content: Text('Der Nutzername ist bereits vergeben!'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } else if (_viewState == RegisterPageViewState.optionalOneBioInfo) {
      _updateViewState(RegisterPageViewState.optionalTwoWorkInfo, 2);
    } else if (_viewState == RegisterPageViewState.optionalTwoWorkInfo) {
      _updateViewState(RegisterPageViewState.optionalThreeConditionAlert, 3);
      // update button text to Registrieren
      setState(() {
        _nextButtonText = "Registrieren";
      });
    } else if (_viewState ==
        RegisterPageViewState.optionalThreeConditionAlert) {
      // _updateViewState(RegisterPageViewState.allInfoToSubmit);
      if (_alertTypeFormKey.currentState!.validate()) {
        _submitAction();
      }
    } else if (_viewState == RegisterPageViewState.allInfoToSubmit) {
      // submit values for registration to server
      // not being used right now
    }
  }

//** Diese Funktion überprüft die Verfügbarkeit eines Benutzernamens, indem sie eine Anfrage an den Server sendet,
// um sicherzustellen, dass der Benutzername eindeutig ist. */
  Future<bool> _checkUserNameAvailability() async {
    String userName = _userNameText.value.text;
    return await ApiManager().checkIfUserNameAvailable(userName);
  }

//** Diese Funktion wird aufgerufen, wenn der Benutzer auf den "Registrieren"-Button klickt.
// Sie sammelt die eingegebenen Informationen und sendet sie an den Server, um den Registrierungsprozess abzuschließen. */
  void _submitAction() async {
    String userName = _userNameText.value.text;
    String password = _passwordText.value.text;
    int age = int.tryParse(_ageText.value.text) ?? 0;
    int weight = int.tryParse(_weightText.value.text) ?? 0;
    int height = int.tryParse(_heightText.value.text) ?? 0;
    String designation = _designationText.value.text;

    String conditionValue = "";
    for (String condition in _selectedConditions) {
      conditionValue += condition;
      conditionValue += ', ';
    }

    var userInfo = UserInfo(
      userName: userName,
      password: password,
      avatarImage: _avatarImage,
      age: age,
      gender:
          _genderValue != null ? _genderValue.toString().split('.').last : "",
      weight: weight,
      height: height,
      walkingSpeed: _walkingSpeedValue.toString().split('.').last,
      teamName: AppConstant.teamNameForCustomBuild,
      score: 0,
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
      deviceToken: AppCache.instance.fcmToken,
    );

    int userDbId = await DatabaseHelper.instance.addUser(userInfo);
    SharedPref.instance.saveStringValue(SharedPref.keyUserName, userName);
    AppCache.instance.userName = userName;
    SharedPref.instance.saveIntValue(SharedPref.keyUserDbId, userDbId);
    AppCache.instance.userDbId = userDbId;

    String? userServerId;
    try {
      userServerId = await ApiManager().registerUser(userInfo);
    } on Exception catch (_) {
      print('failed to connect with server');
    }

    if (mounted) {
      if (userServerId != null) {
        SharedPref.instance
            .saveStringValue(SharedPref.keyUserServerId, userServerId);
        AppCache.instance.userServerId = userServerId;
        CommonUtil.createUserTargets(userInfo);
      } else {
        const snackBar = SnackBar(content: Text('Registrierung fehlgeschlagen'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      Navigator.pushNamedAndRemoveUntil(context, landingRoute, (r) => false);
    }
  }

//** */
  void _addToKeywords() async{
    setState(() {
      String text = _keywordAPI.text.trim();
      if (text.isNotEmpty) {
        keywords.add(text);
        _keywordAPI.clear();
      }
    });
    await _fetchDataFromAPI();
  }


  Future<void> _fetchDataFromAPI() async {
    for (String keyword in keywords) {
      // Verwende die neue Methode, um Daten von der API abzurufen
      String result = await fetchDataForKeyword(keyword);
      setState(() {
        apiResults.add(result);
        print(result);
      });
    }
  }

//**Diese Funktion ändert den Anzeigemodus des Passwortfelds zwischen verdecktem Text und sichtbarem Text.
// Sie wird aufgerufen, wenn der Benutzer auf das "Sichtbarkeits"-Symbol im Passwortfeld klickt. */
  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      if (_obscureText == true) {
        _iconVisible = Icons.visibility_off;
      } else {
        _iconVisible = Icons.visibility;
      }
    });
  }

//**Genau wie _toggleObscureText() ändert diese Funktion den Anzeigemodus des Bestätigungspasswortfelds
// zwischen verdecktem Text und sichtbarem Text. Der einzige Unterschied ist, dass diese Methode, dann aufgerufen wird,
// wenn das klicken auf das Sichtbarkeits-Symbol erfolgt ist. Erst dann wird das Passwort aufgedeckt. */
  void _toggleConfirmObscureText() {
    setState(() {
      _confirmObscureText = !_confirmObscureText;
      if (_confirmObscureText == true) {
        _confirmIconVisible = Icons.visibility_off;
      } else {
        _confirmIconVisible = Icons.visibility;
      }
    });
  }

// Diese Funktion zeigt einen Zeitwahl-Dialog an, wenn der Benutzer auf das Startzeit-Feld klickt, und aktualisiert die ausgewählte Startzeit.
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primaryLight, // header Hintergrundfarbe
              onPrimary: Colors.black, // header Textfarbe
              onSurface: Colors.black, // body Textfarbe
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.orange, // Button Textfarbe
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

//Diese Funktion zeigt einen Zeitwahl-Dialog an, wenn der Benutzer auf das Endzeit-Feld klickt, und aktualisiert die ausgewählte Endzeit.
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primaryLight, // header Hintergrundfarbe
              onPrimary: Colors.black, // header Textfarbe
              onSurface: Colors.black, // body Textfarbe
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.orange, // Button Textfarbe
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

//**  Diese Funktion aktualisiert den aktuellen Registrierungszustand
//(wie "Mandatory Info" oder "Optional Bio Info") und den Anzeigeindex des Fortschrittsbalkens. */
  void _updateViewState(RegisterPageViewState viewState, int viewIndex) {
    setState(() {
      _viewState = viewState;
      _stepIndex = viewIndex;
    });
  }

//**Diese Funktion wird aufgerufen, wenn der Benutzer ein Avatar-Bild auswählt.
// Sie aktualisiert das ausgewählte Avatar-Bild im Registrierungsformular. */
  void onAvatarSelected(String? avatar) {
    setState(() {
      _avatarImage = avatar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Registrierung',
            style: Theme.of(context).textTheme.displayMedium,
          ),
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
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 0),
                    children: <Widget>[
                      buildStepper(context),
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
                                  _nextButtonText.toUpperCase(),
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

  Widget buildMainBody(BuildContext context, RegisterPageViewState viewState) {
    if (viewState == RegisterPageViewState.mandatoryInfo) {
      return buildMandatoryInfoView(context);
    } else if (viewState == RegisterPageViewState.optionalOneBioInfo) {
      return buildOptional1BioInfoView(context);
    } else if (viewState == RegisterPageViewState.optionalTwoWorkInfo) {
      return buildOptional2WorkInfoView(context);
    } else if (viewState == RegisterPageViewState.optionalThreeConditionAlert) {
      return buildOptional3CondAlertInfoView(context);
    } else if (viewState == RegisterPageViewState.allInfoToSubmit) {
      return buildAllInfoSubmitView(context);
    } else {
      return buildMandatoryInfoView(context);
    }
  }

  Widget buildMandatoryInfoView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(15),
            decoration: CommonUtil.getRectangleBoxDecoration(Colors.white, 25),
            child: Form(
              key: _mandatoryFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Bitte geben Sie Ihren eindeutigen Nutzername ein und legen Sie Ihr Passwort unten fest',
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
                  TextFormField(
                      controller: _userNameText,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.orange,
                      style: Theme.of(context).textTheme.bodyLarge,
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
                        labelText: 'Nutzername',
                        labelStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? false) {
                          return 'Nutzername ist erforderlich.';
                        } else if ((value?.length ?? 0) < 5) {
                          return 'Muss mindestens 5 Zeichen lang sein.';
                        } else if ((value?.length ?? 0) > 8) {
                          return 'Darf maximal 8 Zeichen lang sein.';
                        } else if ((value ?? "").contains(' ')) {
                          return 'Darf keine Leerzeichen enthalten.';
                        } else {
                          return null;
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextButton(
                            style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(
                                    Colors.white),
                                backgroundColor: MaterialStateProperty.all<
                                    Color>(AppColor.primary),
                                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                    const EdgeInsets.fromLTRB(30, 10, 30, 10)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    const RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(15)),
                                        side: BorderSide(color: AppColor.primary)))),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AvatarPickerDialog(
                                    selectionCallback: onAvatarSelected,
                                  );
                                },
                              );
                            },
                            child: Text(
                              "Avatar wählen",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _avatarImage != null,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: RandomAvatar(_avatarImage ?? "",
                              height: 50, width: 50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _passwordText,
                    obscureText: _obscureText,
                    cursorColor: Colors.orange,
                    style: Theme.of(context).textTheme.bodyLarge,
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
                      labelText: 'Passwort',
                      labelStyle: Theme.of(context).textTheme.bodyLarge,
                      suffixIcon: IconButton(
                          icon: Icon(_iconVisible,
                              color: Colors.grey[400], size: 20),
                          onPressed: () {
                            _toggleObscureText();
                          }),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? false) {
                        return 'Passwort ist erforderlich.';
                      } else if ((value?.length ?? 0) < 8) {
                        return 'Muss mindestens 8 Zeichen lang sein.';
                      } else if ((value?.length ?? 0) > 14) {
                        return 'Darf maximal 14 Zeichen lang sein.';
                      } else if ((value ?? "").contains(' ')) {
                        return 'Darf keine Leerzeichen enthalten.';
                      } else {
                        return null;
                      }
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _confirmPasswordText,
                    obscureText: _confirmObscureText,
                    cursorColor: Colors.orange,
                    style: Theme.of(context).textTheme.bodyLarge,
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
                      labelText: 'Passwort bestätigen',
                      labelStyle: Theme.of(context).textTheme.bodyLarge,
                      suffixIcon: IconButton(
                          icon: Icon(_confirmIconVisible,
                              color: Colors.grey[400], size: 20),
                          onPressed: () {
                            _toggleConfirmObscureText();
                          }),
                    ),
                    validator: (value) {
                      if (value != _passwordText.text) {
                        return 'Passwort nicht übereinstimmend!';
                      } else {
                        return null;
                      }
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOptional1BioInfoView(BuildContext context) {
    return Container(
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Lauf-Tempo',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: CupertinoSlidingSegmentedControl<WalkingSpeed>(
                    groupValue: _walkingSpeedValue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    children: const {
                      WalkingSpeed.fast: Text('Schnell'),
                      WalkingSpeed.medium: Text('Mittel'),
                      WalkingSpeed.slow: Text('Langsam'),
                    },
                    onValueChanged: (groupValue) {
                      setState(() {
                        _walkingSpeedValue = groupValue;
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

  Widget buildOptional2WorkInfoView(BuildContext context) {
    return Container(
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

  Widget buildOptional3CondAlertInfoView(BuildContext context) {
    return Container(
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
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    'weitere Beeinträchtigungen',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _keywordAPI,
                        onSubmitted: (value) => _addToKeywords(),
                        decoration: InputDecoration(
                          hintText: 'Geben Sie die Beeinträchtigung ein',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: _addToKeywords, 
                                    
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50, // Höhe des Scrollbereichs anpassen
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: keywords.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(keywords[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  child: Form(
                    key: _alertTypeFormKey,
                    child: MultiSelectChipField<TaskType?>(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      scroll: false,
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      selectedChipColor: AppColor.orange,
                      validator: (values) {
                        if ((((values?.contains(TaskType.breaks) ?? false) ||
                                    (values?.contains(TaskType.water) ??
                                        false)) &&
                                (values?.contains(TaskType.waterWithBreak) ??
                                    false)) ||
                            (((values?.contains(TaskType.steps) ?? false) ||
                                    (values?.contains(TaskType.exercise) ??
                                        false)) &&
                                (values?.contains(TaskType.walkWithExercise) ??
                                    false))) {
                          return "* Einzelne u. kombinierte dürfen nicht gewählt";
                        }
                      },
                      selectedTextStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 16, color: Colors.white),
                      onTap: (values) {
                        _selectedAlerts = values.whereType<TaskType>().toList();
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

  Widget buildAllInfoSubmitView(BuildContext context) {
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
                    'Bitte bestätigen Sie alle eingegebenen Informationen und klicken Sie auf die Schaltfläche "Senden", um ein Konto zu erstellen.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStepper(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: 120.0),
      child: Theme(
        data: ThemeData(
          canvasColor: Colors.transparent,
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColor.orange,
                background: Colors.red,
                secondary: Colors.green,
              ),
        ),
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _stepIndex,
          elevation: 0,
          controlsBuilder: (BuildContext context, ControlsDetails controls) {
            return const SizedBox.shrink();
          },
          steps: <Step>[
            Step(
              title: const Text(''),
              label: const Text(
                'Nutzername',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              content: const SizedBox(),
              isActive: _stepIndex >= 0,
            ),
            Step(
              title: const Text(''),
              label: const Text(
                'Persönlich',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              content: const SizedBox(),
              isActive: _stepIndex >= 1,
            ),
            Step(
              title: const SizedBox(),
              label: const Text(
                'Arbeits',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              content: const SizedBox(),
              isActive: _stepIndex >= 2,
            ),
            Step(
              title: const Text(''),
              label: const Text(
                'Präferenz',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              content: const SizedBox(),
              isActive: _stepIndex >= 3,
            ),
          ],
        ),
      ),
    );
  }
}
