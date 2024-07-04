import 'package:app/model/trophy.dart';
import 'package:app/model/user_info.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/view/view_models/user_overview_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserOverviewPage extends StatefulWidget {
  const UserOverviewPage({Key? key}) : super(key: key);

  @override
  _UserOverviewPageState createState() => _UserOverviewPageState();
}

class _UserOverviewPageState extends State<UserOverviewPage> {
  late UserOverviewViewModel _overviewViewModel;

  @override
  void initState() {
    _overviewViewModel = UserOverviewViewModel();
    _overviewViewModel.init(context);
    super.initState();
  }

  @override
  void dispose() {
    _overviewViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _overviewViewModel,
      child: Scaffold(
        backgroundColor: AppColor.lightPink,
        body: Selector<UserOverviewViewModel, bool>(
          selector: (_, vm) => vm.loading,
          builder: (context, loading, _) {
            if (loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildUserInfo();
          },
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Selector<UserOverviewViewModel, UserInfo?>(
      selector: (_, vm) => vm.userInfo,
      builder: (context, user, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Übersicht",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColor.darkBlue,
                        fontSize: 28,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 70,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(left: 10, right: 5),
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      height: 70,
                      decoration: CommonUtil.getRectangleBoxDecoration(
                          Colors.white70, 10),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Image(
                              image: AssetImage("assets/images/fire.png"),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                Text(
                                  "${_overviewViewModel.loginCount}",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Flexible(
                                  child: Text(
                                    "Tagesträhne",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(left: 5, right: 10),
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      height: 70,
                      decoration: CommonUtil.getRectangleBoxDecoration(
                          Colors.white70, 10),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Image(
                              image: AssetImage("assets/images/lightning.png"),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                Text(
                                  '${user?.score}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Flexible(
                                  child: Text(
                                    "Punkte",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
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
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 70,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(left: 10, right: 5),
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      height: 70,
                      decoration: CommonUtil.getRectangleBoxDecoration(
                          Colors.white70, 10),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Image(
                              image: AssetImage("assets/images/diamond.png"),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${_overviewViewModel.userLevel?.level ?? 1}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "Level",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(left: 5, right: 10),
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      height: 70,
                      decoration: CommonUtil.getRectangleBoxDecoration(
                          Colors.white70, 10),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Image(
                              image: AssetImage("assets/images/gold_medal.png"),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                Text(
                                  (_overviewViewModel.userLevel?.levelType)
                                          ?.name ??
                                      'none',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Flexible(
                                  child: Text(
                                    "Ranking",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
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
            ),
            const SizedBox(height: 50),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trophäen",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColor.darkBlue,
                        fontSize: 28,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: Trophy.trophies.length,
                itemBuilder: (context, index) {
                  final trophy = Trophy.trophies[index];
                  final bool haveIt =
                      _overviewViewModel.haveTrophies.contains(trophy);
                  return InkWell(
                    onTap: () {
                      if (haveIt) return;
                      checkScoreToHaveTrophy(trophy);
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      height: 90,
                      decoration: CommonUtil.getRectangleBoxDecoration(
                          Colors.white70, 10),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Image.asset(
                                  trophy.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    trophy.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (haveIt)
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                height: 30,
                                width: 100,
                                decoration: BoxDecoration(
                                    color: Colors.yellow.withOpacity(.3)),
                                child: const Center(
                                  child: Text(
                                    "Got it",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void checkScoreToHaveTrophy(Trophy trophy) async {
    var scoreToHave =
        CommonUtil.getScoreToHaveTrophy(trophy, _overviewViewModel.score);
    if (scoreToHave < 0) {
      _showOkDialog(
        context,
        'Du brauchst noch ${scoreToHave.abs()} Punkte, um ${trophy.name} zu bekommen.',
      );
    }
  }

  _showOkDialog(
    BuildContext context,
    String msg, {
    String? titleCancel,
    String? title,
    bool isCancel = false,
    String? titleOK,
    Function()? okAction,
  }) async {
    var actions = [
      CupertinoDialogAction(
        child: Text(
          titleOK ?? 'Bestätigen',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          if (okAction != null) {
            okAction();
          }
        },
      )
    ];
    if (isCancel) {
      actions.add(
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            titleCancel ?? 'Abbrechen',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title ?? 'Tipp'),
        content: Text(msg),
        actions: actions,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserOverviewPage(),
  ));
}