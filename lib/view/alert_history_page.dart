import 'package:app/model/task_alert.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/view/task_alert_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';

class AlertHistoryPage extends StatefulWidget {
  const AlertHistoryPage({Key? key}) : super(key: key);

  @override
  _AlertHistoryPageState createState() => _AlertHistoryPageState();
}

class _AlertHistoryPageState extends State<AlertHistoryPage> {

  final List<AlertHistory> _historyItems = List.empty(growable: true);

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  _loadData() async {
    List<AlertHistory> historyItems = await DatabaseHelper.instance.getAlertHistoryList();
    setState(() {
      _historyItems.clear();
      _historyItems.addAll(historyItems);
    });
  }

  Icon _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return const Icon(Icons.done_outline, color: Colors.green);
      case TaskStatus.missed:
        return const Icon(Icons.call_missed, color: Colors.red);
      case TaskStatus.pending:
        return const Icon(Icons.pending_actions, color: Colors.yellow);
      case TaskStatus.snoozed:
        return const Icon(Icons.snooze, color: Colors.grey);
      default:
        return const Icon(Icons.call_missed, color: Colors.red);
    }
  }

  String _getIconForTaskType(TaskType type) {
    switch (type) {
      case TaskType.steps:
      case TaskType.walkWithExercise:
        return 'assets/images/walk.jpg';
      case TaskType.exercise:
        return 'assets/images/exercise.jpg';
      case TaskType.breaks:
      case TaskType.waterWithBreak:
        return 'assets/images/break.jpg';
      case TaskType.water:
        return 'assets/images/water.jpg';
      default:
        return 'assets/splash_logo.png';
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        title: const Text('Alarmverlauf'),
      ),
      backgroundColor: AppColor.lightPink,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: _historyItems.isNotEmpty ?
            ListView.separated(
          itemCount: _historyItems.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final historyItem = _historyItems[index];
            return Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder( 
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 30, 
                      backgroundImage: AssetImage(
                        _getIconForTaskType(historyItem.taskType),
                      ),
                    ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          historyItem.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          historyItem.completedAt.isNotEmpty
                              ? CommonUtil.convertDbTimeStampToTimeOnlyStr(historyItem.completedAt)
                              : CommonUtil.convertDbTimeStampToTimeOnlyStr(historyItem.taskCreatedAt),
                          style: const TextStyle(fontSize: 12,
                          color: AppColor.lightBlack
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      historyItem.description,
                      style: const TextStyle(fontSize: 12,
                       color: AppColor.lightBlack),
                    ),
                  ],
                ),
                trailing: _getStatusIcon(historyItem.taskStatus),
                onTap: () {
                    if (historyItem.taskStatus == TaskStatus.snoozed) {
                      TaskAlertPageData alertPageData = TaskAlertPageData(viewMode: 0, taskType: historyItem.taskType.index);
                        Navigator.pushNamed(context, taskAlertRoute, arguments: alertPageData);
                 }
                },
              ),
            );
          },
        ) :
            Center(
              child: Text('Noch keine Alarme erhalten!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            )
      ),
    );
  }
}