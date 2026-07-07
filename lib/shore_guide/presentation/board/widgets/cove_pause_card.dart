import 'package:flutter/cupertino.dart';

import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/tokens/shore_spacing.dart';
import '../../../domain/entities/cove_pause.dart';
import '../../../domain/value_objects/cove_pause_kind.dart';

class CovePauseCard extends StatelessWidget {
  const CovePauseCard({super.key, required this.coastalPause});

  final CovePause coastalPause;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ShoreSpacing.tideLg),
      decoration: BoxDecoration(
        color: TidewashPalette.saltCard,
        borderRadius: BorderRadius.circular(ShoreSpacing.cardRadius),
        border: Border.all(color: TidewashPalette.pierLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PauseKindBadge(pauseKind: coastalPause.pauseKind),
              const SizedBox(width: ShoreSpacing.tideMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coastalPause.coveName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TidewashPalette.inkBlue,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: ShoreSpacing.tideXs),
                    Text(
                      coastalPause.approachHint,
                      style: const TextStyle(
                        color: TidewashPalette.harborSlate,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ShoreSpacing.tideSm),
              Text(
                coastalPause.unhurriedArrival,
                style: const TextStyle(
                  color: TidewashPalette.channelTeal,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: ShoreSpacing.tideLg),
          Text(
            coastalPause.locallyKnownFor,
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 15,
              height: 1.35,
            ),
          ),
          const SizedBox(height: ShoreSpacing.tideMd),
          Wrap(
            spacing: ShoreSpacing.tideSm,
            runSpacing: ShoreSpacing.tideSm,
            children: [
              _PauseFootnote(
                icon: CupertinoIcons.timer,
                label: '${coastalPause.strollingMinutes} min',
              ),
              _PauseFootnote(
                icon: coastalPause.keepsSunsetView
                    ? CupertinoIcons.sunset
                    : CupertinoIcons.cloud_sun,
                label: coastalPause.keepsSunsetView
                    ? 'Sunset view'
                    : 'Daylight',
              ),
            ],
          ),
          const SizedBox(height: ShoreSpacing.tideMd),
          Text(
            coastalPause.pocketNote,
            style: const TextStyle(
              color: TidewashPalette.harborSlate,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PauseKindBadge extends StatelessWidget {
  const _PauseKindBadge({required this.pauseKind});

  final CovePauseKind pauseKind;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: TidewashPalette.glassMist,
        borderRadius: BorderRadius.circular(ShoreSpacing.cardRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _glyphForPauseKind(pauseKind),
            size: 18,
            color: TidewashPalette.channelTeal,
          ),
          const SizedBox(height: 2),
          Text(
            pauseKind.harborLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _glyphForPauseKind(CovePauseKind pauseKind) {
    return switch (pauseKind) {
      CovePauseKind.boardwalk => CupertinoIcons.map,
      CovePauseKind.overlook => CupertinoIcons.eye,
      CovePauseKind.swimBreak => CupertinoIcons.drop,
      CovePauseKind.marketStop => CupertinoIcons.bag,
      CovePauseKind.quietTable => CupertinoIcons.table,
    };
  }
}

class _PauseFootnote extends StatelessWidget {
  const _PauseFootnote({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ShoreSpacing.tideSm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: TidewashPalette.canvasFoam,
        borderRadius: BorderRadius.circular(ShoreSpacing.cardRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: TidewashPalette.kelpGreen),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: TidewashPalette.harborSlate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
