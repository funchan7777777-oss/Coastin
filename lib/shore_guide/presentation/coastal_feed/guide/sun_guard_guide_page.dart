import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/feed/seeded_coastal_feed_deck.dart';
import '../../../domain/entities/feed/sun_guard_chapter.dart';

class SunGuardGuidePage extends StatelessWidget {
  const SunGuardGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFEAF9F2),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 38, 18, 34),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            CoastinAssetRegistry.feedGuidePreview,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        const SizedBox(height: 18),
                        for (final chapter
                            in SeededCoastalFeedDeck.sunGuardChapters) ...[
                          _GuideChapterCard(chapter: chapter),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 14,
              top: 50,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.86),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.chevron_left,
                    color: TidewashPalette.inkBlue,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideChapterCard extends StatelessWidget {
  const _GuideChapterCard({required this.chapter});

  final SunGuardChapter chapter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TidewashPalette.pierLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${chapter.chapterNumber}. ${chapter.chapterTitle}',
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            chapter.chapterText,
            style: const TextStyle(
              color: TidewashPalette.harborSlate,
              fontSize: 14,
              height: 1.36,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
