import 'dart:typed_data';

import 'package:app/model/exercise.dart';
import 'package:app/model/exercise_steps.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/main.dart';
import 'package:app/model/learning.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/view/widgets/user_learning_item.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/model/user_info.dart';
import '../model/user_info.dart';
import '../util/app_constant.dart';

class UserLearningPage extends StatefulWidget {
  const UserLearningPage({Key? key}) : super(key: key);

  @override
  _UserLearningPageState createState() => _UserLearningPageState();
}

class _UserLearningPageState extends State<UserLearningPage> {
  final List<LearningMaterialInfo> _learningMaterials =
      List.empty(growable: true);
  int? _selectedTab = 1;

  @override
  void initState() {
    super.initState();

    _loadDataFromAsset();
  }

  _loadDataFromAsset() async {
    ByteData data = await rootBundle.load("assets/data/material_database.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    List<LearningContent> learningContents = [];
    for (var table in excel.tables.keys) {
      Sheet? sheet = excel.tables[table];
      if (table == "Lernmaterialien") {
        for (int rowIndex = 1; rowIndex < (sheet?.maxRows ?? 0); rowIndex++) {
          Data? titleCell = sheet?.cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
          Data? linkCell = sheet?.cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
          Data? conditionCell = sheet?.cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex));

          LearningContent content = LearningContent();
          content.condition = conditionCell?.value.toString();
          content.title = titleCell?.value.toString();
          content.contentUri = linkCell?.value.toString();

          // Sourav - before adding a learning content, retrieve the userInfo from database
          // and see what is the condition saved for the current user.
          // Match that user condition with the content's condition you found from excel
          learningContents.add(content);

          var info = await LearningMaterialInfo.copyContentFromLink(content);
          if (mounted) {
            setState(() {
              _learningMaterials.add(info);
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightPink,
      body: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: Column(
          children: [
            Visibility(
              visible: false,
              child: Card(
                elevation: 5,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _selectedTab,
                  backgroundColor: Colors.white,
                  thumbColor: Colors.orange,
                  padding: EdgeInsets.zero,
                  children: const {
                    0: Text('Übungen'),
                    1: Text('Lernmaterialien'),
                  },
                  onValueChanged: (newValue) {
                    print(newValue);
                    setState(() {
                      _selectedTab = newValue;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  LearningMaterialInfo material = _learningMaterials[index];
                  return GestureDetector(
                    child: UserLearningItemView(itemData: material),
                    onTap: () {
                      Navigator.pushNamed(context, detailsWebRoute,
                          arguments: material.originalContent);
                      // CommonUtil.openUrl(material.videoUrl);
                      // Navigator.pushNamed(context, learningDetailsRoute, arguments: material.description);
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(endIndent: 0, color: Colors.transparent);
                },
                itemCount: _learningMaterials.length,
                scrollDirection: Axis.vertical,
              ),
            )
          ],
        ),
      ),
    );
  }
}
