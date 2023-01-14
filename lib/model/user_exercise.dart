import 'dart:convert';

class UserExercise {
  UserExercise({
    this.userId,
    this.exerciseId,
  });
  String? userId;
  String? exerciseId;

  factory UserExercise.fromRawJson(String str) =>
      UserExercise.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory UserExercise.fromMap(Map<String, dynamic> json) => UserExercise(
        userId: json["user_id"],
        exerciseId: json["exercise_id"],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "exercise_id": exerciseId,
      };
}
