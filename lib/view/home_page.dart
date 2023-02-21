import 'package:app/main.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/data_loader.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<FitnessItemInfo> _dailyFitnessItems = List.empty(growable: true);
  final List<LearningMaterialInfo> _learningMaterials = List.empty(growable: true);

  final double _completedJobs = 0 / 20;

  @override
  void initState() {
    super.initState();

    _dailyFitnessItems.addAll(FitnessItemInfo.generateDummyList());

    // _createRandomAlerts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadLearningContent();
  }

  _loadLearningContent() async {
    if (AppCache.instance.contents.isNotEmpty) {
      var info = await LearningMaterialInfo.copyContentFromLink(AppCache.instance.contents.first);
      setState(() {
        _learningMaterials.add(info);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightPink,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: -10,
            child: Image.asset(
              "assets/images/healthy_day.jpeg",
              height: 180,
              color: AppColor.lightPink,
              colorBlendMode: BlendMode.darken,
              opacity: const AlwaysStoppedAnimation(.5),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ListView(
              children: [
                Visibility(
                  visible: true,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 20, (MediaQuery.of(context).size.width/2)-50, 10),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: DataLoader.quotes[AppCache.instance.quoteIndex],
                                style: Theme.of(context).textTheme.caption?.copyWith(color: AppColor.darkBlue, fontSize: 30, fontStyle: FontStyle.normal,)
                            ),
                            TextSpan(text: '\n ${DataLoader.quotesAuthor[AppCache.instance.quoteIndex]}',
                              style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.black54, fontSize: 16, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  padding: const EdgeInsets.all(15),
                  decoration: CommonUtil.getRectangleBoxDecoration(Colors.white70, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.crisis_alert_rounded, color: Colors.black54,),
                          const SizedBox(width: 10,),
                          const Text("Tagesziele"),
                          const Spacer(),
                          IconButton(onPressed: () {
                            // Navigator.pushNamed(context, taskAlertRoute, arguments: TaskType.steps.index);
                          }, icon: const Icon(Icons.more_horiz),)
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Text("Schritt für Schritt erreichen Sie Ihr Ziel",
                        style: Theme.of(context).textTheme.caption?.copyWith(color: AppColor.darkBlue, fontSize: 20, fontStyle: FontStyle.normal,),
                      ),
                      Text("Sie machen sich heute gut, machen Sie weiter, um Ihre Tagesziele zu erreichen!",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              child: LinearProgressIndicator(
                                value: _completedJobs,
                                color: Colors.pink,
                                backgroundColor: Colors.white,
                                minHeight: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Text("${_completedJobs*100} %",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  padding: const EdgeInsets.all(15),
                  decoration: CommonUtil.getRectangleBoxDecoration(Colors.white70, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.recommend_outlined, color: Colors.black54,),
                          SizedBox(width: 10,),
                          Text("Empfehlungen"),
                          Spacer(),
                          Icon(Icons.more_horiz),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Text("Glaube an die Magie der Regelmäßigkeit, lass sie uns heute rocken",
                        style: Theme.of(context).textTheme.caption?.copyWith(color: AppColor.darkBlue, fontSize: 20, fontStyle: FontStyle.normal,),
                      ),
                      const SizedBox(height: 10,),
                      Container(
                        height: 100,
                        decoration: CommonUtil.getRectangleBoxDecoration(Colors.white12, 10),
                        child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) {
                              FitnessItemInfo item = _dailyFitnessItems[index];
                              return GestureDetector(
                                child: ClipOval(
                                  child: SizedBox.fromSize(
                                    size: const Size.fromRadius(50),
                                    child: Image.asset(
                                      item.image,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  print("-------> opening task alert page from on home page item click");
                                  Navigator.pushNamed(navigatorKey.currentState!.context, taskAlertRoute, arguments: item.taskType.index);
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
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  padding: const EdgeInsets.all(15),
                  decoration: CommonUtil.getRectangleBoxDecoration(Colors.white70, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.menu_book, color: Colors.black54,),
                          SizedBox(width: 10,),
                          Text("Lernmaterialien"),
                          Spacer(),
                          Icon(Icons.more_horiz),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Text("Lernen Sie die Dinge in Ihrem eigenen Tempo, das Leben ist kein Wettlauf",
                        style: Theme.of(context).textTheme.caption?.copyWith(color: AppColor.darkBlue, fontSize: 20, fontStyle: FontStyle.normal,),
                      ),
                      const SizedBox(height: 10,),
                      ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          LearningMaterialInfo material = _learningMaterials[index];
                          return GestureDetector(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.all(10),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      child: Image.network(material.thumbnail ?? "",
                                        fit: BoxFit.fitHeight,
                                      )
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(material.title?.trim() ?? "",
                                          style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 20),
                                          maxLines: 2,
                                        ),
                                        Text(material.description?.trim() ?? "",
                                          style: Theme.of(context).textTheme.bodyText2,
                                          maxLines: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  margin: const EdgeInsets.all(10),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.arrow_forward_ios, color: AppColor.darkBlue, size: 20,),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, detailsWebRoute);
                              // CommonUtil.openUrl(material.videoUrl);
                              // Navigator.pushNamed(context, learningDetailsRoute, arguments: material.description);
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
          ),
        ],
      ),
    );
  }

  void _showPopup(BuildContext context, String image, String quote, String title) {
    // showDialog(context: context, barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return WillPopScope(
    //         onWillPop: () {
    //           return Future.value(false);
    //         },
    //         child: Dialog(
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(24),
    //             ),
    //             backgroundColor: Colors.transparent,
    //             child: NotificationAlertDialog(image, quote, title)
    //         ),
    //       );
    //     }
    // );
  }
}