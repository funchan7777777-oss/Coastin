import 'package:flutter/cupertino.dart';

import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/tokens/shore_spacing.dart';
import '../shoreline_board_focus.dart';

class ShorelineFocusTabs extends StatelessWidget {
  const ShorelineFocusTabs({
    super.key,
    required this.chosenDeck,
    required this.onDeckChanged,
  });

  final ShorelineBoardFocus chosenDeck;
  final ValueChanged<ShorelineBoardFocus> onDeckChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<ShorelineBoardFocus>(
      groupValue: chosenDeck,
      padding: const EdgeInsets.all(ShoreSpacing.tideXs),
      backgroundColor: TidewashPalette.glassMist,
      thumbColor: TidewashPalette.saltCard,
      children: {
        for (final deck in ShorelineBoardFocus.values)
          deck: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ShoreSpacing.tideMd,
              vertical: ShoreSpacing.tideSm,
            ),
            child: Text(
              deck.switcherLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: deck == chosenDeck
                    ? TidewashPalette.inkBlue
                    : TidewashPalette.harborSlate,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      },
      onValueChanged: (nextDeck) {
        if (nextDeck != null) {
          onDeckChanged(nextDeck);
        }
      },
    );
  }
}
