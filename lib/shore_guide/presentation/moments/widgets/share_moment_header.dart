import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';

class ShareMomentHeader extends StatelessWidget {
  const ShareMomentHeader({
    super.key,
    required this.onReleaseTap,
    this.onBackTap,
    this.showReleaseAction = true,
  });

  final VoidCallback onReleaseTap;
  final VoidCallback? onBackTap;
  final bool showReleaseAction;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      top: 58,
      child: Row(
        children: [
          if (onBackTap != null) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBackTap,
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  CupertinoIcons.chevron_left,
                  color: Color(0xFFFFFFFF),
                  size: 30,
                  shadows: [
                    Shadow(
                      color: Color(0x990A2231),
                      blurRadius: 8,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Image.asset(
            CoastinAssetRegistry.shareMomentWordmark,
            width: onBackTap == null ? 168 : 142,
            height: 24,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const Spacer(),
          if (showReleaseAction)
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
            )
          else
            const SizedBox(width: 56, height: 42),
        ],
      ),
    );
  }
}
