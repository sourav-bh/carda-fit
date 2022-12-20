import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:app/main.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/util/shared_preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {

  int? _genderValue = 0, _jobTypeValue = 0;
  final Color _underlineColor = const Color(0xFFCCCCCC);
  final TextEditingController _nameText = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _saveAction() {
    var name = _nameText.value.text;
    if (name.isEmpty) {
      // Fluttertoast.showToast(msg: 'Name is mandatory!', toastLength: Toast.LENGTH_SHORT);
    } else {
      SharedPref.instance.saveStringValue(SharedPref.keyUserName, name);
      AppCache.instance.userName = name;
      Navigator.pushNamedAndRemoveUntil(context, homeRoute, (r) => false);
    }
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
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: Platform.isIOS ? SystemUiOverlayStyle.light : const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -getSmallDiameter(context) / 3,
                right: -getSmallDiameter(context) / 3,
                child: Container(
                  width: getSmallDiameter(context),
                  height: getSmallDiameter(context),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [AppColor.secondary, AppColor.lightOrange],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                ),
              ),
              Positioned(
                top: -getBigDiameter(context) / 4,
                left: -getBigDiameter(context) / 4,
                child: Container(
                  width: getBigDiameter(context),
                  height: getBigDiameter(context),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [AppColor.primary, AppColor.primaryLight],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                  child: Center(
                    child: Container(
                        alignment: const Alignment(0.2, 0.2),
                        child: Image.asset('assets/images/transparent_logo.png', height: 120)),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 300, 24, 10),
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextField(
                            controller: _nameText,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[600]!)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _underlineColor),
                                ),
                                labelText: 'Name',
                                labelStyle: TextStyle(color: Colors.grey[700])),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[600]!)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: _underlineColor),
                              ),
                              labelText: 'Alter',
                              labelStyle: TextStyle(color: Colors.grey[700]!),
                              counterText: "",
                            ),
                            maxLength: 3,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text('Geschlecht',
                            style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.black54, fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: CupertinoSlidingSegmentedControl<int>(
                              groupValue: _genderValue,
                              children: const {
                                0: Text('Männlich'),
                                1: Text('Weiblich'),
                                2: Text('Divers'),
                              },
                              onValueChanged: (groupValue) {
                                setState(() {
                                  _genderValue = groupValue;
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text('Arbeitszeitmodell',
                            style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.black54, fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: CupertinoSlidingSegmentedControl<int>(
                              groupValue: _jobTypeValue,
                              children: const{
                                0: Text('Vollzeit'),
                                1: Text('Teilzeit'),
                              },
                              onValueChanged: (groupValue) {
                                setState(() {
                                  _jobTypeValue = groupValue;
                                });
                              },
                            ),
                          ),
                          TextField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[600]!)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _underlineColor),
                                ),
                                labelText: 'Berufposition',
                                labelStyle: TextStyle(color: Colors.grey[700])),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) => Colors.transparent,
                                ),
                                overlayColor: MaterialStateProperty.all(Colors.transparent),
                              ),
                              onPressed: () {
                                _saveAction();
                              },
                              child: Ink(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: <Color>[AppColor.primary, AppColor.primaryLight],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 190, minHeight: 40), // min sizes for Material buttons
                                  alignment: Alignment.center,
                                  child: Text(
                                    "speichern".toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}