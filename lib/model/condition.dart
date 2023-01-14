import 'dart:convert';

class Condition {
  Condition({
    this.code,
    this.name,
    this.description,
    this.frequency,
  });
  String? code;
  String? name;
  String? description;
  String? frequency;

  factory Condition.fromRawJson(String str) =>
      Condition.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory Condition.fromMap(Map<String, dynamic> json) => Condition(
        code: json["code"],
        name: json["name"],
        description: json["description"],
        frequency: json["frequency"],
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "name": name,
        "description": description,
        "frequency": frequency,
      };
}
