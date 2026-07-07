import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';

class SeaBuddyTopBar extends StatelessWidget {
  const SeaBuddyTopBar({
    super.key,
    required this.title,
    required this.onBack,
    this.onInfo,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              CupertinoIcons.chevron_left,
              color: TidewashPalette.inkBlue,
              size: 28,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onInfo,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Center(
              child: onInfo == null
                  ? const SizedBox.shrink()
                  : Image.asset(
                      CoastinAssetRegistry.aquaInfoGlyph,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
