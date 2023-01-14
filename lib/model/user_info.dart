import 'dart:convert';
import 'user_allergy.dart';

class UserInfo {
  UserInfo({
    this.userId,
    this.fullName,
    this.age,
    this.weight,
    this.bmi,
    this.jobType,
    this.jobTime,
    this.createdAt,
    this.allergies,
    this.diseases,
    this.height,
  });

  String? userId;
  String? fullName;
  int? age;
  String? weight;
  String? bmi;
  String? jobType;
  String? jobTime;
  double? createdAt;
  List<String>? diseases;
  List<UserAllergy>? allergies;
  String? height;

  factory UserInfo.fromRawJson(String str) =>
      UserInfo.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory UserInfo.fromMap(Map<String, dynamic> json) => UserInfo(
        userId: json["user_id"],
        fullName: json["full_name"],
        age: json["age"],
        jobType: json["job_type"],
        weight: json["weight"],
        height: json["height"],
        jobTime: json["job_time"],
        bmi: json["bmi"],
        createdAt: json['created_at'],
        allergies: List<UserAllergy>.from(json["allergies"].map((x) => x)),
        diseases: List<String>.from(json["diseases"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "full_name": fullName,
        "age": age,
        "job_type": jobType,
        "weight": weight,
        "height": height,
        "job_time": jobTime,
        "bmi": bmi,
        "created_at": createdAt,
        "diseases": diseases != null
            ? List<dynamic>.from(diseases!.map((x) => x))
            : null,
        "allergies": allergies != null
            ? List<dynamic>.from(allergies!.map((x) => x))
            : null,
      };
}

enum JobType {
  none,
  fulltime,
  parttime,
  fieldjob,
}
