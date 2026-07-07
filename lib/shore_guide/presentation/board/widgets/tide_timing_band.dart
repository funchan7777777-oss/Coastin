import 'package:flutter/cupertino.dart';

import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/tokens/shore_spacing.dart';
import '../../../domain/value_objects/tide_window_slot.dart';

class TideTimingBand extends StatelessWidget {
  const TideTimingBand({super.key, required this.tideSlots});

  final List<TideWindowSlot> tideSlots;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleColumn = constraints.maxWidth < 560;
        if (useSingleColumn) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < tideSlots.length; index++) ...[
                _TideSlotCard(tideSlot: tideSlots[index]),
                if (index != tideSlots.length - 1)
                  const SizedBox(height: ShoreSpacing.tideMd),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < tideSlots.length; index++) ...[
              Expanded(child: _TideSlotCard(tideSlot: tideSlots[index])),
              if (index != tideSlots.length - 1)
                const SizedBox(width: ShoreSpacing.tideMd),
            ],
          ],
        );
      },
    );
  }
}

class _TideSlotCard extends StatelessWidget {
  const _TideSlotCard({required this.tideSlot});

  final TideWindowSlot tideSlot;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(ShoreSpacing.tideLg),
      decoration: BoxDecoration(
        color: TidewashPalette.saltCard,
        borderRadius: BorderRadius.circular(ShoreSpacing.cardRadius),
        border: Border.all(color: TidewashPalette.pierLine),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                tideSlot.favorsBarefootWalk
                    ? CupertinoIcons.sun_max
                    : CupertinoIcons.moon_stars,
                size: 18,
                color: TidewashPalette.sunriseCoral,
              ),
              const SizedBox(width: ShoreSpacing.tideSm),
              Expanded(
                child: Text(
                  tideSlot.shorelineCue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TidewashPalette.inkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ShoreSpacing.tideSm),
          Text(
            tideSlot.readableSpan,
            style: const TextStyle(
              color: TidewashPalette.channelTeal,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: ShoreSpacing.tideSm),
          Text(
            tideSlot.waterlineBehavior,
            style: const TextStyle(
              color: TidewashPalette.harborSlate,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: ShoreSpacing.tideLg),
          _ConfidenceRail(confidenceNotches: tideSlot.confidenceNotches),
        ],
      ),
    );
  }
}

class _ConfidenceRail extends StatelessWidget {
  const _ConfidenceRail({required this.confidenceNotches});

  final int confidenceNotches;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final isFilled = index < confidenceNotches;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: index == 4 ? 0 : 4),
            decoration: BoxDecoration(
              color: isFilled
                  ? TidewashPalette.channelTeal
                  : TidewashPalette.pierLine,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
