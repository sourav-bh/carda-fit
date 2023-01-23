import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/util/shared_preference.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({Key? key}) : super(key: key);

  @override
  _LeaderBoardPageState createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  final List<LeaderboardParticipantInfo> _participantInfo = List.empty(growable: true);
  final TextEditingController _avatarText = TextEditingController();
  String? _avatarName = "";

  @override
  void initState() {
    super.initState();

    _loadAvatarName();
    _participantInfo.addAll(LeaderboardParticipantInfo.generateDummyList());
  }

  _loadAvatarName() async {
    var avatarName = await SharedPref.instance.getValue(SharedPref.keyUserAvatar);
    if (avatarName != null && avatarName is String) {
      setState(() {
        _avatarName = avatarName;
      });
    }
  }

  Future<bool> _checkIfUserHasAvatar() async {
    var avatarName = await SharedPref.instance.getValue(SharedPref.keyUserAvatar);
    if (avatarName != null && avatarName is String) {
      return avatarName.isNotEmpty;
    } else {
      return false;
    }
  }

  _saveAction() async {
    String avatar = _avatarText.value.text;
    SharedPref.instance.saveStringValue(SharedPref.keyUserAvatar, avatar);

    setState(() {
      _avatarName = avatar;
    });

    UserInfo? userInfo = await DatabaseHelper.instance.getUserInfo(AppCache.instance.userId);
    if (userInfo != null) {
      userInfo.avatar = avatar;
      await DatabaseHelper.instance.updateUser(userInfo, AppCache.instance.userId);
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
      body: FutureBuilder<bool>(
        future: _checkIfUserHasAvatar(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting: return const CircularProgressIndicator();
            default:
              if (snapshot.data ?? false) {
                return Column(
                  children: [
                    const SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                      child: Text('Du hast den 2. Platz erreicht!',
                        style: Theme.of(context).textTheme.caption?.copyWith(color: AppColor.darkBlue, fontSize: 30, fontStyle: FontStyle.normal,),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text('Mit 255 Punkte', style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 20, color: Colors.brown)),
                    const SizedBox(height: 20,),
                    SizedBox(
                      height: 150,
                      child: GridView.extent(
                        padding: const EdgeInsets.all(8),
                        maxCrossAxisExtent: MediaQuery.of(context).size.width/3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
                            decoration: CommonUtil.getRectangleBoxDecoration(Colors.white54, 10),
                            child: CustomPaint(
                              painter: CurvePainter(Colors.green.shade800),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('2', style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                  Text(_avatarName ?? "", style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 24), textAlign: TextAlign.center,),
                                  Text('255', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 24, color: Colors.brown), textAlign: TextAlign.center,),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: CommonUtil.getRectangleBoxDecoration(Colors.white54, 10),
                            child: CustomPaint(
                              painter: CurvePainter(Colors.orange.shade800),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('1', style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                  Text('Toy', style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 24), textAlign: TextAlign.center,),
                                  Text('482', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 24, color: Colors.brown), textAlign: TextAlign.center,),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            decoration: CommonUtil.getRectangleBoxDecoration(Colors.white54, 10),
                            child: CustomPaint(
                              painter: CurvePainter(Colors.blue.shade800),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('3', style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                  Text('Alles', style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 24), textAlign: TextAlign.center,),
                                  Text('210', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 24, color: Colors.brown), textAlign: TextAlign.center,),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _participantInfo.length,
                        itemBuilder: (BuildContext context, int index) {
                          LeaderboardParticipantInfo participant = _participantInfo[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Card(
                                elevation: 5,
                                color: Colors.pink.shade400,
                                child: Container(
                                  decoration: CommonUtil.getRectangleBoxDecoration(Colors.pink.shade400, 15),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(15),
                                          decoration: CommonUtil.getRectangleBoxDecoration(Colors.white.withAlpha(235), 5),
                                          child: Row(
                                            children: [
                                              Text('${index + 4}.', style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 30, color: Colors.brown, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                              const SizedBox(width: 10,),
                                              Text(participant.name, style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 24), textAlign: TextAlign.center,),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Text('${participant.points}',
                                          style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          );
                        },
                      ),
                    )
                  ],
                );
              } else {
                // ask to set a avatar name
                return Column(
                  children: [
                    const SizedBox(height: 50,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                      child: Text('Bitte geben Sie zuerst Ihren Avatarnamen ein, um die Rangliste zu sehen!',
                        style: Theme.of(context).textTheme.caption?.copyWith(color: AppColor.darkBlue, fontSize: 30, fontStyle: FontStyle.normal,),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      padding: const EdgeInsets.all(15),
                      decoration: CommonUtil.getRectangleBoxDecoration(Colors.white, 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _avatarText,
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.orange,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(width: 1, color: Colors.white12), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(width: 1, color: Colors.white12), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              fillColor: Colors.grey.shade300,
                              filled: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                      child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) => Colors.transparent,),
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                          ),
                          onPressed: () {
                            _saveAction();
                          },
                          child: Ink(
                            decoration: const BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 50), // min sizes for Material buttons
                              alignment: Alignment.center,
                              child: Text("speichern".toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          )),
                    ),
                  ],
                );
              }
          }
        },
      )
    );
  }
}
