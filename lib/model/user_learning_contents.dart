import 'dart:convert';

class UserLearningContent {
  UserLearningContent({
    this.userId,
    this.contentId,
    this.viewCount,
    this.lastViewedAt,
  });
  String? userId;
  String? contentId;
  String? viewCount;
  String? lastViewedAt;

  factory UserLearningContent.fromRawJson(String str) =>
      UserLearningContent.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory UserLearningContent.fromMap(Map<String, dynamic> json) =>
      UserLearningContent(
        userId: json["user_id"],
        contentId: json["content_id"],
        viewCount: json["view_Count"],
        lastViewedAt: json["last_viewed_at"],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "content_id": contentId,
        "view_count": viewCount,
        "last_viewed_at": lastViewedAt,
      };
}
