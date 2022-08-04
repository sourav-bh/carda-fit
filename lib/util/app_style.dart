import 'package:flutter/material.dart';

class AppTextStyle {
  static const double captionTextSize = 26;
  static const double headerTextSize = 20;
  static const double subHeaderTextSize = 18;
  static const double titleTextSize = 17;
  static const double subTitleTextSize = 16;
  static const double bodyTextSize = 15;
  static const double smallTextSize = 14;
  static const double extraSmallTextSize = 12;
  
  static const TextTheme appTextTheme = TextTheme(
    caption: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold, fontSize: captionTextSize),
    headline1: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: headerTextSize),
    subtitle1: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: titleTextSize),
    bodyText1: TextStyle(color: Colors.black87, fontWeight: FontWeight.normal, fontSize: bodyTextSize, fontFamily: 'Roboto'),
    bodyText2: TextStyle(color: Colors.black54, fontWeight: FontWeight.normal, fontSize: smallTextSize, fontFamily: 'Roboto'),
    button: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: subTitleTextSize, fontFamily: 'Roboto'),
    subtitle2: TextStyle(color: AppColor.primary, fontWeight: FontWeight.normal, fontSize: subTitleTextSize),
    headline2: TextStyle(color: AppColor.primary, fontWeight: FontWeight.normal, fontSize: subHeaderTextSize),
    headline3: TextStyle(color: Colors.black87, fontWeight: FontWeight.normal, fontSize: titleTextSize, fontFamily: 'Roboto'),
    headline4: TextStyle(color: Colors.black87, fontWeight: FontWeight.normal, fontSize: subTitleTextSize, fontFamily: 'Roboto'),
    overline: TextStyle(color: AppColor.secondary, fontWeight: FontWeight.normal, fontSize: subTitleTextSize),
  );
}

class AppColor {
  static const primary = Color(0xff059faf);
  static const primaryLight = Color(0xff1ac8db);
  static const secondary = Color(0xfffad02c);
  static const placeholderGrey = Color(0xffdddddd);
  static const darkBlue = Color(0xff0c243e);
  static const lightGreen = Color(0xff05d69e);
  static const lightBlue = Color(0xff4975e9);
  static const lightOrange = Color(0xffff8c00);
  static const darkGrey = Color(0xff8e8e8e);

}

class AppDimension {
  static const buttonHeight = 60.0;
  static const iconSizeNormal = 25.0;
  static const iconSizeSmall = 20.0;
  static const iconSizeLarge = 30.0;
  static const iconSizeExtraLarge = 40.0;
}
