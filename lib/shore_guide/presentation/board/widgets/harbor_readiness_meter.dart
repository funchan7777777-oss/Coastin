import 'package:flutter/cupertino.dart';

import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/tokens/shore_spacing.dart';
import '../../../domain/entities/harbor_readiness_note.dart';

class HarborReadinessMeter extends StatelessWidget {
  const HarborReadinessMeter({
    super.key,
    required this.shorelineEaseScore,
    required this.breezeKnots,
    required this.readinessNotes,
  });

  final int shorelineEaseScore;
  final double breezeKnots;
  final List<HarborReadinessNote> readinessNotes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ShoreSpacing.tideLg),
      decoration: BoxDecoration(
        color: TidewashPalette.nightFerry,
        borderRadius: BorderRadius.circular(ShoreSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Shore readiness',
                  style: TextStyle(
                    color: TidewashPalette.saltCard,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$shorelineEaseScore',
                style: const TextStyle(
                  color: TidewashPalette.buoyGold,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: ShoreSpacing.tideSm),
          Text(
            '${breezeKnots.toStringAsFixed(1)} kt breeze with a steady route.',
            style: TextStyle(
              color: TidewashPalette.saltCard.withValues(alpha: 0.78),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: ShoreSpacing.tideLg),
          for (final note in readinessNotes) ...[
            _ReadinessRow(readinessNote: note),
            if (note != readinessNotes.last)
              const SizedBox(height: ShoreSpacing.tideMd),
          ],
        ],
      ),
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  const _ReadinessRow({required this.readinessNote});

  final HarborReadinessNote readinessNote;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TidewashPalette.saltCard.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(ShoreSpacing.cardRadius),
          ),
          child: Text(
            readinessNote.laneMarker,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TidewashPalette.buoyGold,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: ShoreSpacing.tideMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                readinessNote.readinessLine,
                style: const TextStyle(
                  color: TidewashPalette.saltCard,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: ShoreSpacing.tideXs),
              Text(
                readinessNote.tuckAwayHint,
                style: TextStyle(
                  color: TidewashPalette.saltCard.withValues(alpha: 0.66),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: ShoreSpacing.tideSm),
        _WeightMarks(filledMarks: readinessNote.checkWeight),
      ],
    );
  }
}

class _WeightMarks extends StatelessWidget {
  const _WeightMarks({required this.filledMarks});

  final int filledMarks;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isFilled = index < filledMarks;
        return Container(
          width: 6,
          height: 18,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            color: isFilled
                ? TidewashPalette.sunriseCoral
                : TidewashPalette.saltCard.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
