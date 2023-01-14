import 'dart:convert';

class UserCondition {
  UserCondition({
    this.userId,
    this.conditionCode,
  });

  String? userId;
  String? conditionCode;

  factory UserCondition.fromRawJson(String str) =>
      UserCondition.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory UserCondition.fromMap(Map<String, dynamic> json) => UserCondition(
        userId: json["user_id"],
        conditionCode: json["condition_code"],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "condition_code": conditionCode,
      };
}
