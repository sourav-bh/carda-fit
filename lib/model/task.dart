import 'dart:convert';

class Task {
  Task({
    this.userId,
    this.name,
    this.difficultyLevel,
    this.description,
    this.frequency,
    this.duration,
    this.score,
    this.createdAt,
  });
  String? userId;
  String? name;
  String? difficultyLevel;
  String? description;
  String? frequency;
  int? duration;
  double? score;
  double? createdAt;

  factory Task.fromRawJson(String str) => Task.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory Task.fromMap(Map<String, dynamic> json) => Task(
        userId: json["user_id"],
        name: json["name"],
        difficultyLevel: json["difficulty_level"],
        description: json["description"],
        frequency: json["frequency"],
        duration: json["duration"],
        score: json["score"],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "name": name,
        "difficulty_level": difficultyLevel,
        "description": description,
        "frequency": frequency,
        "duration": duration,
        "score": score,
        "created_at": createdAt,
      };
}
