import 'package:app/util/app_style.dart';
import 'package:app/util/data_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({Key? key}) : super(key: key);

  @override
  _LeaderBoardPageState createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  var androidVersions = [
  "Android Cupcake",
  "Android Donut",
  "Android Eclair",
  "Android Froyo",
  "Android Gingerbread",
  "Android Honeycomb",
  "Android Ice Cream Sandwich",
  "Android Jelly Bean",
  "Android Kitkat",
  ];

  final List<LeaderboardParticipantInfo> _participantInfo = List.empty(growable: true);

  @override
  void initState() {
    super.initState();

    _participantInfo.addAll(LeaderboardParticipantInfo.generateDummyList());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: false,
          title: const Text('Leaderboard'),
        ),
        body: Column(
          children: [
            const SizedBox(height: 30,),
            Text('You have ranked 4th!', style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 24),),
            Text('With 195 Points', style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.black45), textAlign: TextAlign.center,),
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
                    padding: const EdgeInsets.all(8),
                    color: AppColor.lightGreen,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('2nd', style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
                        Text('Cynthia', style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 24, color: Colors.white), textAlign: TextAlign.center,),
                        Text('255 Points', style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.black45), textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: AppColor.lightOrange,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('1st', style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
                        Text('Steven', style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 24, color: Colors.white), textAlign: TextAlign.center,),
                        Text('482 Points', style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.black45), textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(8),
                    color: AppColor.lightBlue,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('3rd', style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
                        Text('Alex', style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 24, color: Colors.white), textAlign: TextAlign.center,),
                        Text('210 Points', style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.black45), textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            Text('All Other Participants', style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 18, color: AppColor.darkGrey),),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _participantInfo.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (BuildContext context, int index){
                  return Card(
                    elevation: 5,
                    color: AppColor.placeholderGrey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(_participantInfo[index].name, style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
                        Text('${_participantInfo[index].points} Points', style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.black45), textAlign: TextAlign.center,),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        )
    );
  }
}
