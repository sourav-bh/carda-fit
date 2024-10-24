import 'dart:convert';
import 'package:app/model/exercise_steps.dart';

class Exercise {
  Exercise(
      {this.id,
      this.name,
      this.description,
      this.url,
      this.duration,
      this.difficultyLevel,
      this.steps,
      this.createdAt,
      this.condition,
      this.stepsJson
      });
     

  int? id;
  String? name;
  String? description;
  String? url;
  int? duration;
  int? difficultyLevel;
  List<ExerciseStep>? steps = [];
  double? createdAt;
  String? condition;
  String? stepsJson;

  factory Exercise.fromRawJson(String str) =>
      Exercise.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory Exercise.fromMap(Map<String, dynamic> json) => Exercise(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      url: json["url"],
      duration: json["duration"],
      difficultyLevel: json["difficulty_level"],
      stepsJson: json["steps_json"],
      steps: (json["steps_json"] as List<dynamic>)
      .map((stepJson) => ExerciseStep.fromMap(stepJson as Map<String, dynamic>))
      .toList(),
      createdAt: json["created_at"],
      condition: json["condition"],
     );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "description": description,
        "url": url,
        "duration": duration,
        "difficulty_level": difficultyLevel,
        "steps_json": json.encode(steps != null
        ? List<dynamic>.from(steps!.map((x) => x.toMap()))
        : []),
        "created_at": createdAt,
        "condition": condition,
      };
}
