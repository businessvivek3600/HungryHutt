import 'package:flutter/material.dart';

// Additional text themes
TextStyle boldCaptionStyle(BuildContext context) => Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold);

TextStyle normalCaptionStyle(BuildContext context) => Theme.of(context).textTheme.bodySmall!.copyWith(
  // color: Colors.grey,
  fontSize: 14,
);

TextStyle normalHeadingStyle(BuildContext context) => Theme.of(context).textTheme.titleLarge!.copyWith(
  fontWeight: FontWeight.normal,
);

TextStyle textFieldHintStyle(BuildContext context) => Theme.of(context).textTheme.bodySmall!.copyWith(
  // color: Colors.grey[500],
  fontWeight: FontWeight.normal,
  fontSize: 15,
);

TextStyle textFieldInputStyle(BuildContext context, FontWeight? fontWeight) => Theme.of(context).textTheme.bodyLarge!.copyWith(
  // color: Colors.black,
  fontSize: 18,
  fontWeight: fontWeight ?? FontWeight.normal,
);

class ThemeUtils {
  static const Color primaryColor = Color(0xFF68a039);

  static final ThemeData defaultAppThemeData = ThemeData(
    fontFamily: "Google-Sans",
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black),
    ),
  );

  static final ThemeData darkAppThemData = ThemeData(
    fontFamily: "Google-Sans",
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.black,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white),
    ),
  );
}

