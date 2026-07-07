import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../access/widgets/wave_art_button.dart';

class ShorelineGuideDeckPage extends StatefulWidget {
  const ShorelineGuideDeckPage({super.key, required this.onGuideDeckFinished});

  final Future<void> Function() onGuideDeckFinished;

  @override
  State<ShorelineGuideDeckPage> createState() => _ShorelineGuideDeckPageState();
}

class _ShorelineGuideDeckPageState extends State<ShorelineGuideDeckPage> {
  final PageController _guideRailController = PageController();
  int _currentHarborCard = 0;
  bool _finishingDeck = false;

  static const List<_GuideDeckCard> _guideCards = [
    _GuideDeckCard(
      artAsset: CoastinAssetRegistry.sundanceProfileTile,
      headline: 'Catch the day early',
      note:
          'Keep the sunny stops, tide windows, and gentle pauses in one clear route.',
    ),
    _GuideDeckCard(
      artAsset: CoastinAssetRegistry.surferProfileTile,
      headline: 'Move with the water',
      note:
          'Coastin keeps the day relaxed with lightweight notes for each shoreline moment.',
    ),
    _GuideDeckCard(
      artAsset: CoastinAssetRegistry.bluewaterHomeMark,
      headline: 'Arrive ready',
      note:
          'Save your small harbor profile once and continue from the same place next time.',
    ),
  ];

  @override
  void dispose() {
    _guideRailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: const Color(0x00000000),
      ),
      child: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0x00000000),
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Image(
                image: AssetImage(CoastinAssetRegistry.saltyRoamBackdrop),
                fit: BoxFit.fill,
              ),
              PageView.builder(
                controller: _guideRailController,
                onPageChanged: (index) {
                  setState(() => _currentHarborCard = index);
                },
                itemCount: _guideCards.length,
                itemBuilder: (context, index) {
                  return _GuideDeckPanel(deckCard: _guideCards[index]);
                },
              ),
              Positioned(
                left: 28,
                right: 28,
                bottom: 42,
                child: Column(
                  children: [
                    _GuideDeckDots(activeIndex: _currentHarborCard),
                    const SizedBox(height: 22),
                    Opacity(
                      opacity: _finishingDeck ? 0.72 : 1,
                      child: WaveArtButton(
                        buttonAsset:
                            _currentHarborCard == _guideCards.length - 1
                            ? CoastinAssetRegistry.sundeckStartButton
                            : CoastinAssetRegistry.tidepoolNextButton,
                        semanticCurrent:
                            _currentHarborCard == _guideCards.length - 1
                            ? 'Start'
                            : 'Next',
                        onPressed: _finishingDeck ? () {} : _stepForward,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _stepForward() async {
    if (_currentHarborCard < _guideCards.length - 1) {
      await _guideRailController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    setState(() => _finishingDeck = true);
    await widget.onGuideDeckFinished();
  }
}

class _GuideDeckPanel extends StatelessWidget {
  const _GuideDeckPanel({required this.deckCard});

  final _GuideDeckCard deckCard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 86, 28, 132),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xDFFFFFFF),
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1FAAB1).withValues(alpha: 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                deckCard.artAsset,
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 34),
          Text(
            deckCard.headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2360C9),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.04,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            deckCard.note,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0x9951767C),
              fontSize: 15,
              height: 1.38,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideDeckDots extends StatelessWidget {
  const _GuideDeckDots({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: active ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2F6ACE) : const Color(0x6638CBD1),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _GuideDeckCard {
  const _GuideDeckCard({
    required this.artAsset,
    required this.headline,
    required this.note,
  });

  final String artAsset;
  final String headline;
  final String note;
}
