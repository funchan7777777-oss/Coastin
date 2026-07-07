import 'package:flutter/cupertino.dart';

import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/tokens/shore_spacing.dart';
import '../../../domain/entities/shoreline_day_plan.dart';
import 'coastal_signal_chip.dart';

class ShorelineHeaderBand extends StatelessWidget {
  const ShorelineHeaderBand({super.key, required this.harborBoard});

  final ShorelineDayPlan harborBoard;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TidewashPalette.glassMist,
        border: Border(bottom: BorderSide(color: TidewashPalette.pierLine)),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ShoreSpacing.boardMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              ShoreSpacing.tideLg,
              ShoreSpacing.tideXl,
              ShoreSpacing.tideLg,
              ShoreSpacing.tideXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  harborBoard.datelineLabel,
                  style: const TextStyle(
                    color: TidewashPalette.channelTeal,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: ShoreSpacing.tideSm),
                Text(
                  harborBoard.boardTitle,
                  style: const TextStyle(
                    color: TidewashPalette.inkBlue,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: ShoreSpacing.tideMd),
                Text(
                  harborBoard.greetingLine,
                  style: const TextStyle(
                    color: TidewashPalette.inkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: ShoreSpacing.tideSm),
                Text(
                  harborBoard.saltAirSummary,
                  style: const TextStyle(
                    color: TidewashPalette.harborSlate,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: ShoreSpacing.tideLg),
                Wrap(
                  spacing: ShoreSpacing.tideSm,
                  runSpacing: ShoreSpacing.tideSm,
                  children: [
                    CoastalSignalChip(
                      saltwaterGlyph: CupertinoIcons.map_pin_ellipse,
                      signalLabel: 'Stretch',
                      signalValue: harborBoard.currentStretchName,
                      washColor: TidewashPalette.saltCard,
                    ),
                    CoastalSignalChip(
                      saltwaterGlyph: CupertinoIcons.cloud_sun,
                      signalLabel: 'Weather',
                      signalValue: harborBoard.weatherTexture,
                      washColor: TidewashPalette.saltCard,
                    ),
                    CoastalSignalChip(
                      saltwaterGlyph: CupertinoIcons.arrow_2_circlepath,
                      signalLabel: 'Pace',
                      signalValue: harborBoard.preferredPace,
                      washColor: TidewashPalette.saltCard,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
