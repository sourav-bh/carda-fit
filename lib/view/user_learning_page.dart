import 'package:app/app.dart';
import 'package:app/model/learning.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/data_loader.dart';
import 'package:app/view/widgets/user_learning_item.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util/app_constant.dart';

class UserLearningPage extends StatefulWidget {
  const UserLearningPage({Key? key}) : super(key: key);

  @override
  _UserLearningPageState createState() => _UserLearningPageState();
}

class CustomSearchDelegate extends SearchDelegate {
  List<LearningMaterialInfo> searchTerms = [];

  CustomSearchDelegate(List<LearningMaterialInfo> learningMaterials) {
    searchTerms = learningMaterials;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print(">>>>>>>>>>$query");
    if (query.isEmpty) return Container();

    List<LearningMaterialInfo> learningMaterialResults = [];

    for (var learningMaterial in searchTerms) {
      if (learningMaterial.description
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          learningMaterial.title.toLowerCase().contains(query.toLowerCase())) {
        learningMaterialResults.add(learningMaterial);
      }
    }

    return ListView.builder(
      itemCount: learningMaterialResults.length,
      itemBuilder: (context, index) {
        var result = learningMaterialResults[index];
        return ListTile(
          title: Text(result.title),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    print(">>>>>>>>>>$query");
    if (query.isEmpty) return Container();

    List<LearningMaterialInfo> learningMaterialResults = [];

    for (var learningMaterial in searchTerms) {
      if (learningMaterial.description
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          learningMaterial.title.toLowerCase().contains(query.toLowerCase())) {
        learningMaterialResults.add(learningMaterial);
      }
    }

    return ListView.separated(
      itemCount: learningMaterialResults.length,
      separatorBuilder: (context, index) {
        return const Divider(endIndent: 0, color: Colors.transparent);
      },
      itemBuilder: (context, index) {
        var result = learningMaterialResults[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, detailsWebRoute, arguments: result.originalContent);
          },
          child: ListTile(
            title: Text(result.title),
          ),
        );
      },
    );
  }
}

class _UserLearningPageState extends State<UserLearningPage> {
  // show all the data
  final List<LearningMaterialInfo> _learningMaterials =
      List.empty(growable: true);
  int? _selectedTab = 1;
  bool _showFilteredList = false;
  String? _userCondition;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  _loadData() async {
    setState(() => _isLoading = true);

    UserInfo? userInfo =
        await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    if (userInfo != null &&
        !CommonUtil.isNullOrEmpty(userInfo.medicalConditions)) {
      setState(() {
        _showFilteredList = true;
        _userCondition = userInfo.medicalConditions;
      });
    }

    _loadContentsFromAsset(true, _userCondition);

    if (_learningMaterials.isEmpty) {
      setState(() {
        _showFilteredList = false;
      });
      _loadContentsFromAsset(false, null);
    }
  }

  _loadContentsFromAsset(bool isFiltered, String? filerCondition) async {
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

          bool addContent = false;
          if (isFiltered) {
            if (content.condition != null &&
                filerCondition != null &&
                filerCondition.contains(content.condition ?? "")) {
              addContent = true;
            } else if (filerCondition == null) {
              addContent = true;
            } else {
              // skip this learning content, since it is not useful for the user condition specified
            }
          } else {
            addContent = true;
          }

          if (addContent) {
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
    // _searchRecipes();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(_learningMaterials),
              );
            },
          )
        ],
      ),
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
            Visibility(
              visible: _showFilteredList,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Text(
                  'Sie sehen die Inhalte, die Ihrem Gesundheitszustand entsprechen: ${_userCondition ?? ""}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColor.darkBlue, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            _isLoading ?
            const Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(),
            ) :
            Expanded(
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  LearningMaterialInfo material = _learningMaterials[index];
                  return GestureDetector(
                    child: UserLearningItemView(itemData: material),
                    onTap: () {
                      Navigator.pushNamed(context, detailsWebRoute, arguments: material.originalContent);
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
