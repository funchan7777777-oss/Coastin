import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../domain/entities/feed/coastal_post_dispatch.dart';
import '../../../domain/entities/feed/coastal_topic_lane.dart';
import '../../../domain/entities/feed/sun_guard_chapter.dart';
import '../../../domain/entities/shore_comment_tide_mark.dart';
import '../shore_moment_harbor_catalog.dart';

class CoastalDispatchHarborCatalog {
  const CoastalDispatchHarborCatalog._();

  static const List<CoastalTopicLane> topicLanes = [
    CoastalTopicLane(
      tideTopicMarker: 'seaside-games',
      tideTopicLabel: '# Seaside games',
      harborParticipationLine: '1.2w people participated',
      topicHarborCardAsset: CoastinAssetRegistry.gamesTopicCard,
      topicWashTint: 0xFFCFF2FF,
    ),
    CoastalTopicLane(
      tideTopicMarker: 'seaside-cuisine',
      tideTopicLabel: '# Seaside cuisine',
      harborParticipationLine: '1.2w people',
      topicHarborCardAsset: CoastinAssetRegistry.cuisineTopicCard,
      topicWashTint: 0xFFFFF4D8,
    ),
    CoastalTopicLane(
      tideTopicMarker: 'seaside-dressing',
      tideTopicLabel: '# Seaside dressing',
      harborParticipationLine: '1.2w people',
      topicHarborCardAsset: CoastinAssetRegistry.dressingTopicCard,
      topicWashTint: 0xFFE7EAFF,
    ),
  ];

