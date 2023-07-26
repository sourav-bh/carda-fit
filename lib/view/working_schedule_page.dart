import 'package:app/util/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../util/shared_preference.dart';

class WorkingSchedulePage extends StatefulWidget {
  const WorkingSchedulePage({Key? key}) : super(key: key);

  @override
  State<WorkingSchedulePage> createState() => _WorkingSchedulePageState();
}

class _WorkingSchedulePageState extends State<WorkingSchedulePage> {
  List<bool> selectedDays = [false, false, false, false, false, false, false];
  String? startingTime = '';
  String? endingTime = '';

  String _getWeekdayName(int index) {
    return [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag'
    ][index];
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != TimeOfDay.now()) {
      setState(() {
        startingTime = '${pickedTime.hour}:${pickedTime.minute}';
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != TimeOfDay.now()) {
      setState(() {
        endingTime = '${pickedTime.hour}:${pickedTime.minute}';
      });
    }
  }

  void _saveAction() async {
    // Convert the selectedDays list to a comma-separated string
    String selectedDaysString =
        selectedDays.map((selected) => selected ? '1' : '0').join(',');
    print(selectedDaysString);
    // save selectedDaysString
    SharedPref.instance
        .saveStringValue(SharedPref.keySelectedDays, selectedDaysString);

    // Save the start time
    SharedPref.instance.saveStringValue(SharedPref.keyStartTime, startingTime!);

    // Save the end time
    SharedPref.instance.saveStringValue(SharedPref.keyEndTime, endingTime!);

    // Show a snackbar to indicate that the data has been saved
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Data saved successfully!'),
    ));
    Navigator.pushNamedAndRemoveUntil(context, landingRoute, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightPink,
      body: Stack(
        children: [
          Positioned(
            top: 110,
            left: -getSmallDiameter(context) / 3,
            child: Container(
              width: getSmallDiameter(context),
              height: getSmallDiameter(context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.lightOrange,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -getSmallDiameter(context) / 3,
            child: Container(
              width: getSmallDiameter(context),
              height: getSmallDiameter(context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.lightBlue,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                padding: EdgeInsets.only(bottom: 0),
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 70, bottom: 10),
                    child: Text(
                      "Arbeitszeitplan",
                      style: Theme.of(context).textTheme.headline4?.copyWith(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Bitte wählen Sie die Tage an denen Sie arbeiten',
                            style:
                                Theme.of(context).textTheme.subtitle1?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ),
                        for (int i = 0; i < 7; i++)
                          Row(
                            children: [
                              Checkbox(
                                value: selectedDays[i],
                                onChanged: (value) {
                                  setState(() {
                                    selectedDays[i] = value!;
                                  });
                                },
                              ),
                              Text(
                                _getWeekdayName(i),
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'ARBEITSZEITEN',
                            style:
                                Theme.of(context).textTheme.subtitle1?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _selectStartTime(context),
                                    child: Text('Select Start Time'),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Starting Time: $startingTime'),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _selectEndTime(context),
                                    child: Text('Select End Time'),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Ending Time: $endingTime'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed:
              _saveAction, // Call the SaveAction method when the button is pressed
          style: ElevatedButton.styleFrom(
            primary: Colors.orangeAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Text(
              "Speichern",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double getSmallDiameter(BuildContext context) {
  return MediaQuery.of(context).size.width * 0.85;
}
