import 'dart:convert';

class Learning {
  Learning({
    this.userId,
    this.title,
    this.description,
    this.contentUri,
    this.targetUserLevel,
    this.contentType,
    this.createdAt,
  });
  String? userId;
  String? title;
  String? description;
  String? contentUri;
  String? targetUserLevel;
  String? contentType;
  double? createdAt;

  factory Learning.fromRawJson(String str) =>
      Learning.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory Learning.fromMap(Map<String, dynamic> json) => Learning(
        userId: json["user_id"],
        title: json["title"],
        description: json["description"],
        contentUri: json["content_uri"],
        targetUserLevel: json["target_user_level"],
        contentType: json["content_type"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "title": title,
        "description": description,
        "content_uri": contentUri,
        "target_user_level": targetUserLevel,
        "content_type": contentType,
        "created_at": createdAt,
      };
}
