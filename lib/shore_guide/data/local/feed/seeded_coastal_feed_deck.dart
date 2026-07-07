import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../domain/entities/feed/coastal_post_dispatch.dart';
import '../../../domain/entities/feed/coastal_topic_lane.dart';
import '../../../domain/entities/feed/sun_guard_chapter.dart';
import '../../../domain/entities/shore_reply_drift.dart';
import '../seeded_shore_moment_deck.dart';

class SeededCoastalFeedDeck {
  const SeededCoastalFeedDeck._();

  static const List<CoastalTopicLane> topicLanes = [
    CoastalTopicLane(
      laneKey: 'seaside-games',
      topicLabel: '# Seaside games',
      participationLine: '1.2w people participated',
      topicCardAsset: CoastinAssetRegistry.gamesTopicCard,
      highlightTint: 0xFFCFF2FF,
    ),
    CoastalTopicLane(
      laneKey: 'seaside-cuisine',
      topicLabel: '# Seaside cuisine',
      participationLine: '1.2w people',
      topicCardAsset: CoastinAssetRegistry.cuisineTopicCard,
      highlightTint: 0xFFFFF4D8,
    ),
    CoastalTopicLane(
      laneKey: 'seaside-dressing',
      topicLabel: '# Seaside dressing',
      participationLine: '1.2w people',
      topicCardAsset: CoastinAssetRegistry.dressingTopicCard,
      highlightTint: 0xFFE7EAFF,
    ),
  ];

