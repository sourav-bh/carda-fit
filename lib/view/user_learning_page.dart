import 'dart:typed_data';

import 'package:app/main.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/view/widgets/user_learning_item.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserLearningPage extends StatefulWidget {
  const UserLearningPage({Key? key}) : super(key: key);

  @override
  _UserLearningPageState createState() => _UserLearningPageState();
}

class _UserLearningPageState extends State<UserLearningPage> {

  final List<LearningMaterialInfo> _exercises = List.empty(growable: true);
  final List<LearningMaterialInfo> _learningMaterials = List.empty(growable: true);
  int? _selectedTab = 0;

  @override
  void initState() {
    super.initState();

    _exercises.addAll(LearningMaterialInfo.generateDummyExerciseList());
    _learningMaterials.addAll(LearningMaterialInfo.generateDummyList());

    _loadDataFromAsset();
  }

  _loadDataFromAsset() async {
    ByteData data = await rootBundle.load("assets/data/Datenbasis.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      print(table); //sheet Name
      print(excel.tables[table]?.maxCols);
      print(excel.tables[table]?.maxRows);
      for (var row in excel.tables[table]?.rows ?? []) {
        print("$row");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightPink,
      body: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          child: Column(
            children: [
              Card(
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
              ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  LearningMaterialInfo material = _selectedTab == 0 ? _exercises[index] : _learningMaterials[index];
                  return GestureDetector(
                    child: UserLearningItemView(itemData: material),
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
                itemCount: _selectedTab == 0 ? _exercises.length : _learningMaterials.length,
                scrollDirection: Axis.vertical,
              )
            ],
          ),
        ),
    );
  }
}
