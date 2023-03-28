import 'dart:convert';

class UserApiModel {
  UserApiModel({
    this.id,
    this.userName,
    this.avatarName,
    this.avatarImage,
    this.deviceToken,
    this.score
  });

  String? id;
  String? userName;
  String? avatarName;
  String? avatarImage;
  String? deviceToken;
  int? score;

  factory UserApiModel.fromRawJson(String str) => UserApiModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserApiModel.fromJson(Map<String, dynamic> json) => UserApiModel(
    id: json["id"],
    userName: json["userName"],
    avatarName: json["avatarName"],
    avatarImage: json["avatarImage"],
    deviceToken: json["deviceToken"],
    score: json["score"],
  );

  Map<String, dynamic> toJson() => {
    "userName": userName,
    "avatarName": avatarName,
    "avatarImage": avatarImage,
    "deviceToken": deviceToken,
    "score": score,
  };
}
