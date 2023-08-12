import 'dart:convert';

class TaskAlert {
  TaskAlert({
    this.alertId,
    this.userId,
    this.taskId,
    this.title,
    this.description,
    this.contentUri,
    this.status,
    this.createdAt,
    this.lastUpdatedAt,
  });
  String? alertId;
  String? userId;
  String? taskId;
  String? title;
  String? description;
  String? contentUri;
  String? status;
  String? createdAt;
  String? lastUpdatedAt;

  factory TaskAlert.fromRawJson(String str) =>
      TaskAlert.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory TaskAlert.fromMap(Map<String, dynamic> json) => TaskAlert(
        alertId: json["alert_id"],
        userId: json["user_id"],
        taskId: json["task_id"],
        title: json["title"],
        description: json["description"],
        contentUri: json["content_uri"],
        status: json["status"],
        createdAt: json["created_at"],
        lastUpdatedAt: json["last_updated_at"],
      );

  Map<String, dynamic> toMap() => {
        "alert_id": alertId,
        "user_id": userId,
        "task_id": taskId,
        "title": title,
        "description": description,
        "content_uri": contentUri,
        'status': status,
        "created_at": createdAt,
        "last_updated_at": lastUpdatedAt,
      };
}

enum TaskType {
  water,
  steps,
  exercise,
  breaks,
  teamExercise,
  waterWithBreak,
  walkWithExercise,
}

enum TaskStatus { completed, pending, missed, snoozed, upcoming }

class AlertHistoryItem {
  AlertHistoryItem({
    required this.title,
    required this.description,
    required this.taskType,
    required this.taskStatus,
    required this.taskCreatedAt,
    required this.completedAt,
  });

  String title;
  String description;
  TaskType taskType;
  TaskStatus taskStatus;
  String taskCreatedAt; // date-time format: 01 Jun 2023, 14:25
  String completedAt; // date-time format: 01 Jun 2023, 14:25
}
