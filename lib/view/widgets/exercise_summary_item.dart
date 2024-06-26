import 'package:app/model/exercise_steps.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:flutter/material.dart';

class ExerciseSummaryItemView extends StatelessWidget {
  final ExerciseStep itemData;

  const ExerciseSummaryItemView({Key? key,
    required this.itemData,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: CommonUtil.getRectangleBoxDecoration(Colors.white54, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColor.darkBlue,
            minRadius: 35,
            child: Center(
              child: Text(itemData.serialNo ?? "",),
            ),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(itemData.name?.trim() ?? "",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                    maxLines: 2,
                  ),
                  Text('Zeit Dauer: ${itemData.duration ?? 0} seconds',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}