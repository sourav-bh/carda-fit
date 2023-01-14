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
  String? totalDueCount;
  int? completedCount;
  double? createdAt;
  double? lastUpdatedAt;
}
