import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/view/widgets/user_activity_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UserActivityPage extends StatefulWidget {
  const UserActivityPage({Key? key}) : super(key: key);

  @override
  _UserActivityPageState createState() => _UserActivityPageState();
}

class _UserActivityPageState extends State<UserActivityPage> {

  @override
  void initState() {
    super.initState();
  }

  final double _completedJobs = 14 / 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.lightPink,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/user_activity_banner.jpg",
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitHeight,
              color: AppColor.lightPink,
              colorBlendMode: BlendMode.darken,
              opacity: const AlwaysStoppedAnimation(1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Text("Aktivität heute",
                  style: Theme.of(context).textTheme.caption?.copyWith(color: AppColor.darkBlue, fontSize: 30, fontStyle: FontStyle.normal,)
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserActivityItemView(icon: Icons.directions_walk, title: "Step", subTitle: "3200/7068 km", highlightColor: Colors.purple, shadeColor: Colors.purple.shade100, progressValue: (3200.0/7068.0)),
                  UserActivityItemView(icon: Icons.sports_gymnastics, title: "Exercise", subTitle: "6/10", highlightColor: Colors.orange, shadeColor: Colors.orange.shade100, progressValue: (6.0/10.0)),
                  UserActivityItemView(icon: Icons.local_drink_rounded, title: "Water", subTitle: "4/8 Glass", highlightColor: Colors.lightBlue, shadeColor: Colors.lightBlue.shade100, progressValue: (4.0/8.0)),
                  UserActivityItemView(icon: Icons.timer, title: "Break", subTitle: "3/5", highlightColor: Colors.red, shadeColor: Colors.red.shade100, progressValue: (3.0/5.0)),
                ],
              ),
            ),
          ],
        )
    );
  }
}
