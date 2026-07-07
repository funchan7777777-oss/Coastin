import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/tokens/shore_spacing.dart';

class CoralGalleryPage extends StatelessWidget {
  const CoralGalleryPage({super.key, required this.bottomDockClearance});

  final double bottomDockClearance;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: TidewashPalette.canvasFoam,
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                ShoreSpacing.tideLg,
                54,
                ShoreSpacing.tideLg,
                bottomDockClearance + ShoreSpacing.tideLg,
              ),
              sliver: SliverList.list(
                children: const [
                  _CoralGalleryHeader(),
                  SizedBox(height: ShoreSpacing.tideLg),
                  _CoralMemoryTile(
                    frameAsset: CoastinAssetRegistry.surferProfileTile,
                    shellName: 'Outer foam ride',
                    shellCaption:
                        'A bright boardwalk stop after the morning tide.',
                  ),
                  SizedBox(height: ShoreSpacing.tideMd),
                  _CoralMemoryTile(
                    frameAsset: CoastinAssetRegistry.sundanceProfileTile,
                    shellName: 'Warm cove spark',
                    shellCaption: 'Saved for the late-sun walk near the palms.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoralGalleryHeader extends StatelessWidget {
  const _CoralGalleryHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coral Gallery',
          style: TextStyle(
            color: TidewashPalette.inkBlue,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: ShoreSpacing.tideSm),
        Text(
          'Pinned snapshots from the day.',
          style: TextStyle(
            color: TidewashPalette.harborSlate,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CoralMemoryTile extends StatelessWidget {
  const _CoralMemoryTile({
    required this.frameAsset,
    required this.shellName,
    required this.shellCaption,
  });

  final String frameAsset;
  final String shellName;
  final String shellCaption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ShoreSpacing.tideMd),
      decoration: BoxDecoration(
        color: TidewashPalette.saltCard,
        borderRadius: BorderRadius.circular(ShoreSpacing.cardRadius),
        border: Border.all(color: TidewashPalette.pierLine),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ShoreSpacing.cardRadius),
            child: Image.asset(
              frameAsset,
              width: 86,
              height: 86,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: ShoreSpacing.tideMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shellName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TidewashPalette.inkBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: ShoreSpacing.tideXs),
                Text(
                  shellCaption,
                  style: const TextStyle(
                    color: TidewashPalette.harborSlate,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
