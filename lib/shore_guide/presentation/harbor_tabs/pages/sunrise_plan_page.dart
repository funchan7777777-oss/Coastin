import 'package:flutter/cupertino.dart';

import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/tokens/shore_spacing.dart';

class SunrisePlanPage extends StatelessWidget {
  const SunrisePlanPage({super.key, required this.bottomDockClearance});

  final double bottomDockClearance;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: TidewashPalette.canvasFoam,
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                ShoreSpacing.tideLg,
                54,
                ShoreSpacing.tideLg,
                bottomDockClearance + ShoreSpacing.tideLg,
              ),
              sliver: SliverList.list(
                children: const [
                  _SunriseHeaderNote(),
                  SizedBox(height: ShoreSpacing.tideLg),
                  _SunrisePlanCard(
                    harborClock: '08:20',
                    dockPhrase: 'Mist coffee stop',
                    driftDetail:
                        'Pick the north counter before the pier line gets busy.',
                    currentTone: TidewashPalette.channelTeal,
                  ),
                  SizedBox(height: ShoreSpacing.tideMd),
                  _SunrisePlanCard(
                    harborClock: '10:45',
                    dockPhrase: 'Open-sand window',
                    driftDetail:
                        'Walk the water edge while the lower shelf is still wide.',
                    currentTone: TidewashPalette.sunriseCoral,
                  ),
                  SizedBox(height: ShoreSpacing.tideMd),
                  _SunrisePlanCard(
                    harborClock: '17:55',
                    dockPhrase: 'Late rail glow',
                    driftDetail:
                        'Hold the outer bench if the breeze stays below eight knots.',
                    currentTone: TidewashPalette.buoyGold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SunriseHeaderNote extends StatelessWidget {
  const _SunriseHeaderNote();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sunrise Plan',
          style: TextStyle(
            color: TidewashPalette.inkBlue,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: ShoreSpacing.tideSm),
        Text(
          'Small windows for an easy coast day.',
          style: TextStyle(
            color: TidewashPalette.harborSlate,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SunrisePlanCard extends StatelessWidget {
  const _SunrisePlanCard({
    required this.harborClock,
    required this.dockPhrase,
    required this.driftDetail,
    required this.currentTone,
  });

  final String harborClock;
  final String dockPhrase;
  final String driftDetail;
  final Color currentTone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ShoreSpacing.tideLg),
      decoration: BoxDecoration(
        color: TidewashPalette.saltCard,
        borderRadius: BorderRadius.circular(ShoreSpacing.cardRadius),
        border: Border.all(color: TidewashPalette.pierLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: currentTone.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(ShoreSpacing.cardRadius),
            ),
            child: Text(
              harborClock,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: currentTone,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: ShoreSpacing.tideMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dockPhrase,
                  style: const TextStyle(
                    color: TidewashPalette.inkBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: ShoreSpacing.tideXs),
                Text(
                  driftDetail,
                  style: const TextStyle(
                    color: TidewashPalette.harborSlate,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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
