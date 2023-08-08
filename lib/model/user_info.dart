import 'dart:convert';

class UserInfo {
  UserInfo({
    this.id,
    this.dbId,
    this.userName,
    this.password,
    this.avatarImage,
    this.deviceToken,
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.teamName,
    this.score,
    this.jobPosition,
    this.jobType,
    this.workingDays,
    this.workStartTime,
    this.workEndTime,
    this.medicalConditions,
    this.diseases,
    this.preferredAlerts,
    this.isMergedAlertSet
  });

  String? id;
  int? dbId;
  String? userName;
  String? password;
  String? avatarImage;
  String? deviceToken;

  int? age;
  String? gender;
  int? weight;
  int? height;

  String? teamName;
  int? score;

  String? jobPosition;
  String? jobType;
  String? workingDays; // comma separated days as 2-letter initial
  String? workStartTime;
  String? workEndTime;

  String? medicalConditions; // comma separated conditions string
  String? diseases; // comma separated disease string
  String? preferredAlerts; // comma separated string containing alert type enum values
  bool? isMergedAlertSet; // indicate if the user wants to merge the alert types, like water + break and exercise + steps

  factory UserInfo.fromRawJson(String str) => UserInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: json["id"],
    userName: json["userName"],
    password: json["password"],
    avatarImage: json["avatarImage"],
    deviceToken: json["deviceToken"],
    age: json["age"],
    gender: json["gender"],
    weight: json["weight"],
    height: json["height"],
    teamName: json["teamName"],
    score: json["score"],
    jobPosition: json["jobPosition"],
    jobType: json["jobType"],
    workingDays: json["workingDays"],
    workStartTime: json["workStartTime"],
    workEndTime: json["workEndTime"],
    medicalConditions: json["medicalConditions"],
    diseases: json["diseases"],
    preferredAlerts: json["preferredAlerts"],
    isMergedAlertSet: json["isMergedAlertSet"],
  );

  Map<String, dynamic> toJson() => {
    "userName": userName,
    "password": password,
    "avatarImage": avatarImage,
    "deviceToken": deviceToken,
    "age": age,
    "gender": gender,
    "weight": weight,
    "height": height,
    "teamName": teamName,
    "score": score,
    "jobPosition": jobPosition,
    "jobType": jobType,
    "workingDays": workingDays,
    "workStartTime": workStartTime,
    "workEndTime": workEndTime,
    "medicalConditions": medicalConditions,
    "diseases": diseases,
    "preferredAlerts": preferredAlerts,
    "isMergedAlertSet": isMergedAlertSet,
  };

  factory UserInfo.fromDbMap(Map<String, dynamic> json) => UserInfo(
    dbId: json["id"],
    userName: json["userName"],
    avatarImage: json["avatarImage"],
    age: json["age"],
    gender: json["gender"],
    weight: json["weight"],
    height: json["height"],
    teamName: json["teamName"],
    score: json["score"],
    jobPosition: json["jobPosition"],
    jobType: json["jobType"],
    workingDays: json["workingDays"],
    workStartTime: json["workStartTime"],
    workEndTime: json["workEndTime"],
    medicalConditions: json["medicalConditions"],
    diseases: json["diseases"],
    preferredAlerts: json["preferredAlerts"],
    isMergedAlertSet: json["isMergedAlertSet"] == 1 ? true : false,
  );

  Map<String, dynamic> toDbMap() => {
    "userName": userName,
    "avatarImage": avatarImage,
    "age": age,
    "gender": gender,
    "weight": weight,
    "height": height,
    "teamName": teamName,
    "score": score,
    "jobPosition": jobPosition,
    "jobType": jobType,
    "workingDays": workingDays,
    "workStartTime": workStartTime,
    "workEndTime": workEndTime,
    "medicalConditions": medicalConditions,
    "diseases": diseases,
    "preferredAlerts": preferredAlerts,
    "isMergedAlertSet": isMergedAlertSet ?? false ? 1 : 0,
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

class SnoozeTime {
  SnoozeTime({
    required this.duration,
    required this.isSelected
  });

  Duration duration;
  bool isSelected;
}