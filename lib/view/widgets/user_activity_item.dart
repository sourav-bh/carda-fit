import 'package:app/util/common_util.dart';
import 'package:flutter/material.dart';

class UserActivityItemView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;
  final Color highlightColor;
  final Color shadeColor;
  final double progressValue;

  const UserActivityItemView({Key? key,
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.highlightColor,
    required this.shadeColor,
    required this.progressValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.all(15),
      decoration: CommonUtil.getRectangleBoxDecoration(Colors.white70, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            color: shadeColor,
            child: Icon(icon, size: 35, color: highlightColor,),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.subtitle1
                    ),
                    Text(subTitle,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    color: highlightColor.withAlpha(200),
                    backgroundColor: shadeColor,
                    minHeight: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}