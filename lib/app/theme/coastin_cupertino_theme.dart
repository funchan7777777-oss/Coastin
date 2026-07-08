import 'package:flutter/cupertino.dart';

import 'tidewash_palette.dart';

class CoastinFontFamilies {
  const CoastinFontFamilies._();

  static const String sans = 'CoastinSans';
  static const String rounded = 'CoastinRounded';
  static const String script = 'CoastinScript';
}

class CoastinCupertinoTheme {
  const CoastinCupertinoTheme._();

  static CupertinoThemeData lightHarbor() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: TidewashPalette.channelTeal,
      scaffoldBackgroundColor: TidewashPalette.canvasFoam,
      barBackgroundColor: TidewashPalette.canvasFoam,
      applyThemeToAll: true,
      textTheme: CupertinoTextThemeData(
        primaryColor: TidewashPalette.inkBlue,
        textStyle: TextStyle(
          fontFamily: CoastinFontFamilies.sans,
          fontFamilyFallback: <String>[CoastinFontFamilies.rounded],
          color: TidewashPalette.inkBlue,
          fontSize: 16,
          height: 1.34,
          letterSpacing: 0,
        ),
        actionTextStyle: TextStyle(
          fontFamily: CoastinFontFamilies.rounded,
          fontFamilyFallback: <String>[CoastinFontFamilies.sans],
          color: TidewashPalette.channelTeal,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        actionSmallTextStyle: TextStyle(
          fontFamily: CoastinFontFamilies.rounded,
          fontFamilyFallback: <String>[CoastinFontFamilies.sans],
          color: TidewashPalette.channelTeal,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: CoastinFontFamilies.rounded,
          fontFamilyFallback: <String>[CoastinFontFamilies.sans],
          color: TidewashPalette.harborSlate,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: CoastinFontFamilies.rounded,
          fontFamilyFallback: <String>[CoastinFontFamilies.sans],
          color: TidewashPalette.inkBlue,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: CoastinFontFamilies.rounded,
          fontFamilyFallback: <String>[CoastinFontFamilies.sans],
          color: TidewashPalette.inkBlue,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        navActionTextStyle: TextStyle(
          fontFamily: CoastinFontFamilies.rounded,
          fontFamilyFallback: <String>[CoastinFontFamilies.sans],
          color: TidewashPalette.channelTeal,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        pickerTextStyle: TextStyle(
          fontFamily: CoastinFontFamilies.sans,
          fontFamilyFallback: <String>[CoastinFontFamilies.rounded],
          color: TidewashPalette.inkBlue,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        dateTimePickerTextStyle: TextStyle(
          fontFamily: CoastinFontFamilies.sans,
          fontFamilyFallback: <String>[CoastinFontFamilies.rounded],
          color: TidewashPalette.inkBlue,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
