import 'dart:convert';

class DailyTarget {
  DailyTarget({
    this.steps,
    this.exercises,
    this.waterGlasses,
    this.breaks
  });

  int? steps;
  int? exercises;
  int? waterGlasses;
  int? breaks;

  factory DailyTarget.fromRawJson(String str) =>
      DailyTarget.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory DailyTarget.fromMap(Map<String, dynamic> json) => DailyTarget(
    steps: json["steps"],
    exercises: json["exercises"],
    waterGlasses: json["water_glasses"],
    breaks: json["breaks"],
  );

  Map<String, dynamic> toMap() => {
    "steps": steps,
    "exercises": exercises,
    "water_glasses": waterGlasses,
    "breaks": breaks,
  };

  void increaseWaterConsumption(int newVal) {
    int oldVal = waterGlasses ?? 0;
    waterGlasses = oldVal + newVal;
  }

  void increaseStepsCount(int newVal) {
    int oldVal = steps ?? 0;
    steps = oldVal + newVal;
  }

  void increaseExerciseCount(int newVal) {
    int oldVal = exercises ?? 0;
    exercises = oldVal + newVal;
  }

  void increaseBreaksCount(int newVal) {
    int oldVal = breaks ?? 0;
    breaks = oldVal + newVal;
  }
}
