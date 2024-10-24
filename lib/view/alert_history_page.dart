import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../app.dart';
import 'package:app/model/task_alert.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/view/task_alert_page.dart';

//**Diese Klasse stellt die Alarmverlaufseite dar. Sie wird verwendet, um den Alarmverlauf anzuzeigen, der aus verschiedenen Alarmen besteht, die der Benutzer erhalten hat. */
class AlertHistoryPage extends StatefulWidget {
  const AlertHistoryPage({Key? key}) : super(key: key);

  @override
  _AlertHistoryPageState createState() => _AlertHistoryPageState();
}

class _AlertHistoryPageState extends State<AlertHistoryPage> with WidgetsBindingObserver {
  final List<AlertHistory> _historyItems = List.empty(growable: true);

//Dies ist der zugehörige State für die AlertHistoryPage. Der State enthält die Logik für das Anzeigen des Alarmverlaufs.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadData(); // Daten erneut laden, wenn die App fortgesetzt wird
    }
  }
  
//**Diese Funktion wird aufgerufen, um die Daten für die Alarmverlaufseite zu laden.
//Sie ruft die Liste der Alarmverlaufselemente aus der lokalen Datenbank ab und aktualisiert den Zustand der Seite, um die Daten darzustellen. */
  _loadData() async {
    String today = CommonUtil.getCurrentDayAsDbFormat();
    List<AlertHistory> historyItems = await DatabaseHelper.instance.getAlertHistoryListOfDate(today);
    if (mounted) {
      setState(() {
        _historyItems.clear();
        _historyItems.addAll(historyItems);
      });
    }
  }

//**Diese Funktion gibt ein Icon zurück, das auf den Status eines Alarmverlaufselements hinweist.
//Sie akzeptiert einen TaskStatus als Eingabe und gibt ein entsprechendes Icon zurück, das den Status visualisiert.
//Zum Beispiel ein grünes Häkchen für "completed" (erledigt) oder ein rotes Ausrufezeichen für "missed" (verpasst). */
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

//**Diese Funktion gibt einen Bildpfad zurück, der einem bestimmten TaskType entspricht.
//Sie akzeptiert einen TaskType als Eingabe und gibt den Pfad zu einer Bilddatei zurück,
// die diesem TaskType zugeordnet ist. Dieses Bild wird verwendet,
// um den Typ des Alarms zu visualisieren. */
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
                    if (historyItem.taskStatus == TaskStatus.snoozed || historyItem.taskStatus == TaskStatus.pending) {
                      TaskAlertPageData alertPageData = TaskAlertPageData(viewMode: 0, taskType: historyItem.taskType.index, taskHistoryId: historyItem.dbId);
                      Navigator.pushNamed(context, taskAlertRoute, arguments: alertPageData);
                    }  else if (historyItem.taskStatus == TaskStatus.completed) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Aufgabe abgeschlossen'),
                            content: const Text('Diese Aufgabe wurde erfolgreich abgeschlossen.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Ok',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (historyItem.taskStatus == TaskStatus.missed) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Aufgabe verpasst'),
                            content: const Text('Diese Aufgabe wurde verpasst und kann nicht nachgeholt werden, da kein Snooze-Alarm festgelegt wurde.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Ok',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
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