import 'package:flutter/cupertino.dart';

import '../../arrival_gate/application/coastin_entry_flow.dart';
import '../theme/coastin_cupertino_theme.dart';

class CoastinBootstrap extends StatelessWidget {
  const CoastinBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Coastin',
      debugShowCheckedModeBanner: false,
      theme: CoastinCupertinoTheme.lightHarbor(),
      builder: (context, child) {
        return DefaultTextStyle.merge(
          style: const TextStyle(
            fontFamily: CoastinFontFamilies.sans,
            fontFamilyFallback: <String>[CoastinFontFamilies.rounded],
            letterSpacing: 0,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const CoastinEntryFlow(),
    );
  }
}
