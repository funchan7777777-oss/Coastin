import 'package:flutter/cupertino.dart';

import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/tokens/shore_spacing.dart';
import '../../../domain/entities/shoreline_day_plan.dart';
import '../../../domain/value_objects/tide_window_slot.dart';

class CoveRoutePlannerPage extends StatefulWidget {
  const CoveRoutePlannerPage({super.key, required this.harborBoard});

  final ShorelineDayPlan harborBoard;

  @override
  State<CoveRoutePlannerPage> createState() => _CoveRoutePlannerPageState();
}

class _CoveRoutePlannerPageState extends State<CoveRoutePlannerPage> {
  int _selectedTideIndex = 1;
  _RoutePace _routePace = _RoutePace.easy;
  _ShadeNeed _shadeNeed = _ShadeNeed.balanced;
  bool _quietEdges = true;
  bool _planSaved = false;
  final Set<String> _packedKit = <String>{};

  TideWindowSlot get _selectedTideSlot {
    return widget.harborBoard.tideSlots[_selectedTideIndex];
  }

  int get _comfortScore {
    final tideWeight = _selectedTideSlot.confidenceNotches * 9;
    final paceWeight = _routePace.scoreWeight;
    final shadeWeight = _shadeNeed.scoreWeight;
    final quietWeight = _quietEdges ? 8 : 1;
    final noonDrag = _selectedTideIndex == 1 && _shadeNeed == _ShadeNeed.open
        ? 7
        : 0;
    final score =
        42 + tideWeight + paceWeight + shadeWeight + quietWeight - noonDrag;
    return score.clamp(52, 96).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE6FFF8),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            const Positioned.fill(child: _PlannerWash()),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 54, 20, 34),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PlannerTopBar(
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 20),
                        _PlannerHero(harborBoard: widget.harborBoard),
                        const SizedBox(height: 18),
                        _PlannerCard(
                          title: 'Tide window',
                          child: _TideWindowPicker(
                            tideSlots: widget.harborBoard.tideSlots,
                            selectedIndex: _selectedTideIndex,
                            onChanged: (nextIndex) {
                              setState(() => _selectedTideIndex = nextIndex);
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        _PlannerCard(
                          title: 'Route feel',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ChoiceStrip<_RoutePace>(
                                values: _RoutePace.values,
                                selectedValue: _routePace,
                                labelFor: (value) => value.label,
                                onChanged: (value) {
                                  setState(() => _routePace = value);
                                },
                              ),
                              const SizedBox(height: 12),
                              _ChoiceStrip<_ShadeNeed>(
                                values: _ShadeNeed.values,
                                selectedValue: _shadeNeed,
                                labelFor: (value) => value.label,
                                onChanged: (value) {
                                  setState(() => _shadeNeed = value);
                                },
                              ),
                              const SizedBox(height: 12),
                              _QuietEdgeToggle(
                                quietEdges: _quietEdges,
                                onChanged: (value) {
                                  setState(() => _quietEdges = value);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _RouteBriefCard(
                          comfortScore: _comfortScore,
                          tideSlot: _selectedTideSlot,
                          routePace: _routePace,
                          shadeNeed: _shadeNeed,
                          quietEdges: _quietEdges,
                          harborBoard: widget.harborBoard,
                        ),
                        const SizedBox(height: 14),
                        _PlannerCard(
                          title: 'Cove kit',
                          child: Column(
                            children: [
                              for (final kitItem in _kitItems) ...[
                                _KitRow(
                                  label: kitItem,
                                  isPacked: _packedKit.contains(kitItem),
                                  onTap: () {
                                    setState(() {
                                      if (!_packedKit.add(kitItem)) {
                                        _packedKit.remove(kitItem);
                                      }
                                    });
                                  },
                                ),
                                if (kitItem != _kitItems.last)
                                  const SizedBox(height: 8),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _SavePlanButton(
                          isSaved: _planSaved,
                          onTap: () {
                            setState(() => _planSaved = !_planSaved);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Comfort notes are local planning prompts only. Check posted signs, weather, water conditions, and your own limits before heading out.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TidewashPalette.harborSlate.withValues(
                              alpha: 0.72,
                            ),
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _RoutePace {
  easy('Easy walk', 'Short pauses and a smooth return.', 12),
  photo('Photo pace', 'Hold the brightest stops longer.', 8),
  market('Market stop', 'Leave room for water and a snack.', 10);

  const _RoutePace(this.label, this.note, this.scoreWeight);

  final String label;
  final String note;
  final int scoreWeight;
}

enum _ShadeNeed {
  balanced('Balanced', 'Mix open water views with shaded rails.', 11),
  shade('More shade', 'Favor benches, palms, and covered edges.', 14),
  open('Open light', 'Keep the route bright for photos.', 6);

  const _ShadeNeed(this.label, this.note, this.scoreWeight);

  final String label;
  final String note;
  final int scoreWeight;
}

const List<String> _kitItems = [
  'Water bottle before the longest open stretch',
  'Brimmed cap or shade layer',
  'Small towel for rail and bench pauses',
  'Backup route if the beach edge narrows',
];

class _PlannerWash extends StatelessWidget {
  const _PlannerWash();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF7DA),
            const Color(0xFFEAF8EA),
            const Color(0xFFB9F8F0).withValues(alpha: 0.98),
          ],
        ),
      ),
    );
  }
}

class _PlannerTopBar extends StatelessWidget {
  const _PlannerTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              CupertinoIcons.chevron_left,
              color: TidewashPalette.inkBlue,
              size: 28,
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'Cove planner',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }
}

class _PlannerHero extends StatelessWidget {
  const _PlannerHero({required this.harborBoard});

  final ShorelineDayPlan harborBoard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFC9F9F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F68D3).withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(CupertinoIcons.map, color: Color(0xFF2F68D3), size: 30),
          const SizedBox(height: 12),
          Text(
            harborBoard.currentStretchName,
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tune tide timing, shade, and pause rhythm before starting your shoreline route.',
            style: TextStyle(
              color: TidewashPalette.harborSlate.withValues(alpha: 0.78),
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlannerCard extends StatelessWidget {
  const _PlannerCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD5F8F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TideWindowPicker extends StatelessWidget {
  const _TideWindowPicker({
    required this.tideSlots,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<TideWindowSlot> tideSlots;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<int>(
      groupValue: selectedIndex,
      padding: const EdgeInsets.all(4),
      backgroundColor: const Color(0xFFE8F6F2),
      thumbColor: const Color(0xFFFFFFFF),
      children: {
        for (var index = 0; index < tideSlots.length; index++)
          index: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              tideSlots[index].shorelineCue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: index == selectedIndex
                    ? TidewashPalette.inkBlue
                    : TidewashPalette.harborSlate,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      },
      onValueChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _ChoiceStrip<T> extends StatelessWidget {
  const _ChoiceStrip({
    required this.values,
    required this.selectedValue,
    required this.labelFor,
    required this.onChanged,
  });

  final List<T> values;
  final T selectedValue;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final value in values)
          _PlannerChip(
            label: labelFor(value),
            isSelected: value == selectedValue,
            onTap: () => onChanged(value),
          ),
      ],
    );
  }
}

class _PlannerChip extends StatelessWidget {
  const _PlannerChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2F68D3) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2F68D3)
                : const Color(0xFFD6E8E5),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFFFFFFF)
                : TidewashPalette.harborSlate,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _QuietEdgeToggle extends StatelessWidget {
  const _QuietEdgeToggle({required this.quietEdges, required this.onChanged});

  final bool quietEdges;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFFFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Prefer calmer side paths',
              style: TextStyle(
                color: TidewashPalette.inkBlue,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          CupertinoSwitch(value: quietEdges, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _RouteBriefCard extends StatelessWidget {
  const _RouteBriefCard({
    required this.comfortScore,
    required this.tideSlot,
    required this.routePace,
    required this.shadeNeed,
    required this.quietEdges,
    required this.harborBoard,
  });

  final int comfortScore;
  final TideWindowSlot tideSlot;
  final _RoutePace routePace;
  final _ShadeNeed shadeNeed;
  final bool quietEdges;
  final ShorelineDayPlan harborBoard;

  @override
  Widget build(BuildContext context) {
    final firstPause = harborBoard.covePauses.first;
    final lastPause = harborBoard.covePauses.last;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: TidewashPalette.nightFerry,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Comfort route',
                  style: TextStyle(
                    color: TidewashPalette.saltCard,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$comfortScore',
                style: const TextStyle(
                  color: TidewashPalette.buoyGold,
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${tideSlot.readableSpan} - ${routePace.note}',
            style: TextStyle(
              color: TidewashPalette.saltCard.withValues(alpha: 0.76),
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _BriefLine(
            icon: CupertinoIcons.drop,
            text: tideSlot.waterlineBehavior,
          ),
          const SizedBox(height: 10),
          _BriefLine(icon: CupertinoIcons.tree, text: shadeNeed.note),
          const SizedBox(height: 10),
          _BriefLine(
            icon: CupertinoIcons.map_pin_ellipse,
            text: quietEdges
                ? 'Begin at ${firstPause.coveName}, then keep the quieter rail until ${lastPause.coveName}.'
                : 'Use the direct promenade and keep ${lastPause.coveName} as the longer pause.',
          ),
        ],
      ),
    );
  }
}

class _BriefLine extends StatelessWidget {
  const _BriefLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: TidewashPalette.buoyGold),
        const SizedBox(width: ShoreSpacing.tideSm),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: TidewashPalette.saltCard.withValues(alpha: 0.88),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _KitRow extends StatelessWidget {
  const _KitRow({
    required this.label,
    required this.isPacked,
    required this.onTap,
  });

  final String label;
  final bool isPacked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isPacked
                  ? const Color(0xFF35D5DC)
                  : const Color(0xFFFFFFFF),
              shape: BoxShape.circle,
              border: Border.all(
                color: isPacked
                    ? const Color(0xFF35D5DC)
                    : const Color(0xFFCFE5E1),
                width: 1.4,
              ),
            ),
            child: isPacked
                ? const Icon(
                    CupertinoIcons.check_mark,
                    color: Color(0xFFFFFFFF),
                    size: 15,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: TidewashPalette.harborSlate,
                fontSize: 13,
                height: 1.28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavePlanButton extends StatelessWidget {
  const _SavePlanButton({required this.isSaved, required this.onTap});

  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSaved
                ? [const Color(0xFF35D5DC), const Color(0xFF0C7C7A)]
                : [const Color(0xFF35D5DC), const Color(0xFF2F68D3)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F68D3).withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Text(
          isSaved ? 'Route saved for today' : 'Save this route',
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