  static final List<CoastalPostDispatch> coastalDispatches = List.unmodifiable([
    CoastalPostDispatch(
      shoreDispatchMarker: 'dora-coral-dressing',
      shorelineKeeper: ShoreMomentHarborCatalog.shorelinePeople[22],
      tideTopicMarker: 'seaside-dressing',
      tideTopicLabel: 'Seaside dressing',
      localApproachRibbon: '23 - Australia',
      postedAtRibbon: '18m ago',
      shorelineCaption:
          'Breeze by shore, collect soft light today. Long coastline, slow down for coastal tiny joys.',
      shorelineFrameAssets: const [
        CoastinAssetRegistry.sunwearMood1,
        CoastinAssetRegistry.sunwearMood2,
        CoastinAssetRegistry.sunwearMood3,
      ],
      shellLikeCount: 24,
      commentCount: 5,
      shoreShareCount: 7,
      startsShellLiked: false,
      startsFollowed: false,
      commentTideMarks: _commentTideMarks(0, count: 5),
    ),
    CoastalPostDispatch(
      shoreDispatchMarker: 'milo-paddle-games',
      shorelineKeeper: ShoreMomentHarborCatalog.shorelinePeople[5],
      tideTopicMarker: 'seaside-games',
      tideTopicLabel: 'Seaside games',
      localApproachRibbon: 'Palm Cove - Cebu',
      postedAtRibbon: '42m ago',
      shorelineCaption:
          'Small wave races after breakfast, the easy board wins when everyone laughs first.',
      shorelineFrameAssets: const [
        CoastinAssetRegistry.tideplayArc1,
        CoastinAssetRegistry.tideplayArc2,
      ],
      shellLikeCount: 18,
      commentCount: 3,
      shoreShareCount: 5,
      startsShellLiked: false,
      startsFollowed: true,
      commentTideMarks: _commentTideMarks(3, count: 3),
    ),
    CoastalPostDispatch(
      shoreDispatchMarker: 'vivian-citrus-cuisine',
      shorelineKeeper: ShoreMomentHarborCatalog.shorelinePeople[12],
      tideTopicMarker: 'seaside-cuisine',
      tideTopicLabel: 'Seaside cuisine',
      localApproachRibbon: 'Lagoon Market - Aruba',
      postedAtRibbon: '1h ago',
      shorelineCaption:
          'Citrus bowl, cold juice, and a bench with just enough shade to stay longer.',
      shorelineFrameAssets: const [CoastinAssetRegistry.harborBite1],
      shellLikeCount: 31,
      commentCount: 6,
      shoreShareCount: 9,
      startsShellLiked: false,
      startsFollowed: false,
      commentTideMarks: _commentTideMarks(5, count: 6),
    ),
    CoastalPostDispatch(
      shoreDispatchMarker: 'sienna-sunwear-loop',
      shorelineKeeper: ShoreMomentHarborCatalog.shorelinePeople[24],
      tideTopicMarker: 'seaside-dressing',
      tideTopicLabel: 'Seaside dressing',
      localApproachRibbon: 'Shell Lane - Kona',
      postedAtRibbon: '2h ago',
      shorelineCaption:
          'Wide hat, bright wrap, tiny shell earrings. The wind decided the final look.',
      shorelineFrameAssets: const [
        CoastinAssetRegistry.sunwearMood4,
        CoastinAssetRegistry.sunwearMood5,
        CoastinAssetRegistry.sunwearMood6,
      ],
      shellLikeCount: 27,
      commentCount: 4,
      shoreShareCount: 6,
      startsShellLiked: false,
      startsFollowed: true,
      commentTideMarks: _commentTideMarks(8, count: 4),
    ),
    CoastalPostDispatch(
      shoreDispatchMarker: 'kai-reef-games',
      shorelineKeeper: ShoreMomentHarborCatalog.shorelinePeople[19],
      tideTopicMarker: 'seaside-games',
      tideTopicLabel: 'Seaside games',
      localApproachRibbon: 'Reef Rail - Bali',
      postedAtRibbon: '3h ago',
      shorelineCaption:
          'The board game was simple: stay balanced, dodge foam, cheer for every fall.',
      shorelineFrameAssets: const [
        CoastinAssetRegistry.tideplayArc4,
        CoastinAssetRegistry.tideplayArc5,
      ],
      shellLikeCount: 15,
      commentCount: 2,
      shoreShareCount: 4,
      startsShellLiked: false,
      startsFollowed: false,
      commentTideMarks: _commentTideMarks(10, count: 2),
    ),
    CoastalPostDispatch(
      shoreDispatchMarker: 'elena-pier-bites',
      shorelineKeeper: ShoreMomentHarborCatalog.shorelinePeople[14],
      tideTopicMarker: 'seaside-cuisine',
      tideTopicLabel: 'Seaside cuisine',
      localApproachRibbon: 'Pier Table - Lisbon',
      postedAtRibbon: '4h ago',
      shorelineCaption:
          'Late lunch tasted better with salty hair and a chair facing the harbor.',
      shorelineFrameAssets: const [CoastinAssetRegistry.harborBite4],
      shellLikeCount: 22,
      commentCount: 5,
      shoreShareCount: 8,
      startsShellLiked: false,
      startsFollowed: false,
      commentTideMarks: _commentTideMarks(13, count: 5),
    ),
    CoastalPostDispatch(
      shoreDispatchMarker: 'aurora-light-dressing',
      shorelineKeeper: ShoreMomentHarborCatalog.shorelinePeople[22],
      tideTopicMarker: 'seaside-dressing',
      tideTopicLabel: 'Seaside dressing',
      localApproachRibbon: 'Bright Cove - Nice',
      postedAtRibbon: '5h ago',
      shorelineCaption:
          'Soft linen survived the strongest breeze and still looked made for the walk.',
      shorelineFrameAssets: const [
        CoastinAssetRegistry.sunwearMood7,
        CoastinAssetRegistry.sunwearMood8,
        CoastinAssetRegistry.sunwearMood9,
      ],
      shellLikeCount: 19,
      commentCount: 3,
      shoreShareCount: 5,
      startsShellLiked: false,
      startsFollowed: false,
      commentTideMarks: _commentTideMarks(16, count: 3),
    ),
    CoastalPostDispatch(
      shoreDispatchMarker: 'river-sunset-games',
      shorelineKeeper: ShoreMomentHarborCatalog.shorelinePeople[25],
      tideTopicMarker: 'seaside-games',
      tideTopicLabel: 'Seaside games',
      localApproachRibbon: 'Dune Court - Durban',
      postedAtRibbon: 'Yesterday',
      shorelineCaption:
          'Sunset teams picked by shell color. Somehow the blue shell always wins.',
      shorelineFrameAssets: const [
        CoastinAssetRegistry.tideplayArc7,
        CoastinAssetRegistry.tideplayArc8,
      ],
      shellLikeCount: 16,
      commentCount: 4,
      shoreShareCount: 3,
      startsShellLiked: false,
      startsFollowed: true,
      commentTideMarks: _commentTideMarks(19, count: 4),
    ),
    CoastalPostDispatch(
      shoreDispatchMarker: 'nora-salt-bites',
      shorelineKeeper: ShoreMomentHarborCatalog.shorelinePeople[10],
      tideTopicMarker: 'seaside-cuisine',
      tideTopicLabel: 'Seaside cuisine',
      localApproachRibbon: 'Seaglass Cafe - Crete',
      postedAtRibbon: 'Yesterday',
      shorelineCaption:
          'A tiny pastry, cold coffee, and the table closest to the open window.',
      shorelineFrameAssets: const [CoastinAssetRegistry.harborBite7],
      shellLikeCount: 28,
      commentCount: 6,
      shoreShareCount: 6,
      startsShellLiked: false,
      startsFollowed: false,
      commentTideMarks: _commentTideMarks(22, count: 6),
    ),
    CoastalPostDispatch(
      shoreDispatchMarker: 'jade-last-shoreline',
      shorelineKeeper: ShoreMomentHarborCatalog.shorelinePeople[36],
      tideTopicMarker: 'seaside-dressing',
      tideTopicLabel: 'Seaside dressing',
      localApproachRibbon: 'Beacon Steps - Sanya',
      postedAtRibbon: '2d ago',
      shorelineCaption:
          'Last light, one more photo, and a final walk before the sandals come off.',
      shorelineFrameAssets: const [
        CoastinAssetRegistry.sunwearMood10,
        CoastinAssetRegistry.tideplayArc10,
      ],
      shellLikeCount: 20,
      commentCount: 2,
      shoreShareCount: 4,
      startsShellLiked: false,
      startsFollowed: true,
      commentTideMarks: _commentTideMarks(25, count: 2),
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

  static List<ShoreCommentTideMark> _commentTideMarks(int offset, {int count = 4}) {
    const replies = [
      'This spot makes the whole walk slow down in the best way.',
      'The color is so clean today; saving this route for the weekend.',
      'That little shore corner is better before the afternoon crowd.',
      'I need the exact snack stop near this beach.',
      'The outfit and the water color are a good match.',
      'I passed that same place yesterday and the wind was perfect.',
      'The third photo has the calmest light.',
      'This topic is getting better every day.',
    ];
    const commentClocks = [
      '4m ago',
      '12m ago',
      '26m ago',
      '38m ago',
      '1h ago',
      '2h ago',
    ];
    return List.generate(count, (index) {
      final people = ShoreMomentHarborCatalog.shorelinePeople;
      return ShoreCommentTideMark(
        commentMarker: 'feed-commentTideMark-$offset-$index',
        commentHarbor: people[(offset + index * 4) % people.length],
        commentClock: commentClocks[index % commentClocks.length],
        commentText: replies[(offset + index) % replies.length],
        hasFreshSignal: index == 0 || (offset + index).isEven,
      );
    });
  }
}
