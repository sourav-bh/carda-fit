import 'dart:convert';

class ExerciseStep {
  ExerciseStep({
    this.id,
    this.serialNo,
    this.name,
    this.details,
    this.media,
    this.duration,
    this.createdAt,
  });

  int? id;
  String? serialNo;
  String? name;
  String? details;
  String? media;
  int? duration;
  double? createdAt;

  factory ExerciseStep.fromRawJson(String str) =>
      ExerciseStep.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory ExerciseStep.fromMap(Map<String, dynamic> json) => ExerciseStep(
        id: json["id"],
        name: json["name"],
        details: json["details"] ?? "",
        media: json["media"],
        duration: json["duration"] ?? 0,
        serialNo: json["serial_no"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "details": details,
        "media": media,
        "duration": duration,
        "serial_no": serialNo,
        "created_at": createdAt,
      };
}
