import 'dart:convert';

class Exercise {
  Exercise({
    this.name,
    this.difficultyLevel,
    this.description,
    this.createdAt,
  });
  String? name;
  String? difficultyLevel;
  String? description;
  String? createdAt;

  factory Exercise.fromRawJson(String str) =>
      Exercise.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory Exercise.fromMap(Map<String, dynamic> json) => Exercise(
        difficultyLevel: json["difficulty_level"],
        name: json["name"],
        description: json["description"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toMap() => {
        "difficulty_level": difficultyLevel,
        "name": name,
        "description": description,
        "cearetd_at": createdAt,
      };
}
