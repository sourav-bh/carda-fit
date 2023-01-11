import 'dart:convert';

class UserAllergy {
  UserAllergy({
    this.userId,
    this.allergyCode,
  });
  String? userId;
  String? allergyCode;

  factory UserAllergy.fromRawJson(String str) =>
      UserAllergy.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory UserAllergy.fromMap(Map<String, dynamic> json) => UserAllergy(
        userId: json["user_id"],
        allergyCode: json["allergy_code"],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "allergy_code": allergyCode,
      };
}
