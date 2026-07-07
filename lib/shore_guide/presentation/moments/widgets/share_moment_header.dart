import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';

class ShareMomentHeader extends StatelessWidget {
  const ShareMomentHeader({super.key, required this.onReleaseTap});

  final VoidCallback onReleaseTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      top: 58,
      child: Row(
        children: [
          Image.asset(
            CoastinAssetRegistry.shareMomentWordmark,
            width: 168,
            height: 24,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onReleaseTap,
            child: SizedBox(
              width: 56,
              height: 42,
              child: Image.asset(
                CoastinAssetRegistry.postReleaseGlyph,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
