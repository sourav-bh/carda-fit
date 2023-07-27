import 'package:app/view/task_alert_page.dart';
import 'package:flutter/material.dart';
import 'package:app/model/exercise.dart';
import '../model/exercise_steps.dart';
import 'package:app/main.dart';

class SummaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Exercise exerciseNow =
        ModalRoute.of(context)!.settings.arguments as Exercise;
    List<ExerciseStep> steps = exerciseNow.steps ?? [];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Zusammenfassung',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Übung: ${steps.isNotEmpty ? steps[0].name ?? "" : ""}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: steps.length - 1,
                  itemBuilder: (context, index) {
                    return _buildStepItem(index + 1, steps);
                  },
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16), // Padding um den Button
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, taskAlertRoute);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Text(
                      "Weiter",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.pink.shade50,
    );
  }

  String _getExerciseName(List<ExerciseStep> steps) {
    if (steps.length > 0) {
      return steps[0].name ?? "";
    }
    return "";
  }

  Widget _buildStepItem(int index, List<ExerciseStep> steps) {
    if (index >= steps.length - 1 ||
        steps[index].name == null ||
        steps[index].name!.isEmpty) {
      return SizedBox
          .shrink(); // Hide the item if it exceeds the steps length or has an empty name
    }

    ExerciseStep step = steps[index];
    String description = step.name!;
    int? duration = step.duration;

    return Container(
      color: Colors.grey[50], // Set the background color of the Container
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Schritt $index:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              if (duration != null && duration > 0)
                Text(
                  'Dauer: $duration Minuten',
                  style: TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
