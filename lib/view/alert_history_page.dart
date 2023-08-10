import 'package:app/model/task_alert.dart';
import 'package:app/util/app_style.dart';
import 'package:app/view/task_alert_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AlertHistoryPage extends StatefulWidget {
  const AlertHistoryPage({Key? key}) : super(key: key);

  @override
  _AlertHistoryPageState createState() => _AlertHistoryPageState();
}

class _AlertHistoryPageState extends State<AlertHistoryPage> {

  final List<AlertHistoryItem> _historyItems = List.empty(growable: true);

  @override
  void initState() {
    super.initState();

    _loadDummyData();
  }

  _loadDummyData() {
   setState(() {
     _historyItems.add(AlertHistoryItem(
         title: 'Walking alert',
         description: 'Please walk for 2 minutes',
         taskType: TaskType.steps,
         taskStatus: TaskStatus.completed,
         taskCreatedAt: '01 Jun 2023, 14:25',
         completedAt: '01 Jun 2023, 14:27')
     );
     _historyItems.add(AlertHistoryItem(
         title: 'Exercise alert',
         description: 'Please stretch your hand and move around a little bit',
         taskType: TaskType.exercise,
         taskStatus: TaskStatus.pending,
         taskCreatedAt: '01 Jun 2023, 10:00',
         completedAt: '')
     );
     _historyItems.add(AlertHistoryItem(
         title: 'Drink with Break alert',
         description: 'Take a short break for 2 minutes and drink a glass of water',
         taskType: TaskType.waterWithBreak,
         taskStatus: TaskStatus.missed,
         taskCreatedAt: '01 Jun 2023, 12:10',
         completedAt: '')
     );
     _historyItems.add(AlertHistoryItem(
         title: 'Exercise alert',
         description: 'Stand up and move your head in left, right, front and back directions',
         taskType: TaskType.exercise,
         taskStatus: TaskStatus.completed,
         taskCreatedAt: '01 Jun 2023, 09:30',
         completedAt: '01 Jun 2023, 09:35')
     );
     _historyItems.add(AlertHistoryItem(
         title: 'Drink alert',
         description: 'Please drink a glass of water',
         taskType: TaskType.water,
         taskStatus: TaskStatus.pending,
         taskCreatedAt: '01 Jun 2023, 13:45',
         completedAt: '')
     );
   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: false,
          title: const Text('Alarmgeschichte'),
        ),
        body: Center(
          child: Text(
            'History items here, count is: ${_historyItems.length}',
            style: const TextStyle(fontSize: 14, color: AppColor.darkBlue),
          ),)
    );
  }
}
