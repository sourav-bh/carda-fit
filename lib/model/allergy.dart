import 'dart:convert';

class Allergy {
  Allergy({
    this.code,
    this.name,
    this.description,
    this.cause,
  });
  String? code;
  String? name;
  String? description;
  String? cause;

  factory Allergy.fromRawJson(String str) => Allergy.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory Allergy.fromMap(Map<String, dynamic> json) => Allergy(
        code: json["code"],
        name: json["name"],
        description: json["description"],
        cause: json["cause"],
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "name": name,
        "description": description,
        "cause": cause,
      };
}
