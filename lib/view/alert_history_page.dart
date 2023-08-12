import 'package:app/model/task_alert.dart';
import 'package:app/util/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
         title: 'Walk',
         description: 'Please walk for 2 minutes',
         taskType: TaskType.steps,
         taskStatus: TaskStatus.completed,
         taskCreatedAt: '01 Jun 2023, 14:25',
         completedAt: '01 Jun 2023, 14:27')
     );
     _historyItems.add(AlertHistoryItem(
         title: 'Exercise',
         description: 'Please stretch your hand and move around a little bit',
         taskType: TaskType.exercise,
         taskStatus: TaskStatus.pending,
         taskCreatedAt: '01 Jun 2023, 10:00',
         completedAt: '')
     );
     _historyItems.add(AlertHistoryItem(
         title: 'Drink & Break',
         description: 'Take a short break for 2 minutes and drink a glass of water',
         taskType: TaskType.waterWithBreak,
         taskStatus: TaskStatus.missed,
         taskCreatedAt: '01 Jun 2023, 12:10',
         completedAt: '')
     );
     _historyItems.add(AlertHistoryItem(
         title: 'Exercise',
         description: 'Stand up and move your head in left, right, front and back directions',
         taskType: TaskType.exercise,
         taskStatus: TaskStatus.completed,
         taskCreatedAt: '01 Jun 2023, 09:30',
         completedAt: '01 Jun 2023, 09:35')
     );
     _historyItems.add(AlertHistoryItem(
         title: 'Drink',
         description: 'Please drink a glass of water',
         taskType: TaskType.water,
         taskStatus: TaskStatus.pending,
         taskCreatedAt: '01 Jun 2023, 13:45',
         completedAt: '')
     );
   });
  }

  // TODO: @Justin
  // left-side is the icon to identify the task, so pick the image based on the 'TaskType' value

  // in the middle show the title on top with the time only (no date).
  // -> In case the alert is "completed" show the time of 'completedAt', otherwise show 'taskCreatedAt'

  // in the middle and bottom of the title, show the description

  // right-side is the status icon, pick one from below based on the 'TaskStatus' value

  // status icons
  // const Icon(Icons.done_outline)
  // const Icon(Icons.call_missed)
  // const Icon(Icons.snooze)
  // const Icon(Icons.pending_actions)
Icon _getStatusIcon(TaskStatus status) {
  Color iconColor;
  switch (status) {
    case TaskStatus.completed:
      iconColor = Colors.green;
      return Icon(Icons.done_outline, color: iconColor);
    case TaskStatus.missed:
      iconColor = Colors.red;
      return Icon(Icons.call_missed, color: iconColor);
    case TaskStatus.pending:
      iconColor = Colors.yellow;
      return Icon(Icons.pending_actions, color: iconColor);
    default:
      iconColor = Colors.grey;
      return Icon(Icons.snooze, color: iconColor);
  }
}

  String _getIconForTaskType(TaskType type) {
  switch (type) {
    case TaskType.steps:
      return 'assets/images/walk.jpg';
    case TaskType.exercise:
      return 'assets/images/exercise.jpg';
    case TaskType.waterWithBreak:
      return 'assets/images/break.jpg';
    case TaskType.water:
      return 'assets/images/water.jpg';
    default:
      return 'assets/default_icon.png';
  }
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
      backgroundColor: AppColor.lightPink,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.separated(
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
                              ? historyItem.completedAt
                              : historyItem.taskCreatedAt,
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
                },
              ),
            );
          },
        ),
      ),
    );
  }
}