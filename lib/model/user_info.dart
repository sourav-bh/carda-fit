import 'dart:convert';
import 'dart:math';
import 'user_allergy.dart';

class UserInfo {
  UserInfo(
      {this.id,
      this.fullName,
      this.avatar,
      this.avatarImage,
      this.gender,
      this.age,
      this.weight,
      this.designation,
      this.jobType,
      this.createdAt,
      this.allergies,
      this.diseases,
      this.height,
      this.condition});

  String? id;
  String? fullName;
  String? avatar;
  String? avatarImage;
  String? gender;
  int? age;
  int? weight;
  int? height;
  String? designation;
  String? jobType;
  double? createdAt;
  List<String>? diseases;
  List<UserAllergy>? allergies;
  String? condition;

  // Sourav - create a new variable to store the condition value from user info page

  factory UserInfo.fromRawJson(String str) =>
      UserInfo.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory UserInfo.fromMap(Map<String, dynamic> json) => UserInfo(
        id: json["id"].toString(),
        fullName: json["fullName"],
        avatar: json["avatar"],
        avatarImage: json["avatar_image"],
        gender: json["gender"],
        age: json["age"],
        jobType: json["job_type"],
        weight: json["weight"],
        height: json["height"],
        designation: json["designation"],
        createdAt: json['created_at'],
        condition: json["condition"],
        //allergies: List<UserAllergy>.from(json["allergies"].map((x) => x)),
        //diseases: List<String>.from(json["diseases"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "id": id != null ? id.toString() : Random().nextInt(999),
        "fullName": fullName,
        "avatar": avatar,
        "avatar_image": avatarImage,
        "gender": gender,
        "age": age,
        "job_type": jobType,
        "weight": weight,
        "height": height,
        "designation": designation,
        "created_at": createdAt,
        "condition": condition,
        // "diseases": diseases != null? List<dynamic>.from(diseases!.map((x) => x)) : null,
        // "allergies": allergies != null ? List<dynamic>.from(allergies!.map((x) => x)): null,
      };
}

enum Gender {
  none,
  Mannlich,
  Weiblich,
  Divers,
}

enum JobType {
  none,
  Vollzeit,
  Teilzeit,
  HomeOffice,
}
