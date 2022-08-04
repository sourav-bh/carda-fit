import 'dart:io';
import 'dart:ui';
import 'package:app/util/app_style.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonUtil {
  static isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  static getEmptyIfNull(String? value) {
    return value ?? '';
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
}