  static final List<CoastalPostDispatch> coastalDispatches = List.unmodifiable([
    CoastalPostDispatch(
      dispatchKey: 'dora-coral-dressing',
      authorHarbor: SeededShoreMomentDeck.shorelinePeople[22],
      topicKey: 'seaside-dressing',
      topicLabel: 'Seaside dressing',
      placeRibbon: '23 - Australia',
      clockRibbon: '12:24',
      captionCurrent:
          'Breeze by shore, collect seaside romance today. Long coastline, slow down for coastal tiny joys.',
      frameAssets: const [
        CoastinAssetRegistry.sunwearMood1,
        CoastinAssetRegistry.sunwearMood2,
        CoastinAssetRegistry.sunwearMood3,
      ],
      heartTally: 958,
      replyTally: 584,
      relayTally: 654,
      isInitiallyLoved: true,
      isInitiallyFollowed: false,
      replyDrifts: _commentDrifts(0),
    ),
    CoastalPostDispatch(
      dispatchKey: 'milo-paddle-games',
      authorHarbor: SeededShoreMomentDeck.shorelinePeople[5],
      topicKey: 'seaside-games',
      topicLabel: 'Seaside games',
      placeRibbon: 'Palm Cove - Cebu',
      clockRibbon: '09:42',
      captionCurrent:
          'Small wave races after breakfast, the easy board wins when everyone laughs first.',
      frameAssets: const [
        CoastinAssetRegistry.tideplayArc1,
        CoastinAssetRegistry.tideplayArc2,
        CoastinAssetRegistry.tideplayArc3,
      ],
      heartTally: 742,
      replyTally: 311,
      relayTally: 286,
      isInitiallyLoved: false,
      isInitiallyFollowed: true,
      replyDrifts: _commentDrifts(3),
    ),
    CoastalPostDispatch(
      dispatchKey: 'vivian-citrus-cuisine',
      authorHarbor: SeededShoreMomentDeck.shorelinePeople[12],
      topicKey: 'seaside-cuisine',
      topicLabel: 'Seaside cuisine',
      placeRibbon: 'Lagoon Market - Aruba',
      clockRibbon: '11:05',
      captionCurrent:
          'Citrus bowl, cold juice, and a bench with just enough shade to stay longer.',
      frameAssets: const [
        CoastinAssetRegistry.harborBite1,
        CoastinAssetRegistry.harborBite2,
        CoastinAssetRegistry.harborBite3,
      ],
      heartTally: 889,
      replyTally: 420,
      relayTally: 361,
      isInitiallyLoved: false,
      isInitiallyFollowed: false,
      replyDrifts: _commentDrifts(5),
    ),
    CoastalPostDispatch(
      dispatchKey: 'sienna-sunwear-loop',
      authorHarbor: SeededShoreMomentDeck.shorelinePeople[24],
      topicKey: 'seaside-dressing',
      topicLabel: 'Seaside dressing',
      placeRibbon: 'Shell Lane - Kona',
      clockRibbon: '15:18',
      captionCurrent:
          'Wide hat, bright wrap, tiny shell earrings. The wind decided the final look.',
      frameAssets: const [
        CoastinAssetRegistry.sunwearMood4,
        CoastinAssetRegistry.sunwearMood5,
        CoastinAssetRegistry.sunwearMood6,
      ],
      heartTally: 1120,
      replyTally: 503,
      relayTally: 497,
      isInitiallyLoved: true,
      isInitiallyFollowed: true,
      replyDrifts: _commentDrifts(8),
    ),
    CoastalPostDispatch(
      dispatchKey: 'kai-reef-games',
      authorHarbor: SeededShoreMomentDeck.shorelinePeople[19],
      topicKey: 'seaside-games',
      topicLabel: 'Seaside games',
      placeRibbon: 'Reef Rail - Bali',
      clockRibbon: '16:44',
      captionCurrent:
          'The board game was simple: stay balanced, dodge foam, cheer for every fall.',
      frameAssets: const [
        CoastinAssetRegistry.tideplayArc4,
        CoastinAssetRegistry.tideplayArc5,
        CoastinAssetRegistry.tideplayArc6,
      ],
      heartTally: 637,
      replyTally: 228,
      relayTally: 193,
      isInitiallyLoved: false,
      isInitiallyFollowed: false,
      replyDrifts: _commentDrifts(10),
    ),
    CoastalPostDispatch(
      dispatchKey: 'elena-pier-bites',
      authorHarbor: SeededShoreMomentDeck.shorelinePeople[14],
      topicKey: 'seaside-cuisine',
      topicLabel: 'Seaside cuisine',
      placeRibbon: 'Pier Table - Lisbon',
      clockRibbon: '13:27',
      captionCurrent:
          'Late lunch tasted better with salty hair and a chair facing the harbor.',
      frameAssets: const [
        CoastinAssetRegistry.harborBite4,
        CoastinAssetRegistry.harborBite5,
        CoastinAssetRegistry.harborBite6,
      ],
      heartTally: 1014,
      replyTally: 448,
      relayTally: 502,
      isInitiallyLoved: true,
      isInitiallyFollowed: false,
      replyDrifts: _commentDrifts(13),
    ),
    CoastalPostDispatch(
      dispatchKey: 'aurora-light-dressing',
      authorHarbor: SeededShoreMomentDeck.shorelinePeople[22],
      topicKey: 'seaside-dressing',
      topicLabel: 'Seaside dressing',
      placeRibbon: 'Bright Cove - Nice',
      clockRibbon: '17:36',
      captionCurrent:
          'Soft linen survived the strongest breeze and still looked made for the walk.',
      frameAssets: const [
        CoastinAssetRegistry.sunwearMood7,
        CoastinAssetRegistry.sunwearMood8,
        CoastinAssetRegistry.sunwearMood9,
      ],
      heartTally: 781,
      replyTally: 304,
      relayTally: 260,
      isInitiallyLoved: false,
      isInitiallyFollowed: false,
      replyDrifts: _commentDrifts(16),
    ),
    CoastalPostDispatch(
      dispatchKey: 'river-sunset-games',
      authorHarbor: SeededShoreMomentDeck.shorelinePeople[25],
      topicKey: 'seaside-games',
      topicLabel: 'Seaside games',
      placeRibbon: 'Dune Court - Durban',
      clockRibbon: '18:09',
      captionCurrent:
          'Sunset teams picked by shell color. Somehow the blue shell always wins.',
      frameAssets: const [
        CoastinAssetRegistry.tideplayArc7,
        CoastinAssetRegistry.tideplayArc8,
        CoastinAssetRegistry.tideplayArc9,
      ],
      heartTally: 690,
      replyTally: 277,
      relayTally: 244,
      isInitiallyLoved: false,
      isInitiallyFollowed: true,
      replyDrifts: _commentDrifts(19),
    ),
    CoastalPostDispatch(
      dispatchKey: 'nora-salt-bites',
      authorHarbor: SeededShoreMomentDeck.shorelinePeople[10],
      topicKey: 'seaside-cuisine',
      topicLabel: 'Seaside cuisine',
      placeRibbon: 'Seaglass Cafe - Crete',
      clockRibbon: '10:51',
      captionCurrent:
          'A tiny pastry, cold coffee, and the table closest to the open window.',
      frameAssets: const [
        CoastinAssetRegistry.harborBite7,
        CoastinAssetRegistry.harborBite8,
        CoastinAssetRegistry.harborBite9,
      ],
      heartTally: 835,
      replyTally: 392,
      relayTally: 318,
      isInitiallyLoved: false,
      isInitiallyFollowed: false,
      replyDrifts: _commentDrifts(22),
    ),
    CoastalPostDispatch(
      dispatchKey: 'jade-last-shoreline',
      authorHarbor: SeededShoreMomentDeck.shorelinePeople[36],
      topicKey: 'seaside-dressing',
      topicLabel: 'Seaside dressing',
      placeRibbon: 'Beacon Steps - Sanya',
      clockRibbon: '19:02',
      captionCurrent:
          'Last light, one more photo, and a final walk before the sandals come off.',
      frameAssets: const [
        CoastinAssetRegistry.sunwearMood10,
        CoastinAssetRegistry.tideplayArc10,
        CoastinAssetRegistry.harborBite10,
      ],
      heartTally: 1196,
      replyTally: 531,
      relayTally: 604,
      isInitiallyLoved: true,
      isInitiallyFollowed: true,
      replyDrifts: _commentDrifts(25),
    ),
  ]);

