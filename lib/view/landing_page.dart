import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:app/util/app_style.dart';
import 'package:app/view/about_page.dart';
import 'package:app/view/home_page.dart';
import 'package:app/view/leaderboard_page.dart';
import 'package:app/view/learning_details_page.dart';
import 'package:app/view/privacy_policy_page.dart';
import 'package:app/view/user_activity_page.dart';
import 'package:app/view/user_learning_page.dart';
import 'package:app/view/user_profile_page.dart';
// import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  late PageController _pageController;
  int _currentIndex = 0;

  final List<Widget> _contentPages = <Widget>[
    const HomePage(),
    const UserActivityPage(),
    const UserLearningPage(),
    const LeaderBoardPage(),
    const UserProfilePage(),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_handleTabSelection);

    // _startTimer();

    super.initState();
  }

  // _startTimer() {
  //   Timer(Duration(seconds: Random().nextInt(7)), () async {
  //     final downloaderUtils = DownloaderUtils(
  //       progressCallback: (current, total) {
  //         final progress = (current / total) * 100;
  //         print('Downloading: $progress');
  //       },
  //       file: File('path_to_store_file/200MB.zip'),
  //       progress: ProgressImplementation(),
  //       onDone: () => print('Download done'),
  //       deleteOnCancel: true,
  //     );
  //
  //     final core = await Flowder.download(
  //         'http://ipv4.download.thinkbroadband.com/200MB.zip',
  //         downloaderUtils);
  //
  //     core.download('http://ipv4.download.thinkbroadband.com/200MB.zip', downloaderUtils);
  //   });
  // }

  void _handleTabSelection() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.lightPink,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _contentPages.map((Widget content) {
            return content;
          }).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (value) {
            _currentIndex = value;
            _pageController.jumpToPage(value);

            FocusScope.of(context).unfocus();
          },
          selectedFontSize: 8,
          unselectedFontSize: 8,
          iconSize: 28,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
                label: 'Home',
                icon: Icon(
                    Icons.home,
                    color: _currentIndex == 0 ? Colors.orange : Colors.grey
                )
            ),
            BottomNavigationBarItem(
                label: 'Target',
                icon: Icon(
                    Icons.crisis_alert_sharp,
                    color: _currentIndex == 1 ? Colors.orange : Colors.grey
                )
            ),
            BottomNavigationBarItem(
                label: 'Learn',
                icon: Icon(
                    Icons.menu_book,
                    color: _currentIndex == 2 ? Colors.orange : Colors.grey
                )
            ),
            BottomNavigationBarItem(
                label: 'Board',
                icon: Icon(
                    Icons.leaderboard,
                    color: _currentIndex == 3 ? Colors.orange : Colors.grey
                )
            ),
            BottomNavigationBarItem(
                label: 'Profile',
                icon: Icon(
                    Icons.person,
                    color: _currentIndex == 4 ? Colors.orange : Colors.grey
                )
            ),
          ],
        )
    );
  }
}
