import 'dart:async';
import 'dart:math';

import 'package:app/main.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/util/shared_preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  var _quoteIndex = 0;

  @override
  void initState() {
    super.initState();

    _quoteIndex = Random().nextInt(DataLoader.quotes.length);
    AppCache.instance.quoteIndex = _quoteIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // go to next page after 3 seconds
    Timer(const Duration(seconds: 5), () {
      _goToNextPage();
    });
  }

  _goToNextPage() async {
    bool isUserExist = await SharedPref.instance.hasValue(SharedPref.keyUserName);
    if (isUserExist && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, homeRoute, (r) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, userInfoRoute, (r) => false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 100,),
          Center(
            child: Image(image: const AssetImage("assets/images/splash_logo.png"),
              width: MediaQuery.of(context).size.width/1.5,
            ),
          ),
          const SizedBox(height: 20,),
          Text('CARDA FIT',
            style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.white, fontSize: 36),
          ),
          const SizedBox(height: 120,),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(DataLoader.quotes[_quoteIndex],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption?.copyWith(color: AppColor.secondary, fontSize: 28, fontStyle: FontStyle.italic, shadows: <Shadow>[
                const Shadow(
                  offset: Offset(5.0, 5.0),
                  blurRadius: 20.0,
                ),
              ])
            ),
          ),
          const SizedBox(height: 15,),
          Text('- ${DataLoader.quotesAuthor[_quoteIndex]}',
            style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.white, fontSize: 16, fontStyle: FontStyle.normal),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}