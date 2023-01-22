import 'dart:io';

import 'package:app/main.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/shared_preference.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {

  @override
  void initState() {
    super.initState();
  }

  _logoutAction() async {
    SharedPref.instance.clearCache();
    Navigator.pushNamed(context, userInfoRoute);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double topHeight = MediaQuery.of(context).size.height / 4;
    if(kIsWeb){
      topHeight = MediaQuery.of(context).size.height / 2.5;
    }
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Platform.isIOS ? SystemUiOverlayStyle.light : const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light
        ),
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
                        end: Alignment.bottomCenter)
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(
                    top: (topHeight) -
                        MediaQuery.of(context).size.width / 5.5),
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: MediaQuery.of(context).size.width / 5.5,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: (MediaQuery.of(context).size.width / 5.5) - 4,
                        child: const ClipOval(
                            child: Icon(Icons.person_outlined, size: 100,)
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Don',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 24),
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
                              const Icon(Icons.person_pin_rounded, color: Colors.orangeAccent, size: 25),
                              const SizedBox(width: 10,),
                              Text('Robert Steven',
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 20),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.male_rounded, color: Colors.orangeAccent, size: 25),
                              const SizedBox(width: 10,),
                              Text('Männlich',
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 20),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.date_range, color: Colors.orangeAccent, size: 25),
                              const SizedBox(width: 10,),
                              Text('30 Jahre',
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 20),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.filter_tilt_shift, color: Colors.orangeAccent, size: 25),
                              const SizedBox(width: 10,),
                              Text('Vollzeit',
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 20),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.design_services, color: Colors.orangeAccent, size: 25),
                              const SizedBox(width: 10,),
                              Expanded(
                                child: Text('Leitender Vertriebsmitarbeiter',
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 20),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50,),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                      child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) => Colors.transparent,),
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
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
                              constraints: const BoxConstraints(minHeight: 50), // min sizes for Material buttons
                              alignment: Alignment.center,
                              child: Text("Abmeldung".toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
