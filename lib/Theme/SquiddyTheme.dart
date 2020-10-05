import 'package:flutter/material.dart';

class SquiddyTheme {
  static const MaterialAccentColor squiddyPrimary = MaterialAccentColor(
    _squiddyPrimaryValue,
    <int, Color>{
      50: Color(0xFFFCEAF5),
      100: Color(0xFFF7CAE5),
      200: Color(0xFFF2A7D4),
      300: Color(0xFFEC83C2),
      400: Color(0xFFE869B5),
      500: Color(_squiddyPrimaryValue),
      600: Color(0xFFE147A0),
      700: Color(0xFFDD3D97),
      800: Color(0xFFD9358D),
      900: Color(0xFFD1257D),
    },
  );
  static const int _squiddyPrimaryValue = 0xFFE44EA8;

  static const MaterialAccentColor squiddySecondary = MaterialAccentColor(
    _squiddySecondaryValue,
    <int, Color>{
      50: Color(0xFFECF8FA),
      100: Color(0xFFD0ECF2),
      200: Color(0xFFB0E0E9),
      300: Color(0xFF90D4E0),
      400: Color(0xFF79CADA),
      500: Color(_squiddySecondaryValue),
      600: Color(0xFF59BBCE),
      700: Color(0xFF4FB3C8),
      800: Color(0xFF45ABC2),
      900: Color(0xFF339EB7),
    },
  );
  static const int _squiddySecondaryValue = 0xFF61C1D3;

  static const MaterialAccentColor squiddyNeutrals = MaterialAccentColor(
    _squiddyNeutralValue,
    <int, Color>{
      50: Color(0xFFF0F4F8),
      100: Color(0xFFD9E2EC),
      200: Color(0xFFBCCCDC),
      300: Color(0xFF9FB3C8),
      400: Color(0xFF829AB1),
      500: Color(_squiddyNeutralValue),
      600: Color(0xFF486581),
      700: Color(0xFF334E68),
      800: Color(0xFF243B53),
      900: Color(0xFF102A43),
    },
  );
  static const int _squiddyNeutralValue = 0xFF627D98;

  static const MaterialAccentColor squiddySupport1 = MaterialAccentColor(
    _squiddySupport1Value,
    <int, Color>{
      50: Color(0xFFE0FCFF),
      100: Color(0xFFBEF8FD),
      200: Color(0xFF87EAF2),
      300: Color(0xFF54D1DB),
      400: Color(0xFF38BEC9),
      500: Color(_squiddySupport1Value),
      600: Color(0xFF14919B),
      700: Color(0xFF0E7C86),
      800: Color(0xFF0A6C74),
      900: Color(0xFF044E54),
    },
  );
  static const int _squiddySupport1Value = 0xFF2CB1BC;

  static const MaterialAccentColor squiddySupport2 = MaterialAccentColor(
    _squiddySupport2Value,
    <int, Color>{
      50: Color(0xFFFFEEEE),
      100: Color(0xFFFACDCD),
      200: Color(0xFFF29B9B),
      300: Color(0xFFE66A6A),
      400: Color(0xFFD64545),
      500: Color(_squiddySupport2Value),
      600: Color(0xFFA61B1B),
      700: Color(0xFF911111),
      800: Color(0xFF780A0A),
      900: Color(0xFF610404),
    },
  );
  static const int _squiddySupport2Value = 0xFFBA2525;

  static Color snackBarBackground() {
    return squiddySecondary[600];
  }

  static Widget squiddytHeadingBig2(String text, {Color color}) {
    return Padding(
        padding: EdgeInsets.fromLTRB(7, 7, 10, 10),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color:
                  color ?? HSLColor.fromAHSL(1.0, 209.0, 0.34, 0.30).toColor()),
        ));
  }

  static ThemeData defaultSquiddyTheme({Brightness brightness}) {
    return ThemeData(
        primaryColor: SquiddyTheme.squiddyPrimary,
        accentColor: SquiddyTheme.squiddySecondary,
// accentColorBrightness: Brightness.dark
        brightness: brightness ?? Brightness.light);
  }
}
