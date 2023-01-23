import 'dart:convert';

class LearningContent {
  LearningContent({
    this.id,
    this.title,
    this.description,
    this.contentUri,
    this.targetUserLevel,
    this.contentType,
    this.createdAt,
  });

  int? id;
  String? title;
  String? description;
  String? contentUri;
  String? targetUserLevel;
  String? contentType;
  double? createdAt;

  factory LearningContent.fromRawJson(String str) =>
      LearningContent.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory LearningContent.fromMap(Map<String, dynamic> json) => LearningContent(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    contentUri: json["content_uri"],
    targetUserLevel: json["target_user_level"],
    contentType: json["content_type"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "description": description,
    "content_uri": contentUri,
    "target_user_level": targetUserLevel,
    "content_type": contentType,
    "created_at": createdAt,
  };
}
