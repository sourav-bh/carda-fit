import 'dart:convert';

class Exercise {
  Exercise({
    this.userId,
    this.name,
    this.difficultyLevel,
    this.description,
    this.createdAt,
  });
  String? userId;
  String? name;
  int? difficultyLevel;
  String? description;
  double? createdAt;

  factory Exercise.fromRawJson(String str) =>
      Exercise.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory Exercise.fromMap(Map<String, dynamic> json) => Exercise(
        difficultyLevel: json["difficulty_level"],
        name: json["name"],
        description: json["description"],
        createdAt: json["created_at"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toMap() => {
        "difficulty_level": difficultyLevel,
        "name": name,
        "description": description,
        "cearetd_at": createdAt,
        "user_id": userId,
      };
}
