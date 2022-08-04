import 'dart:async';
import 'dart:math';

import 'package:app/main.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/view/notification_dialog.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<FitnessItemInfo> _dailyFitnessItems = List.empty(growable: true);
  final List<LearningMaterialInfo> _learningMaterials = List.empty(growable: true);

  @override
  void initState() {
    super.initState();

    _dailyFitnessItems.addAll(FitnessItemInfo.generateDummyList());
    _learningMaterials.addAll(LearningMaterialInfo.generateDummyList());

    _createRandomAlerts();
  }

  void _createRandomAlerts() {
    var waterIntervals = List<Duration>.empty(growable: true);
    for (int i=0;i<1;i++) {
      var dur = Duration(seconds: Random().nextInt(300) + 120);
      if (!waterIntervals.contains(dur)) {
        waterIntervals.add(dur);
      }
    }

    for (var interval in waterIntervals) {
      Timer(interval, () => _showPopup(context, 'assets/animations/anim_water.gif', '8 Glass of Water a Day, Keep Doctor Away', 'Drink a glass of water now!'));
    }

    var stepsIntervals = List<Duration>.empty(growable: true);
    for (int i=0;i<2;i++) {
      var dur = Duration(seconds: Random().nextInt(120) + 60);
      if (!stepsIntervals.contains(dur)) {
        stepsIntervals.add(dur);
      }
    }

    for (var interval in stepsIntervals) {
      Timer(interval, () => _showPopup(context, 'assets/animations/anim_steps.gif', 'More Steps You Take, More Healthier You Become', 'Walk for 100 Steps Now!'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          GestureDetector(
            child: const Icon(Icons.account_circle_outlined, color: AppColor.primaryLight, size: 30,),
            onTap: () {
              Navigator.pushNamed(context, profileRoute, arguments: null);
            },
          ),
          const SizedBox(width: 10,),
        ],
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guten Morgen, ${AppCache.instance.userName}', style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20),),
            const SizedBox(height: 5,),
            Text('195 erreichte Punkte', style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54),),
          ],
        ),
        leading: Builder(
            builder: (BuildContext buildContext) {
              return GestureDetector(
                child: Image.asset('assets/images/ic_menu.png'),
                onTap: () => Scaffold.of(buildContext).openDrawer(),
              );
            }
        ),
      ),
      body: ListView(
        children: [
          Visibility(
            visible: true,
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Card(
                  elevation: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColor.secondary.withAlpha(150),
                        ),
                        color: AppColor.secondary.withAlpha(150),
                        borderRadius: const BorderRadius.all(Radius.circular(5))
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(text: DataLoader.quotes[AppCache.instance.quoteIndex],
                                    style: Theme.of(context).textTheme.caption?.copyWith(color: AppColor.darkBlue, fontSize: 18, fontStyle: FontStyle.normal,
                                    )),
                                TextSpan(text: ' - ${DataLoader.quotesAuthor[AppCache.instance.quoteIndex]}',
                                  style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.black54, fontSize: 14, fontStyle: FontStyle.normal),),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10,),
                        GestureDetector(
                          onTap: () {
                            Share.share('${DataLoader.quotes[AppCache.instance.quoteIndex]} - ${DataLoader.quotesAuthor[AppCache.instance.quoteIndex]}');
                          },
                          child: const Icon(Icons.share_rounded, size: 20,)
                        )
                      ],
                    ),
                  )
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tagesziele', style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, color: AppColor.darkGrey),),
                const SizedBox(height: 10,),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        FitnessItemInfo item = _dailyFitnessItems[index];
                        return GestureDetector(
                          child: Card(
                            elevation: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(item.name, style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 20, color: CommonUtil.getFitnessItemBasedColor(item.id))),
                                    Text('${item.count}/${item.target}', style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 14)),
                                  ],
                                ),
                                SizedBox(
                                  width: 120,
                                  height: 80,
                                  child: Image.asset(
                                    item.image,
                                    color: CommonUtil.getFitnessItemBasedColor(item.id),
                                    colorBlendMode: BlendMode.color,
                                  ),
                                ),
                                Text('+${item.points} Punkte', style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16)),
                              ],
                            ),
                          ),
                          onTap: () {
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(endIndent: 15, color: Colors.transparent);
                      },
                      // itemCount: _homeFeed?.popularProducts?.length ?? 0,
                      itemCount: _dailyFitnessItems.length,
                      scrollDirection: Axis.horizontal
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lernen, wie man gesund bleibt', style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, color: AppColor.darkGrey),),
                const SizedBox(height: 10,),
                ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    LearningMaterialInfo material = _learningMaterials[index];
                    return GestureDetector(
                      child: Card(
                        elevation: 5,
                        margin: const EdgeInsets.all(0),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(Radius.circular(5))
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  image: DecorationImage(
                                    image: AssetImage(material.thumbnail),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(material.title, style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 20)),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 30,
                                height: 30,
                                margin: const EdgeInsets.all(10),
                                alignment: Alignment.center,
                                child: Icon(index == 1 ? Icons.arrow_forward_ios : Icons.video_collection_rounded, color: AppColor.darkBlue, size: 20,),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        if (index == 0) {
                          CommonUtil.openUrl(material.videoUrl);
                        } else if (index == 1) {
                          Navigator.pushNamed(context, learningDetailsRoute, arguments: material.description);
                        } else {
                          Navigator.pushNamed(context, detailsWebRoute);
                        }

                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(endIndent: 0, color: Colors.transparent);
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _learningMaterials.length,
                  scrollDirection: Axis.vertical,
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, leaderboardRoute, arguments: null);
        },
        backgroundColor: AppColor.primary,
        // shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: const Icon(Icons.leaderboard_rounded),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColor.primary,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(text: 'Deine Meinung\n',
                      style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 24), children: [
                        TextSpan(
                          text: 'ist uns wichtig',
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 18),
                        ),]
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('Rangliste'),
              horizontalTitleGap: 0,
              leading: const Icon(Icons.leaderboard_outlined, color: AppColor.secondary,),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, leaderboardRoute, arguments: null);
              },
            ),
            ListTile(
              title: const Text('Lernmaterialien'),
              horizontalTitleGap: 0,
              leading: const Icon(Icons.bubble_chart_outlined, color: AppColor.secondary,),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Benachrichtigungen'),
              horizontalTitleGap: 0,
              leading: const Icon(Icons.notifications_none, color: AppColor.secondary,),
              onTap: () {
                Navigator.pop(context);
                _showPopup(context, 'assets/animations/anim_water.gif', '8 Glass of Water a Day, Keep Doctor Away', 'Drink a glass of water now!');
              },
            ),
            ListTile(
              title: const Text('Datenschutz'),
              horizontalTitleGap: 0,
              leading: const Icon(Icons.lock_outline, color: AppColor.secondary,),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, privacyPolicyRoute, arguments: null);
              },
            ),
            ListTile(
              title: const Text('Bedingungen und Konditionen'),
              horizontalTitleGap: 0,
              leading: const Icon(Icons.support_agent_outlined, color: AppColor.secondary,),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, termsConditionsRoute, arguments: null);
              },
            ),
            ListTile(
              title: const Text('Über uns'),
              horizontalTitleGap: 0,
              leading: const Icon(Icons.help_outline, color: AppColor.secondary,),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, aboutUsRoute, arguments: null);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPopup(BuildContext context, String image, String quote, String title) {
    showDialog(context: context, barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: Colors.transparent,
                child: NotificationAlertDialog(image, quote, title)
            ),
          );
        }
    );
  }
}