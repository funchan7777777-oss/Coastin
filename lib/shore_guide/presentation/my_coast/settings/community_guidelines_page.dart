import 'package:flutter/cupertino.dart';

import '../../../../app/theme/tidewash_palette.dart';
import '../widgets/my_coast_top_bar.dart';
import '../widgets/my_coast_wash.dart';

class CommunityGuidelinesPage extends StatelessWidget {
  const CommunityGuidelinesPage({super.key});

  static const List<_GuidelineCurrent> _guidelines = [
    _GuidelineCurrent(
      title: 'Use a clear Coastin identity',
      body:
          'Profiles, posts, comments, and messages should represent a real user identity inside Coastin. Do not impersonate another person or create anonymous contact paths.',
    ),
    _GuidelineCurrent(
      title: 'Keep private chat permission based',
      body:
          'Chat and video calls are available only after both people follow each other. Do not pressure another user to respond, follow, or move a conversation outside Coastin.',
    ),
    _GuidelineCurrent(
      title: 'Share lawful shoreline content',
      body:
          'Upload only content you own or have permission to use. Do not share illegal activity, dangerous instructions, sexual content, threats, hate, or harassment.',
    ),
    _GuidelineCurrent(
      title: 'Respect safety controls',
      body:
          'Reports and blocks are reviewed locally for your account experience. Report unsafe posts, comments, or profiles instead of engaging with them.',
    ),
    _GuidelineCurrent(
      title: 'Moderation before visibility',
      body:
          'New public posts and videos may be held for review before appearing in Coastin feeds. Repeated abuse can limit account access.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFFF7DA),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            const Positioned.fill(child: MyCoastWash()),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 54, 22, 34),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyCoastTopBar(
                          title: 'Community guidelines',
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 28),
                        for (final guideline in _guidelines) ...[
                          _GuidelineCard(guideline: guideline),
                          const SizedBox(height: 14),
                        ],
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

class _GuidelineCard extends StatelessWidget {
  const _GuidelineCard({required this.guideline});

  final _GuidelineCurrent guideline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            guideline.title,
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            guideline.body,
            style: TextStyle(
              color: TidewashPalette.harborSlate.withValues(alpha: 0.78),
              fontSize: 14,
              height: 1.42,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidelineCurrent {
  const _GuidelineCurrent({required this.title, required this.body});

  final String title;
  final String body;
}
