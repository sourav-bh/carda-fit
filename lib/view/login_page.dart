import 'dart:io';

import 'package:app/api/api_manager.dart';
import 'package:app/app.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/shared_preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Diese Klasse repräsentiert die Anmeldeseite der App.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

//Diese Klasse verwaltet die Zustände und Logik der Login-Page.
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userNameText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();

  bool _obscureText = true;
  IconData _iconVisible = Icons.visibility_off;

//**Diese Funktion wird aufgerufen, wenn der Benutzer auf das Sichtbarkeits-Symbol im Passwortfeld klickt.
// Sie ändert den Sichtbarkeitsstatus des Passwortfelds und aktualisiert das Symbol entsprechend. */
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

  @override
  void initState() {
    super.initState();

    // CommonUtil.testApi();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

//**Diese Funktion wird aufgerufen, wenn der Benutzer auf den Anmelde-Button klickt.
// Sie liest den eingegebenen Benutzernamen und das Passwort aus den Controllern aus und versucht dann,
// den Benutzer über die ApiManager().loginUser()-Methode anzumelden.
//Wenn die Anmeldung erfolgreich ist, wird ein UserInfo-Objekt zurückgegeben, das Informationen zum angemeldeten Benutzer enthält.
//Wenn ein Fehler bei der Verbindung mit dem Server auftritt, wird eine Fehlermeldung ausgegeben. */
  void _loginAction() async {
    String userName = _userNameText.value.text;
    String password = _passwordText.value.text;

    UserInfo? userRes;
    try {
      userRes = await ApiManager().loginUser(userName, password);
    } on Exception catch (_) {
      print('failed to connect with server');
    }

    if (userRes != null) {
      int userDbId = await DatabaseHelper.instance.addUser(userRes);
      SharedPref.instance.saveStringValue(SharedPref.keyUserName, userName);
      AppCache.instance.userName = userName;

      SharedPref.instance.saveIntValue(SharedPref.keyUserDbId, userDbId);
      AppCache.instance.userDbId = userDbId;

      SharedPref.instance
          .saveStringValue(SharedPref.keyUserServerId, userRes.id!);
      AppCache.instance.userServerId = userRes.id!;

      CommonUtil.createUserTargets(userRes);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, landingRoute, (r) => false);
      }
    } else if (mounted) {
      const snackBar = SnackBar(content: Text('Login fehlgeschlagen'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
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
                      Padding(
                        padding: const EdgeInsets.only(top: 100, bottom: 10),
                        child: Text(
                          'Anmeldung',
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 30),
                              decoration: CommonUtil.getRectangleBoxDecoration(
                                  Colors.white, 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      'Geben Sie Ihren Nutzernamen und Ihr Passwort ein, um sich anzumelden',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.copyWith(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  TextFormField(
                                    controller: _userNameText,
                                    keyboardType: TextInputType.text,
                                    cursorColor: Colors.orange,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.white12),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.white12),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      fillColor: Colors.grey.shade300,
                                      filled: true,
                                      labelText: 'Nutzername',
                                      labelStyle:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    validator: (value) {
                                      if (value?.isEmpty ?? false) {
                                        return 'Nutzername ist erforderlich.';
                                      } else if ((value?.length ?? 0) < 5) {
                                        return 'Nutzername muss mindestens 5 Zeichen lang sein.';
                                      } else if ((value?.length ?? 0) > 15) {
                                        return 'Nutzername darf maximal 15 Zeichen lang sein.';
                                      } else if ((value ?? "").contains(' ')) {
                                        return 'Nutzername darf keine Leerzeichen enthalten.';
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextField(
                                    controller: _passwordText,
                                    obscureText: _obscureText,
                                    cursorColor: Colors.orange,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.white12),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.white12),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      fillColor: Colors.grey.shade300,
                                      filled: true,
                                      labelText: 'Passwort',
                                      labelStyle:
                                          Theme.of(context).textTheme.bodyLarge,
                                      suffixIcon: IconButton(
                                          icon: Icon(_iconVisible,
                                              color: Colors.grey[400],
                                              size: 20),
                                          onPressed: () {
                                            _toggleObscureText();
                                          }),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Visibility(
                                    visible: false,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: const Text(
                                        "Passwort vergessen?",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                              child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) =>
                                          Colors.transparent,
                                    ),
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  onPressed: () {
                                    _loginAction();
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
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sie haben noch kein Konto?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, registerRoute);
                                    },
                                    child: Text('Hier registrieren',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
