import 'package:flutter/cupertino.dart';

import '../../../app/theme/tidewash_palette.dart';
import '../../../shared/ui/tokens/shore_spacing.dart';
import '../../domain/entities/shoreline_day_plan.dart';
import 'shoreline_board_focus.dart';
import 'widgets/cove_pause_card.dart';
import 'widgets/harbor_readiness_meter.dart';
import 'widgets/shoreline_focus_tabs.dart';
import 'widgets/shoreline_header_band.dart';
import 'widgets/tide_timing_band.dart';

class ShorelineBoardPage extends StatefulWidget {
  const ShorelineBoardPage({super.key, required this.harborBoard});

  final ShorelineDayPlan harborBoard;

  @override
  State<ShorelineBoardPage> createState() => _ShorelineBoardPageState();
}

class _ShorelineBoardPageState extends State<ShorelineBoardPage> {
  ShorelineBoardFocus _selectedBoardFocus = ShorelineBoardFocus.dayflow;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Coastin'),
        trailing: Icon(CupertinoIcons.compass),
      ),
      backgroundColor: TidewashPalette.canvasFoam,
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ShorelineHeaderBand(harborBoard: widget.harborBoard),
            ),
            SliverToBoxAdapter(
              child: _BoardContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HarborReadinessMeter(
                      shorelineEaseScore: widget.harborBoard.shorelineEaseScore,
                      breezeKnots: widget.harborBoard.breezeKnots,
                      readinessNotes: widget.harborBoard.readinessNotes,
                    ),
                    const SizedBox(height: ShoreSpacing.tideLg),
                    ShorelineFocusTabs(
                      chosenDeck: _selectedBoardFocus,
                      onDeckChanged: (nextDeck) {
                        setState(() => _selectedBoardFocus = nextDeck);
                      },
                    ),
                    const SizedBox(height: ShoreSpacing.tideLg),
                    _FocusedBoardSection(
                      harborBoard: widget.harborBoard,
                      selectedBoardFocus: _selectedBoardFocus,
                    ),
                    const SizedBox(height: ShoreSpacing.tideXl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardContentFrame extends StatelessWidget {
  const _BoardContentFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ShoreSpacing.boardMaxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ShoreSpacing.tideLg,
            ShoreSpacing.tideLg,
            ShoreSpacing.tideLg,
            0,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FocusedBoardSection extends StatelessWidget {
  const _FocusedBoardSection({
    required this.harborBoard,
    required this.selectedBoardFocus,
  });

  final ShorelineDayPlan harborBoard;
  final ShorelineBoardFocus selectedBoardFocus;

  @override
  Widget build(BuildContext context) {
    return switch (selectedBoardFocus) {
      ShorelineBoardFocus.dayflow => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TideTimingBand(tideSlots: harborBoard.tideSlots.take(2).toList()),
          const SizedBox(height: ShoreSpacing.tideMd),
          for (final pause in harborBoard.covePauses.take(2)) ...[
            CovePauseCard(coastalPause: pause),
            const SizedBox(height: ShoreSpacing.tideMd),
          ],
        ],
      ),
      ShorelineBoardFocus.waterline => TideTimingBand(
        tideSlots: harborBoard.tideSlots,
      ),
      ShorelineBoardFocus.pauses => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final pause in harborBoard.covePauses) ...[
            CovePauseCard(coastalPause: pause),
            const SizedBox(height: ShoreSpacing.tideMd),
          ],
        ],
      ),
    };
  }
}
