import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/data_loader.dart';
import 'package:flutter/material.dart';

class UserLearningItemView extends StatelessWidget {
  final LearningMaterialInfo itemData;

  const UserLearningItemView({Key? key,
    required this.itemData,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: CommonUtil.getRectangleBoxDecoration(Colors.white54, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Image.network(itemData.thumbnail ?? "",
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
                  Text(itemData.title.trim(),
                    style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 20),
                    maxLines: 2,
                  ),
                  Text(itemData.description.trim(),
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
    );
  }

}