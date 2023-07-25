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
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

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

  void _saveAction() async {
    // Convert the selectedDays list to a comma-separated string
    String selectedDaysString =
        selectedDays.map((selected) => selected ? '1' : '0').join(',');

    // save selectedDaysString
    SharedPref.instance
        .saveStringValue(SharedPref.keySelectedDays, selectedDaysString);

    // Save the start time
    SharedPref.instance
        .saveStringValue(SharedPref.keyStartTime, startTimeController.text);

    // Save the end time
    SharedPref.instance
        .saveStringValue(SharedPref.keyEndTime, endTimeController.text);

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
                        TextField(
                          decoration: InputDecoration(
                            labelText:
                                'Startzeit (hh:mm)', // <-- Update the label for Startzeit
                            prefixText: 'Von: ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.white12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.white12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            labelText:
                                'Endzeit (hh:mm)', // <-- Update the label for Endzeit
                            prefixText: 'Bis: ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.white12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.white12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade300,
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
