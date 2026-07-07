import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../domain/entities/shoreline_persona.dart';
import '../../../domain/value_objects/shore_profile_current.dart';

class MomentActionRail extends StatelessWidget {
  const MomentActionRail({
    super.key,
    required this.creatorPersona,
    required this.isLiked,
    required this.isPaused,
    required this.likeCount,
    required this.replyCount,
    required this.infoCount,
    required this.onLikeTap,
    required this.onPlayTap,
    required this.onCommentTap,
    required this.onInfoTap,
  });

  final ShorelinePersona creatorPersona;
  final bool isLiked;
  final bool isPaused;
  final int likeCount;
  final int replyCount;
  final int infoCount;
  final VoidCallback onLikeTap;
  final VoidCallback onPlayTap;
  final VoidCallback onCommentTap;
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 160,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MomentPortraitBubble(creatorPersona: creatorPersona),
          const SizedBox(height: 24),
          _MomentImageButton(
            asset: isLiked
                ? CoastinAssetRegistry.likeLitBadge
                : CoastinAssetRegistry.likeRestingBadge,
            spokenLabel: isLiked ? 'Remove coast like' : 'Send coast like',
            onTap: onLikeTap,
          ),
          _CountWash(count: likeCount),
          const SizedBox(height: 12),
          _MomentImageButton(
            asset: isPaused
                ? CoastinAssetRegistry.playRoundBadge
                : CoastinAssetRegistry.pauseRoundBadge,
            spokenLabel: isPaused ? 'Play video' : 'Pause video',
            onTap: onPlayTap,
          ),
          const SizedBox(height: 14),
          _MomentImageButton(
            asset: CoastinAssetRegistry.commentRoundBadge,
            spokenLabel: 'Open comments',
            onTap: onCommentTap,
          ),
          _CountWash(count: replyCount),
          const SizedBox(height: 14),
          _MomentImageButton(
            asset: CoastinAssetRegistry.infoRoundBadge,
            spokenLabel: 'Open safety choices',
            onTap: onInfoTap,
          ),
          _CountWash(count: infoCount),
        ],
      ),
    );
  }
}

class _MomentPortraitBubble extends StatelessWidget {
  const _MomentPortraitBubble({required this.creatorPersona});

  final ShorelinePersona creatorPersona;

  @override
  Widget build(BuildContext context) {
    final genderGlyph =
        creatorPersona.profileCurrent == ShoreProfileCurrent.feminine
        ? CoastinAssetRegistry.feminineTideGlyph
        : CoastinAssetRegistry.masculineTideGlyph;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFFFFF), width: 1.6),
          ),
          child: ClipOval(
            child: Image.asset(
              creatorPersona.avatarAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -3,
          child: Container(
            width: 20,
            height: 20,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFFFFF),
            ),
            child: Image.asset(genderGlyph, fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }
}

class _MomentImageButton extends StatelessWidget {
  const _MomentImageButton({
    required this.asset,
    required this.spokenLabel,
    required this.onTap,
  });

  final String asset;
  final String spokenLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: spokenLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 54,
          height: 54,
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class _CountWash extends StatelessWidget {
  const _CountWash({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        _compactCount(count),
        style: const TextStyle(
          color: TidewashPalette.saltCard,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(
              color: Color(0xAA0A2231),
              blurRadius: 8,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  String _compactCount(int value) {
    if (value >= 1000) {
      return '999+';
    }
    return '$value';
  }
}
