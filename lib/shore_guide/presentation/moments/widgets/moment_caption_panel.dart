import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../domain/entities/shore_video_moment.dart';

class MomentCaptionPanel extends StatelessWidget {
  const MomentCaptionPanel({
    super.key,
    required this.shoreMoment,
    required this.isFollowed,
    required this.bottomDockClearance,
    required this.onFollowTap,
    required this.onPersonaTap,
  });

  final ShoreVideoMoment shoreMoment;
  final bool isFollowed;
  final double bottomDockClearance;
  final VoidCallback onFollowTap;
  final VoidCallback onPersonaTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: bottomDockClearance + 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onPersonaTap,
                  child: Text(
                    shoreMoment.creatorPersona.displayHarborName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: TidewashPalette.saltCard,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      shadows: [_darkShoreShadow],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onFollowTap,
                child: SizedBox(
                  width: 76,
                  height: 32,
                  child: Image.asset(
                    isFollowed
                        ? CoastinAssetRegistry.followedBadge
                        : CoastinAssetRegistry.followBadge,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                CupertinoIcons.location_solid,
                color: Color(0xFFFF5FA7),
                size: 16,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  shoreMoment.placeRibbon,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF62C9FF),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    shadows: [_darkShoreShadow],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Posted ${shoreMoment.clockRibbon}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFEAFBFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  shadows: [_darkShoreShadow],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            shoreMoment.captionTide,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TidewashPalette.saltCard,
              fontSize: 15,
              height: 1.25,
              fontWeight: FontWeight.w700,
              shadows: [_darkShoreShadow],
            ),
          ),
        ],
      ),
    );
  }
}

const Shadow _darkShoreShadow = Shadow(
  color: Color(0xCC0A2231),
  blurRadius: 9,
  offset: Offset(0, 1),
);
