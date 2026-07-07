import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../harbor_access_mode.dart';

class HarborModeRibbon extends StatelessWidget {
  const HarborModeRibbon({
    super.key,
    required this.anchoredAccessMode,
    required this.onAccessModeChosen,
  });

  final HarborAccessMode anchoredAccessMode;
  final ValueChanged<HarborAccessMode> onAccessModeChosen;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RibbonImageChoice(
          waveAsset: anchoredAccessMode == HarborAccessMode.returningCrew
              ? CoastinAssetRegistry.activePierLogin
              : CoastinAssetRegistry.restingPierLogin,
          semanticCurrent: 'log in',
          onPressed: () => onAccessModeChosen(HarborAccessMode.returningCrew),
        ),
        _RibbonImageChoice(
          waveAsset: anchoredAccessMode == HarborAccessMode.newShoreline
              ? CoastinAssetRegistry.activePierSignup
              : CoastinAssetRegistry.restingPierSignup,
          semanticCurrent: 'sign up',
          onPressed: () => onAccessModeChosen(HarborAccessMode.newShoreline),
        ),
      ],
    );
  }
}

class _RibbonImageChoice extends StatelessWidget {
  const _RibbonImageChoice({
    required this.waveAsset,
    required this.semanticCurrent,
    required this.onPressed,
  });

  final String waveAsset;
  final String semanticCurrent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Semantics(
        button: true,
        label: semanticCurrent,
        child: Image.asset(waveAsset, width: 112, height: 39, fit: BoxFit.fill),
      ),
    );
  }
}
