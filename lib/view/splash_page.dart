import 'dart:async';
import 'dart:math';

import 'package:app/main.dart';
import 'package:app/service/task_alert_service.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/task_alert_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    Timer(const Duration(seconds: 3), () {
      _goToNextPage();
    });
  }

  _goToNextPage() async {
    bool isUserExist = await SharedPref.instance.hasValue(SharedPref.keyUserName);
    var userId = await SharedPref.instance.getValue(SharedPref.keyUserDbId);
    if (userId != null && userId is int) {
      AppCache.instance.userDbId = userId;
    }

    if (isUserExist && mounted) {
      final NotificationAppLaunchDetails? notDetails = await TaskAlertService.instance.getNotificationAppLaunchDetails();
      if (notDetails != null && notDetails.didNotificationLaunchApp) {
        print("notificationAppLaunchDetails: $notDetails");
        String payload = notDetails.notificationResponse?.payload ?? "2";
        int taskType = int.tryParse(payload) ?? TaskType.exercise.index;

        print("-------> opening task alert page from _goToNextPage in splash page");
        Navigator.pushNamed(navigatorKey.currentState!.context, taskAlertRoute, arguments: taskType);
      } else {
        Navigator.pushNamedAndRemoveUntil(navigatorKey.currentState!.context, landingRoute, (r) => false);
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(navigatorKey.currentState!.context, userInfoRoute, (r) => false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightPink,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 100,),
          Center(
            child: Image(
              image: const AssetImage("assets/images/transparent_logo.png"),

              width: MediaQuery.of(context).size.width/1.5,
            ),
          ),
          const SizedBox(height: 20,),
          Text('CARDA FIT',
            style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.white, fontSize: 36),
          ),
          const SizedBox(height: 150,),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(DataLoader.quotes[_quoteIndex],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.black87, fontSize: 32, fontWeight: FontWeight.bold, shadows: <Shadow>[
                const Shadow(
                  offset: Offset(5.0, 5.0),
                  blurRadius: 50.0,
                ),
              ])
            ),
          ),
          const SizedBox(height: 15,),
          Text('- ${DataLoader.quotesAuthor[_quoteIndex]}',
            style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.black54, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}