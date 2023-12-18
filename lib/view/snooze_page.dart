import 'package:app/app.dart';
import 'package:flutter/material.dart';
import 'package:app/model/user_info.dart';
import 'package:intl/intl.dart';

import '../util/app_style.dart';
import '../util/common_util.dart';
import '../util/shared_preference.dart';

class SnoozePage extends StatefulWidget {
  final void Function()? onUpdateState;

  const SnoozePage({Key? key, this.onUpdateState}) : super(key: key);

  @override
  _SnoozePageState createState() => _SnoozePageState();
}

class _SnoozePageState extends State<SnoozePage> {
  final List<SnoozeTime> _snoozeTimeItems = [
    SnoozeTime(duration: const Duration(minutes: 5), isSelected: false),
    SnoozeTime(duration: const Duration(minutes: 10), isSelected: false),
    SnoozeTime(duration: const Duration(minutes: 30), isSelected: false),
    SnoozeTime(duration: const Duration(hours: 1), isSelected: false),
    SnoozeTime(duration: const Duration(hours: 2), isSelected: false),
    SnoozeTime(duration: const Duration(hours: 3), isSelected: false),
  ];

  SnoozeTime? _selectedSnoozeTimeVal;
  DateTime? _startTime;
  DateTime? _endTime;
  bool? isSelected;

