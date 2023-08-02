// ignore_for_file: iterable_contains_unrelated_type

import 'dart:math';
import 'dart:typed_data';

import 'package:app/model/exercise.dart';
import 'package:app/model/exercise_steps.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/main.dart';
import 'package:app/model/learning.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
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

class CustomSearchDelegate extends SearchDelegate {
  List<LearningMaterialInfo> searchTerms = [];

  CustomSearchDelegate(List<LearningMaterialInfo> learningMaterials) {
    searchTerms = learningMaterials;
  }

  @override
  // Abteil um die Query zu löschen
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
  //Leave and close the Searchbar
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    print(">>>>>>>>>>$query");
    if (query.isEmpty) return Container();

    List<LearningMaterialInfo> learningMaterialResults = [];

    for (var learningMaterial in searchTerms) {
      if (query.toLowerCase().contains(learningMaterial.description.toLowerCase())) {
        learningMaterialResults.add(learningMaterial);
      } else if (query.toLowerCase().contains(learningMaterial.title.toLowerCase())) {
        learningMaterialResults.add(learningMaterial);
      }
    }
    print(learningMaterialResults);

    return ListView.builder(
      itemCount: learningMaterialResults.length,
      itemBuilder: (context, index) {
        var result = learningMaterialResults[index];
        return ListTile(
          title: Text(result.title ?? ""),
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
      if (query.toLowerCase().contains(learningMaterial.description.toLowerCase())) {
        learningMaterialResults.add(learningMaterial);
      } else if (query.toLowerCase().contains(learningMaterial.title.toLowerCase())) {
        learningMaterialResults.add(learningMaterial);
      }
    }
    print(learningMaterialResults);

    return ListView.builder(
      itemCount: learningMaterialResults.length,
      itemBuilder: (context, index) {
        var result = learningMaterialResults[index];
        return ListTile(
          title: Text(result.title ?? ""),
        );
      },
    );
  }
}
// TODO: how to switch the view of the list while seachring (no search / searching / search is over {3 cases})
class _UserLearningPageState extends State<UserLearningPage> {
  // show all the data
  final List<LearningMaterialInfo> _learningMaterials =
      List.empty(growable: true);
  int? _selectedTab = 1;
  bool _showFilteredList = false;
  String? _userCondition;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  /*  */
  // The function needs to be called everytime something is getting searched
  // The function gives out the list of recipes that mtach with the query
  // The search function needs to be implemented in the MySearchDelegate class, which is not possible for me
  _searchRecipes() {
    var query = "Gemüse";
    var results = [];
    for (var recipe in _learningMaterials) {
      if (recipe.title?.contains(query) ?? false) {
        results.add(recipe);
      }
    }
    return results;
  }

  _loadData() async {
    UserInfo? userInfo =
        await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    if (userInfo != null && !CommonUtil.isNullOrEmpty(userInfo.medicalConditions)) {
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
            Expanded(
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  LearningMaterialInfo material = _learningMaterials[index];
                  return GestureDetector(
                    child: UserLearningItemView(itemData: material),
                    onTap: () {
                      // TODO: @Justin -- see here how to pass value to another page
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
