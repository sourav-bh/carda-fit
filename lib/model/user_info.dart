import 'dart:convert';

class UserInfo {
  UserInfo({
    this.userId,
    this.fullName,
    this.age,
    this.gender,
    this.jobType,
    this.designation,
    this.weight,
    this.height,
    this.diseases,
  });

  String? userId;
  String? fullName;
  int? age;
  String? gender;
  String? jobType;
  String? designation;
  double? weight;
  double? height;
  List<String>? diseases;

  factory UserInfo.fromRawJson(String str) => UserInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    userId: json["user_id"],
    fullName: json["full_name"],
    age: json["age"],
    gender: json["gender"],
    jobType: json["job_type"],
    designation: json["designation"],
    weight: json["weight"],
    height: json["height"],
    diseases: List<String>.from(json["diseases"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "full_name": fullName,
    "age": age,
    "gender": gender,
    "job_type": jobType,
    "designation": designation,
    "weight": weight,
    "height": height,
    "diseases": diseases != null ? List<dynamic>.from(diseases!.map((x) => x)) : null,
  };
}