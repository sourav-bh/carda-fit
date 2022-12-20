import 'dart:io';

import 'package:app/util/app_style.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Color _color1 = const Color(0xFF0181cc);
  Color _color2 = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
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
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                height: topHeight,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppColor.primary, AppColor.primaryLight],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        )
                    ),
                  ],
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
                    Container(
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.only(top: 48),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.person_pin_rounded, color: _color1, size: 20),
                              const SizedBox(width: 20,),
                              Flexible(child:
                                Text('Robert Steven', style: TextStyle(
                                  fontSize: 16, color: _color2, fontWeight: FontWeight.w600
                                ))
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.man_rounded, color: _color1, size: 20),
                              const SizedBox(width: 20,),
                              Flexible(child:
                                Text('Male', style: TextStyle(
                                  fontSize: 16, color: _color2, fontWeight: FontWeight.w600
                                ))
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.date_range, color: _color1, size: 20),
                              const SizedBox(width: 20,),
                              Flexible(child:
                                Text('30 Years', style: TextStyle(
                                  fontSize: 16, color: _color2, fontWeight: FontWeight.w600
                                ))
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.filter_tilt_shift, color: _color1, size: 20),
                              const SizedBox(width: 20,),
                              Flexible(child:
                              Text('Full-time Worker', style: TextStyle(
                                  fontSize: 16, color: _color2, fontWeight: FontWeight.w600
                              ))
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.perm_identity, color: _color1, size: 20),
                              const SizedBox(width: 20,),
                              Flexible(child:
                              Text('Senior Sales Executive', style: TextStyle(
                                  fontSize: 16, color: _color2, fontWeight: FontWeight.w600
                              ))
                              )
                            ],
                          ),
                        ],
                      ),
                    )
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
