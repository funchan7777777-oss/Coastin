import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../cerulean_tab_berth.dart';

class CeruleanTripTabbar extends StatelessWidget {
  const CeruleanTripTabbar({
    super.key,
    required this.currentBerth,
    required this.onBerthChanged,
  });

  static const double boardWidth = 410;
  static const double boardHeight = 85;
  static const double glyphEdge = 24;

  final CeruleanTabBerth currentBerth;
  final ValueChanged<CeruleanTabBerth> onBerthChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dockWidth = math.min(boardWidth, constraints.maxWidth);
        final dockHeight = dockWidth * boardHeight / boardWidth;

        return SizedBox(
          width: double.infinity,
          height: dockHeight,
          child: Center(
            child: SizedBox(
              width: dockWidth,
              height: dockHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    CoastinAssetRegistry.ceruleanTripDock,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final berth in CeruleanTabBerth.values)
                        _CeruleanGlyphButton(
                          tabBerth: berth,
                          isCurrent: berth == currentBerth,
                          onTap: () => onBerthChanged(berth),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CeruleanGlyphButton extends StatelessWidget {
  const _CeruleanGlyphButton({
    required this.tabBerth,
    required this.isCurrent,
    required this.onTap,
  });

  final CeruleanTabBerth tabBerth;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isCurrent,
      label: tabBerth.spokenName,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: CeruleanTripTabbar.glyphEdge,
          height: CeruleanTripTabbar.glyphEdge,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Image.asset(
              isCurrent ? tabBerth.activeGlyph : tabBerth.quietGlyph,
              key: ValueKey('${tabBerth.name}-$isCurrent'),
              width: CeruleanTripTabbar.glyphEdge,
              height: CeruleanTripTabbar.glyphEdge,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