  static const List<SunGuardChapter> sunGuardChapters = [
    SunGuardChapter(
      chapterNumber: 1,
      chapterTitle: 'UV Radiation Conditions on the Beach',
      chapterText:
          'Seawater reflects strong daylight and pale sand brightens it again. Check the UV window before long shoreline walks.',
    ),
    SunGuardChapter(
      chapterNumber: 2,
      chapterTitle: 'Sunscreen Selection & Correct Application',
      chapterText:
          'Choose broad spectrum SPF50+ for open beach time. Apply a full layer before leaving shade and refresh after swimming.',
    ),
    SunGuardChapter(
      chapterNumber: 3,
      chapterTitle: 'Physical Sun Protection Gear',
      chapterText:
          'Wide brim hats, light coverups, UV sunglasses, and a small umbrella reduce direct exposure better than sunscreen alone.',
    ),
    SunGuardChapter(
      chapterNumber: 4,
      chapterTitle: 'Reasonable Schedule for Beach Activities',
      chapterText:
          'Plan games and photos early or late. Keep the harshest midday stretch for food, shade, water, and slow indoor breaks.',
    ),
    SunGuardChapter(
      chapterNumber: 5,
      chapterTitle: 'After-sun Soothing & Repair Steps',
      chapterText:
          'Rinse with cool water, use a simple moisturizing gel, and avoid extra sun on irritated areas for the next day.',
    ),
  ];

  static List<ShoreReplyDrift> _commentDrifts(int offset) {
    const replies = [
      'This looks like the kind of spot that makes the whole walk slower.',
      'The color is so clean today; saving this route for the weekend.',
      'That little shore corner is better before the afternoon crowd.',
      'I need the exact snack stop near this beach.',
      'The outfit and the water color are a good match.',
      'I passed that same place yesterday and the wind was perfect.',
      'The third photo has the calmest light.',
      'This topic is getting better every day.',
    ];
    return List.generate(4, (index) {
      final people = SeededShoreMomentDeck.shorelinePeople;
      return ShoreReplyDrift(
        replyMarker: 'feed-reply-$offset-$index',
        replyAuthor: people[(offset + index * 4) % people.length],
        tideMinute: ['08:45', '09:12', '10:36', '12:28'][index],
        replyText: replies[(offset + index) % replies.length],
        hasFreshSignal: index == 0 || (offset + index).isEven,
      );
    });
  }
}
