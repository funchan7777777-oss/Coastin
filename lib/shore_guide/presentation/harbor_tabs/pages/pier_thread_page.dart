import 'package:flutter/cupertino.dart';

import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/tokens/shore_spacing.dart';

class PierThreadPage extends StatelessWidget {
  const PierThreadPage({super.key, required this.bottomDockClearance});

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
                  _PierThreadHeader(),
                  SizedBox(height: ShoreSpacing.tideLg),
                  _PierThreadNote(
                    markerInitials: 'M',
                    markerColor: TidewashPalette.channelTeal,
                    noteTitle: 'Mira at Dock 3',
                    noteBody:
                        'The tide rail is dry again near the shell stand.',
                    noteStamp: '9 min',
                  ),
                  SizedBox(height: ShoreSpacing.tideMd),
                  _PierThreadNote(
                    markerInitials: 'J',
                    markerColor: TidewashPalette.sunriseCoral,
                    noteTitle: 'Jun by Twin Palms',
                    noteBody:
                        'Warm bench, light breeze, still good for a quiet snack.',
                    noteStamp: '24 min',
                  ),
                  SizedBox(height: ShoreSpacing.tideMd),
                  _PierThreadNote(
                    markerInitials: 'S',
                    markerColor: TidewashPalette.buoyGold,
                    noteTitle: 'Sage on Harbor Walk',
                    noteBody:
                        'Cloud edge opened up; sunset view may hold tonight.',
                    noteStamp: '1 hr',
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

class _PierThreadHeader extends StatelessWidget {
  const _PierThreadHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pier Thread',
          style: TextStyle(
            color: TidewashPalette.inkBlue,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: ShoreSpacing.tideSm),
        Text(
          'Fresh notes around the walk.',
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

class _PierThreadNote extends StatelessWidget {
  const _PierThreadNote({
    required this.markerInitials,
    required this.markerColor,
    required this.noteTitle,
    required this.noteBody,
    required this.noteStamp,
  });

  final String markerInitials;
  final Color markerColor;
  final String noteTitle;
  final String noteBody;
  final String noteStamp;

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
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: markerColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              markerInitials,
              style: TextStyle(
                color: markerColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: ShoreSpacing.tideMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        noteTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: TidewashPalette.inkBlue,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: ShoreSpacing.tideSm),
                    Text(
                      noteStamp,
                      style: const TextStyle(
                        color: TidewashPalette.harborSlate,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ShoreSpacing.tideXs),
                Text(
                  noteBody,
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
