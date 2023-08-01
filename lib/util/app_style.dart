import 'package:flutter/material.dart';

class AppTextStyle {
  static const double captionTextSize = 32;
  static const double headerTextSize = 24;
  static const double subHeaderTextSize = 20;
  static const double titleTextSize = 18;
  static const double subTitleTextSize = 17;
  static const double bodyTextSize = 15;
  static const double smallTextSize = 14;
  static const double extraSmallTextSize = 12;
  
  static const TextTheme appTextTheme = TextTheme(
    displayLarge: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold, fontSize: 36),
    displayMedium: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold, fontSize: 30),
    displaySmall: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold, fontSize: 24),
    headlineLarge: TextStyle(color: AppColor.primary, fontWeight: FontWeight.normal, fontSize: 28),
    headlineMedium: TextStyle(color: AppColor.primary, fontWeight: FontWeight.normal, fontSize: 22),
    headlineSmall: TextStyle(color: AppColor.primary, fontWeight: FontWeight.normal, fontSize: 18),
    titleLarge: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold, fontSize: 24),
    titleMedium: TextStyle(color: AppColor.primary, fontWeight: FontWeight.normal, fontSize: 20),
    titleSmall: TextStyle(color: AppColor.primary, fontWeight: FontWeight.normal, fontSize: 18),
    bodyLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.normal, fontSize: 16, fontFamily: 'Roboto'),
    bodyMedium: TextStyle(color: Colors.black54, fontWeight: FontWeight.normal, fontSize: 15, fontFamily: 'Roboto'),
    bodySmall: TextStyle(color: Colors.black54, fontWeight: FontWeight.normal, fontSize: 14, fontFamily: 'Roboto'),
    labelLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.normal, fontSize: 16, fontFamily: 'NotoSans'),
    labelMedium: TextStyle(color: Colors.black54, fontWeight: FontWeight.normal, fontSize: 15, fontFamily: 'NotoSans'),
    labelSmall: TextStyle(color: Colors.black54, fontWeight: FontWeight.normal, fontSize: 14, fontFamily: 'NotoSans'),
  );
}

class AppColor {
  static const primary = Color(0xff059faf);
  static const primaryLight = Color(0xff1ac8db);
  static const secondary = Color(0xfffad02c);
  static const placeholderGrey = Color(0xffdddddd);
  static const darkBlue = Color(0xff0c243e);
  static const lightGreen = Color(0xff05d69e);
  static const lightBlue = Color(0xff71D8E8);
  static const orange = Color(0xffff8c00);
  static const lightOrange = Color(0xffF4BC7F);
  static const lightPink = Color(0xffE9D4D6);
  static const darkGrey = Color(0xff8e8e8e);

}

class AppDimension {
  static const buttonHeight = 60.0;
  static const iconSizeNormal = 25.0;
  static const iconSizeSmall = 20.0;
  static const iconSizeLarge = 30.0;
  static const iconSizeExtraLarge = 40.0;
}
