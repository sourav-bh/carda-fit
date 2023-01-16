import 'dart:convert';

class UserTask {
  UserTask({
    this.userId,
    this.taskId,
    this.totalDueCount,
    this.completedCount,
    this.createdAt,
    this.lastUpdatedAt,
  });
  String? userId;
  String? taskId;
  int? totalDueCount;
  int? completedCount;
  double? createdAt;
  double? lastUpdatedAt;

  factory UserTask.fromRawJson(String str) =>
      UserTask.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory UserTask.fromMap(Map<String, dynamic> json) => UserTask(
        userId: json["user_id"],
        taskId: json["task_id"],
        totalDueCount: json["total_due_Count"],
        completedCount: json["completed_count"],
        createdAt: json["created_at"],
        lastUpdatedAt: json["last_updated_at"],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "task_id": taskId,
        "total_due_count": totalDueCount,
        "completed_count": completedCount,
        "created_at": createdAt,
        "last_updated_at": lastUpdatedAt,
      };
}
