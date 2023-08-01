import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:app/api/api_manager.dart';
import 'package:app/model/user_info.dart';
import 'package:app/util/app_style.dart';
import 'package:app/view/task_alert_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

typedef StringCallback = void Function(String?);

class CommonUtil {
  static isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  static getEmptyIfNull(String? value) {
    return value ?? '';
  }
  
  static showSnoozedIfActive(bool? value) {
    
  }

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  static openUrl(String url) async {
    String uri = Uri.encodeFull(url.trim());
    if (await canLaunch(uri)) {
      launch(uri, forceSafariVC: false, enableJavaScript: true);
    }
  }

  static openYouTubeURL(String url) async {
    if (Platform.isIOS) {
      if (await canLaunch('youtube://$url')) {
        await launch('youtube://$url', forceSafariVC: false);
      } else {
        if (await canLaunch('https://$url')) {
          await launch('https://$url');
        } else {
          throw 'Could not launch https://$url';
        }
      }
    } else {
      var urlToLaunch = 'youtube://$url';
      if (await canLaunch(urlToLaunch)) {
        await launch(urlToLaunch);
      } else {
        throw 'Could not launch $urlToLaunch';
      }
    }
  }

  static String formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00';

    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = totalSeconds % 60;

    final minutesString = '$minutes'.padLeft(2, '0');
    final secondsString = '$seconds'.padLeft(2, '0');
    return '$minutesString:$secondsString';
  }

  static String convert12HourTimeTo24HourFormat(BuildContext context, TimeOfDay time) {
    var df = DateFormat("h:mm a");
    var dt = df.parse(time.format(context));
    return DateFormat('HH:mm').format(dt);
  }

  static double getSmallDiameter(BuildContext context) {
    return MediaQuery.of(context).size.width * 2 / 3;
  }

  static double getBigDiameter(BuildContext context) {
    return MediaQuery.of(context).size.width * 7 / 8;
  }

  static getFitnessItemBasedColor(int id) {
    switch (id) {
      case 12920:
        return AppColor.lightBlue.withAlpha(255);
      case 12921:
        return AppColor.lightOrange.withAlpha(255);
      case 12922:
        return AppColor.lightGreen.withAlpha(255);
      case 12923:
        return AppColor.secondary.withAlpha(255);
      default:
        return AppColor.primaryLight.withAlpha(255);
    }
  }

  static getRectangleBoxDecoration(Color fillColor, double radius) {
    return BoxDecoration(
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      color: fillColor,
    );
  }

  static String getRandomString(int length) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static int getRandomScore(int max) {
    return Random().nextInt(max);
  }

  static const List<String> weekdayNames = [
    'Mo',
    'Di',
    'Mi',
    'Do',
    'Fr',
  ];

  static String getWeekDaySelectionStr(List<bool> selections) {
    String result = "";
    for (int i=0 ; i<selections.length ; i++) {
      if (selections[i] == true) {
        result += weekdayNames[i];
        result += ', ';
      }
    }
    return result.substring(0, result.length - 2);
  }

  static String getPreferredAlertStr(List<TaskType> selections) {
    String result = "";
    for (TaskType selection in selections) {
      result += selection.name;
      result += ', ';
    }
    return result.substring(0, result.length - 2);
  }
}

class DrawCircle extends CustomPainter {
  final Color colorGradiant1;
  final Color colorGradiant2;
  final double radius;

  const DrawCircle(this.colorGradiant1, this.colorGradiant2, this.radius);

  @override
  void paint(Canvas canvas, Size size)
  {
    final paint = Paint()
      ..shader = LinearGradient(colors: [colorGradiant1, colorGradiant2,])
          .createShader(Rect.fromCircle(center: const Offset(0.0, 0.0), radius: radius));
    canvas.drawCircle(const Offset(0.0, 0.0), radius, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CurvePainter extends CustomPainter {
  final Color color;

  CurvePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(
        size.width / 2, size.height / 2, size.width, size.height * 0.25);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}