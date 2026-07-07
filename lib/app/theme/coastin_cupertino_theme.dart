import 'package:flutter/cupertino.dart';

import 'tidewash_palette.dart';

class CoastinCupertinoTheme {
  const CoastinCupertinoTheme._();

  static CupertinoThemeData lightHarbor() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: TidewashPalette.channelTeal,
      scaffoldBackgroundColor: TidewashPalette.canvasFoam,
      barBackgroundColor: TidewashPalette.canvasFoam,
      textTheme: CupertinoTextThemeData(
        primaryColor: TidewashPalette.inkBlue,
        textStyle: TextStyle(
          color: TidewashPalette.inkBlue,
          fontSize: 16,
          height: 1.34,
        ),
        navTitleTextStyle: TextStyle(
          color: TidewashPalette.inkBlue,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: TidewashPalette.inkBlue,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
