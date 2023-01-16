import 'dart:convert';

class Scorer {
  Scorer({
    this.scorerId,
    this.userId,
    this.currentScore,
    this.currentLevel,
    this.currentRank,
    this.currentStreak,
    this.longestStreak,
  });
  String? scorerId;
  String? userId;
  double? currentScore;
  String? currentLevel;
  int? currentRank;
  int? currentStreak;
  int? longestStreak;

  factory Scorer.fromRawJson(String str) => Scorer.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory Scorer.fromMap(Map<String, dynamic> json) => Scorer(
        userId: json["user_id"],
        scorerId: json["scorer_id"],
        currentScore: json["current_score"],
        currentLevel: json["current_level"],
        currentRank: json["current_rank"],
        currentStreak: json["current_streak"],
        longestStreak: json["longest_streak"],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "scorer_id": scorerId,
        "current_score": currentScore,
        "current_level": currentLevel,
        "current_rank": currentRank,
        "dcurrent_streak": currentStreak,
        "longest_streak": longestStreak,
      };
}
