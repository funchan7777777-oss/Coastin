import 'package:flutter/cupertino.dart';

import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/tokens/shore_spacing.dart';

class CoastalSignalChip extends StatelessWidget {
  const CoastalSignalChip({
    super.key,
    required this.saltwaterGlyph,
    required this.signalLabel,
    required this.signalValue,
    required this.washColor,
  });

  final IconData saltwaterGlyph;
  final String signalLabel;
  final String signalValue;
  final Color washColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.symmetric(
        horizontal: ShoreSpacing.tideMd,
        vertical: ShoreSpacing.tideSm,
      ),
      decoration: BoxDecoration(
        color: washColor,
        borderRadius: BorderRadius.circular(ShoreSpacing.cardRadius),
        border: Border.all(color: TidewashPalette.pierLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(saltwaterGlyph, size: 18, color: TidewashPalette.channelTeal),
          const SizedBox(width: ShoreSpacing.tideSm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  signalLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TidewashPalette.harborSlate,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  signalValue,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TidewashPalette.inkBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