  TextStyle _getTextStyle(bool isSelected) {
    Color textColor = isSelected ? Colors.orange : Colors.black;

    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.bold,
    );
  }

  Future<void> _selectSnoozeStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primaryLight,
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.orange,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != TimeOfDay.now()) {
      setState(() {
        _startTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _selectSnoozeEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primaryLight,
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.orange,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != TimeOfDay.now()) {
      setState(() {
        _endTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void setSnoozeTime(SnoozeTime snoozeTime) async {
    setState(() {
      _selectedSnoozeTimeVal = snoozeTime;
    });

    await SharedPref.instance.saveIntValue(
      SharedPref.keySnoozeDuration,
      _selectedSnoozeTimeVal?.duration.inMinutes ?? 0,
    );
    await SharedPref.instance.saveIntValue(
      SharedPref.keySnoozedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  _checkSnoozeTimeStatus() async {
    int snoozeDuration =
        await SharedPref.instance.getIntValue(SharedPref.keySnoozeDuration);
    int snoozedAt =
        await SharedPref.instance.getIntValue(SharedPref.keySnoozedAt);
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    if (currentTime - snoozedAt > snoozeDuration * 60 * 1000) {
      setState(() {
        _selectedSnoozeTimeVal = null;
      });

      await SharedPref.instance.deleteValue(SharedPref.keySnoozeDuration);
      await SharedPref.instance.deleteValue(SharedPref.keySnoozedAt);
    } else {
      setState(() {
        _selectedSnoozeTimeVal = SnoozeTime(
            duration: Duration(minutes: snoozeDuration), isSelected: true);
      });
    }
  }

  void resetSnooze() async {
    // Hier setzen Sie den Snooze-Wert in der Datenbank zurück
    await SharedPref.instance.deleteValue(SharedPref.keySnoozeDuration);
    await SharedPref.instance.deleteValue(SharedPref.keySnoozedAt);

    // Hier wird die Bestätigung angezeigt
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Snooze wurde erfolgreich aufgehoben.'),
        duration: Duration(
            seconds:
                2), // Zeigt die Bestätigung für 2 Sekunden an (kann angepasst werden)
      ),
    );
  }

  void _calculateAndSaveCustomSnoozeTime() async {
    if (_startTime != null && _endTime != null) {
      DateTime startDateTime = _startTime!;
      DateTime endDateTime = _endTime!;

      // Berechnung der Differenz in Minuten
      int differenceInMinutes = endDateTime.difference(startDateTime).inMinutes;

      // Erstellen einer SnoozeTime mit der berechneten Differenz
      SnoozeTime customSnoozeTime = SnoozeTime(
        duration: Duration(minutes: differenceInMinutes),
        isSelected: true,
      );

      // Speichern der SnoozeTime
      await SharedPref.instance.saveIntValue(
        SharedPref.keySnoozeDuration,
        differenceInMinutes,
      );
      await SharedPref.instance.saveIntValue(
        SharedPref.keySnoozedAt,
        DateTime.now().millisecondsSinceEpoch,
      );

      // Aktualisierung des ausgewählten SnoozeTime-Werts
      setState(() {
        _selectedSnoozeTimeVal = customSnoozeTime;
      });

      // Zeigen Sie eine Bestätigungsnachricht an
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Snooze wurde erfolgreich gespeichert.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Zeigen Sie eine Fehlermeldung an, wenn Start- oder Endzeit fehlen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bitte wählen Sie sowohl Start- als auch Endzeit aus.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSnoozeTimeStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightPink,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Zentrierter Text oben
                Center(
                  child: Text(
                    'Snooze-Zeit wählen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Klickbare Snooze-Zeiten
                for (int i = 0; i < _snoozeTimeItems.length; i += 2)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedSnoozeTimeVal == _snoozeTimeItems[i]) {
                              // Deselect, wenn bereits ausgewählt
                              _selectedSnoozeTimeVal = null;
                            } else {
                              setSnoozeTime(_snoozeTimeItems[i]);
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 30),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // _selectedSnoozeTimeVal == _snoozeTimeItems[i]
                            //     ? Colors.orangeAccent
                            //     : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedSnoozeTimeVal ==
                                      _snoozeTimeItems[i]
                                  ? Colors.orangeAccent
                                  : Colors
                                      .white, // Ändern Sie die Borderfarbe hier
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${_snoozeTimeItems[i].duration.inMinutes} min',
                            style: _getTextStyle(
                                _selectedSnoozeTimeVal == _snoozeTimeItems[i]),
                          ),
                        ),
                      ),
                      if (i + 1 < _snoozeTimeItems.length)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedSnoozeTimeVal ==
                                  _snoozeTimeItems[i + 1]) {
                                // Deselect, wenn bereits ausgewählt
                                _selectedSnoozeTimeVal = null;
                              } else {
                                setSnoozeTime(_snoozeTimeItems[i + 1]);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 30),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // _selectedSnoozeTimeVal ==
                              //         _snoozeTimeItems[i + 1]
                              //     ? Colors.orangeAccent
                              //     : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedSnoozeTimeVal ==
                                        _snoozeTimeItems[i + 1]
                                    ? Colors.orangeAccent
                                    : Colors.white,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${_snoozeTimeItems[i + 1].duration.inMinutes} min',
                              style: _getTextStyle(_selectedSnoozeTimeVal ==
                                  _snoozeTimeItems[i + 1]),
                            ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 10),
                // Bestätigungsbutton
                ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => Colors.transparent,
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, homeRoute);
                    widget.onUpdateState?.call();
                  },
                  child: Ink(
                    decoration: const BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(
                          minHeight: 40), // min sizes for Material buttons
                      alignment: Alignment.center,
                      child: Text(
                        _selectedSnoozeTimeVal == null
                            ? 'Snooze Bestätigen'
                            : 'Snooze bestätigen: ${_selectedSnoozeTimeVal?.duration.inMinutes} Minuten',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                // Spacer(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      _startTime == null
                          ? ' Snooze Startzeit wählen'
                          : 'Startzeit: ${DateFormat('HH:mm').format(_startTime!)}',
                      // Änderung hier
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500, fontSize: 17),
                    ),
                    IconButton(
                        onPressed: () {
                          _selectSnoozeStartTime(context);
                        },
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: AppColor.orange,
                          size: 30,
                        ))
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      _endTime == null
                          ? ' Snooze Startzeit wählen'
                          : 'Startzeit: ${DateFormat('HH:mm').format(_endTime!)}',
                      // Änderung hier
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500, fontSize: 17),
                    ),
                    IconButton(
                        onPressed: () {
                          _selectSnoozeEndTime(context);
                        },
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: AppColor.orange,
                          size: 30,
                        ))
                  ],
                ),

                const SizedBox(height: 10),
                // Bestätigungsbutton für die Differenzberechnung
                ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => Colors.transparent,
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    _calculateAndSaveCustomSnoozeTime();
                    Navigator.pushNamed(context, homeRoute);
                    widget.onUpdateState?.call();
                  },
                  child: Ink(
                    decoration: const BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 40,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'gewählte Zeit bestätigen',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                // "Annullieren"-Button
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(
                          0), // Setzt die Erhebung auf 0
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) => Colors.transparent,
                      ),
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedSnoozeTimeVal = null;
                      });
                      resetSnooze();
                      Navigator.pushNamed(context, homeRoute);
                      widget.onUpdateState?.call();
                    },
                    child: Ink(
                      decoration: const BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Snooze annullieren',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10), // Platz zwischen Text und Button
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pushNamed(context, homeRoute);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
