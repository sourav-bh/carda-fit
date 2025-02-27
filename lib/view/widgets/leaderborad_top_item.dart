import 'package:app/model/user_info.dart';
import 'package:app/util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

class LeaderboardTopItemView extends StatelessWidget {
  final UserInfo? userInfo;
  final Color badgeColor;
  final int position;
  final double topMargin;

  const LeaderboardTopItemView({Key? key,
    required this.userInfo,
    required this.position,
    required this.topMargin,
    required this.badgeColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      decoration: CommonUtil.getRectangleBoxDecoration(Colors.white54, 10),
      child: CustomPaint(
        painter: CurvePainter(badgeColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('$position', style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            const SizedBox(width: 10,),
            Text(userInfo?.userName ?? "",
              style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w600, fontSize: 20), textAlign: TextAlign.center,
              maxLines: 2,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RandomAvatar(userInfo?.avatarImage ?? "n/a", width: 25, height: 25),
                  Text('${userInfo?.score ?? 0}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20, color: Colors.brown), textAlign: TextAlign.center,),
                ],
              ),
            ),
            const SizedBox(width: 10,),
          ],
        ),
      ),
    );
  }

}