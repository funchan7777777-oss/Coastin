import '../../../app/assets/coastin_asset_registry.dart';
import '../../domain/entities/shore_reply_drift.dart';
import '../../domain/entities/shore_video_moment.dart';
import '../../domain/entities/shoreline_persona.dart';
import '../../domain/value_objects/shore_profile_current.dart';

class SeededShoreMomentDeck {
  const SeededShoreMomentDeck._();

  static const List<ShorelinePersona> shorelinePeople = [
    ShorelinePersona(
      tideHandle: 'marina-sunset',
      displayHarborName: 'Marina Vale',
      avatarAsset: CoastinAssetRegistry.marinaSunsetPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'sun deck regular',
    ),
    ShorelinePersona(
      tideHandle: 'atlas-breakwater',
      displayHarborName: 'Atlas Reed',
      avatarAsset: CoastinAssetRegistry.atlasBreakwaterPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'breakwater runner',
    ),
    ShorelinePersona(
      tideHandle: 'luna-boardwalk',
      displayHarborName: 'Luna West',
      avatarAsset: CoastinAssetRegistry.lunaBoardwalkPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'boardwalk lens',
    ),
    ShorelinePersona(
      tideHandle: 'rowan-tidewalk',
      displayHarborName: 'Rowan Vale',
      avatarAsset: CoastinAssetRegistry.rowanTidewalkPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'quiet pier scout',
    ),
    ShorelinePersona(
      tideHandle: 'celeste-foam',
      displayHarborName: 'Celeste Cove',
      avatarAsset: CoastinAssetRegistry.celesteFoamPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'foamline finder',
    ),
    ShorelinePersona(
      tideHandle: 'milo-seacliff',
      displayHarborName: 'Milo Crane',
      avatarAsset: CoastinAssetRegistry.miloSeacliffPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'cliff path friend',
    ),
    ShorelinePersona(
      tideHandle: 'isla-palms',
      displayHarborName: 'Isla Monroe',
      avatarAsset: CoastinAssetRegistry.islaPalmsPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'palm shade keeper',
    ),
    ShorelinePersona(
      tideHandle: 'owen-harbor',
      displayHarborName: 'Owen Hart',
      avatarAsset: CoastinAssetRegistry.owenHarborPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'harbor rail local',
    ),
    ShorelinePersona(
      tideHandle: 'tessa-harbor',
      displayHarborName: 'Tessa Lane',
      avatarAsset: CoastinAssetRegistry.tessaHarborPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'late tide smile',
    ),
    ShorelinePersona(
      tideHandle: 'leo-sandbar',
      displayHarborName: 'Leo Shore',
      avatarAsset: CoastinAssetRegistry.leoSandbarPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'sandbar walker',
    ),
    ShorelinePersona(
      tideHandle: 'nora-seaglass',
      displayHarborName: 'Nora Bly',
      avatarAsset: CoastinAssetRegistry.noraSeaglassPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'seaglass collector',
    ),
    ShorelinePersona(
      tideHandle: 'noah-pierlight',
      displayHarborName: 'Noah Wells',
      avatarAsset: CoastinAssetRegistry.noahPierlightPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'pier light regular',
    ),
    ShorelinePersona(
      tideHandle: 'vivian-lagoon',
      displayHarborName: 'Vivian Rhodes',
      avatarAsset: CoastinAssetRegistry.vivianLagoonPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'lagoon table host',
    ),
    ShorelinePersona(
      tideHandle: 'finn-wavecrest',
      displayHarborName: 'Finn Calder',
      avatarAsset: CoastinAssetRegistry.finnWavecrestPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'wavecrest drifter',
    ),
    ShorelinePersona(
      tideHandle: 'elena-pier',
      displayHarborName: 'Elena Cruz',
      avatarAsset: CoastinAssetRegistry.elenaPierPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'pier sunset note',
    ),
    ShorelinePersona(
      tideHandle: 'eli-coverun',
      displayHarborName: 'Eli Stone',
      avatarAsset: CoastinAssetRegistry.eliCoveRunPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'cove run crew',
    ),
    ShorelinePersona(
      tideHandle: 'kaia-cove',
      displayHarborName: 'Kaia Blue',
      avatarAsset: CoastinAssetRegistry.kaiaCovePortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'clear water guide',
    ),
    ShorelinePersona(
      tideHandle: 'asher-sailway',
      displayHarborName: 'Asher Pike',
      avatarAsset: CoastinAssetRegistry.asherSailwayPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'sailway lookout',
    ),
    ShorelinePersona(
      tideHandle: 'selene-surf',
      displayHarborName: 'Selene Ray',
      avatarAsset: CoastinAssetRegistry.seleneSurfPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'surf break pause',
    ),
    ShorelinePersona(
      tideHandle: 'kai-reefline',
      displayHarborName: 'Kai Ellis',
      avatarAsset: CoastinAssetRegistry.kaiReeflinePortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'reefline watcher',
    ),
    ShorelinePersona(
      tideHandle: 'mila-coastline',
      displayHarborName: 'Mila Sol',
      avatarAsset: CoastinAssetRegistry.milaCoastlinePortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'coastline sketcher',
    ),
    ShorelinePersona(
      tideHandle: 'dylan-beachrail',
      displayHarborName: 'Dylan Moss',
      avatarAsset: CoastinAssetRegistry.dylanBeachrailPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'beach rail regular',
    ),
    ShorelinePersona(
      tideHandle: 'aurora-tide',
      displayHarborName: 'Aurora Quinn',
      avatarAsset: CoastinAssetRegistry.auroraTidePortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'tide glow finder',
    ),
    ShorelinePersona(
      tideHandle: 'jude-palmwalk',
      displayHarborName: 'Jude Marin',
      avatarAsset: CoastinAssetRegistry.judePalmwalkPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'palm walk runner',
    ),
    ShorelinePersona(
      tideHandle: 'sienna-shell',
      displayHarborName: 'Sienna Hart',
      avatarAsset: CoastinAssetRegistry.siennaShellPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'shell lane regular',
    ),
    ShorelinePersona(
      tideHandle: 'river-coastmark',
      displayHarborName: 'River Brooks',
      avatarAsset: CoastinAssetRegistry.riverCoastmarkPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'coast mark scout',
    ),
    ShorelinePersona(
      tideHandle: 'layla-reef',
      displayHarborName: 'Layla Noor',
      avatarAsset: CoastinAssetRegistry.laylaReefPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'reef color hunter',
    ),
    ShorelinePersona(
      tideHandle: 'cole-sundown',
      displayHarborName: 'Cole Avery',
      avatarAsset: CoastinAssetRegistry.coleSundownPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'sundown bench fan',
    ),
    ShorelinePersona(
      tideHandle: 'iris-sail',
      displayHarborName: 'Iris Hale',
      avatarAsset: CoastinAssetRegistry.irisSailPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'sail shade note',
    ),
    ShorelinePersona(
      tideHandle: 'sean-current',
      displayHarborName: 'Sean Vale',
      avatarAsset: CoastinAssetRegistry.seanCurrentPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'current lane regular',
    ),
    ShorelinePersona(
      tideHandle: 'opal-breeze',
      displayHarborName: 'Opal Finch',
      avatarAsset: CoastinAssetRegistry.opalBreezePortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'breeze chaser',
    ),
    ShorelinePersona(
      tideHandle: 'niko-foamline',
      displayHarborName: 'Niko Hart',
      avatarAsset: CoastinAssetRegistry.nikoFoamlinePortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'foamline sprinter',
    ),
    ShorelinePersona(
      tideHandle: 'ruby-waterline',
      displayHarborName: 'Ruby Lane',
      avatarAsset: CoastinAssetRegistry.rubyWaterlinePortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'waterline reader',
    ),
    ShorelinePersona(
      tideHandle: 'wyatt-seabreeze',
      displayHarborName: 'Wyatt Reed',
      avatarAsset: CoastinAssetRegistry.wyattSeabreezePortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'sea breeze stop',
    ),
    ShorelinePersona(
      tideHandle: 'clara-dune',
      displayHarborName: 'Clara Wren',
      avatarAsset: CoastinAssetRegistry.claraDunePortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'dune camera friend',
    ),
    ShorelinePersona(
      tideHandle: 'mateo-shoreline',
      displayHarborName: 'Mateo Cruz',
      avatarAsset: CoastinAssetRegistry.mateoShorelinePortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'shoreline noon walk',
    ),
    ShorelinePersona(
      tideHandle: 'jade-beacon',
      displayHarborName: 'Jade Monroe',
      avatarAsset: CoastinAssetRegistry.jadeBeaconPortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'beacon route saver',
    ),
    ShorelinePersona(
      tideHandle: 'reece-marina',
      displayHarborName: 'Reece Wilder',
      avatarAsset: CoastinAssetRegistry.reeceMarinaPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'marina stair regular',
    ),
    ShorelinePersona(
      tideHandle: 'zoe-shore',
      displayHarborName: 'Zoe Palm',
      avatarAsset: CoastinAssetRegistry.zoeShorePortrait,
      profileCurrent: ShoreProfileCurrent.feminine,
      coastalStamp: 'shore picnic finder',
    ),
    ShorelinePersona(
      tideHandle: 'logan-duneview',
      displayHarborName: 'Logan Fields',
      avatarAsset: CoastinAssetRegistry.loganDuneviewPortrait,
      profileCurrent: ShoreProfileCurrent.masculine,
      coastalStamp: 'dune view regular',
    ),
  ];

  static final List<ShoreVideoMoment> shoreVideoMoments = List.unmodifiable(
    List.generate(_momentVideoAssets.length, (index) {
      final replyStart = (index * 3 + 8) % shorelinePeople.length;
      return ShoreVideoMoment(
        momentKey: 'shore-drift-${index + 1}',
        creatorPersona: shorelinePeople[index],
        videoAsset: _momentVideoAssets[index],
        placeRibbon: _placeRibbons[index],
        clockRibbon: _clockRibbons[index],
        captionTide: _captionTides[index],
        likeTally: _likeTallies[index],
        replyTally: _replyTallies[index],
        infoTally: _infoTallies[index],
        isInitiallyFollowed: index % 3 == 0,
        isInitiallyLiked: index == 1 || index == 6 || index == 11,
        replyDrifts: List.generate(5, (replyIndex) {
          final persona =
              shorelinePeople[(replyStart + replyIndex * 5) %
                  shorelinePeople.length];
          return ShoreReplyDrift(
            replyMarker: 'reply-${index + 1}-$replyIndex',
            replyAuthor: persona,
            tideMinute:
                _replyMinutes[(index + replyIndex) % _replyMinutes.length],
            replyText:
                _replyLines[(index * 2 + replyIndex) % _replyLines.length],
            hasFreshSignal: replyIndex == 0 || (index + replyIndex) % 4 == 0,
          );
        }),
      );
    }),
  );

  static const List<String> _momentVideoAssets = [
    CoastinAssetRegistry.palmsAfterglowDrift,
    CoastinAssetRegistry.coveHatSunsetWalk,
    CoastinAssetRegistry.railsideBeachTurn,
    CoastinAssetRegistry.blueWaterPaddleLoop,
    CoastinAssetRegistry.morningFoamBoardRun,
    CoastinAssetRegistry.harborMarketSmileClip,
    CoastinAssetRegistry.lagoonChairBreeze,
    CoastinAssetRegistry.pierDanceSmallWave,
    CoastinAssetRegistry.outerSandSlowPan,
    CoastinAssetRegistry.sunlitBoardwalkCatch,
    CoastinAssetRegistry.seaglassCafeMoment,
    CoastinAssetRegistry.shorelineSkateGlide,
    CoastinAssetRegistry.marinaGoldenHourStep,
    CoastinAssetRegistry.reefsidePicnicSweep,
    CoastinAssetRegistry.duneTrailEveningClip,
  ];

  static const List<String> _placeRibbons = [
    '23 - Australia',
    'Palm Rail - Maui',
    'Cove Lane - Cebu',
    'Blue Steps - Lagos',
    'Morning Foam - Bali',
    'Harbor Cart - Lisbon',
    'Lagoon Chair - Aruba',
    'Pier Turn - Sanya',
    'Outer Sand - Phuket',
    'Boardwalk - Miami',
    'Seaglass Cafe - Crete',
    'Shore Skate - Venice',
    'Marina Glow - Nice',
    'Reef Picnic - Kona',
    'Dune Trail - Durban',
  ];

  static const List<String> _clockRibbons = [
    '12:24',
    '08:45',
    '16:10',
    '10:36',
    '07:28',
    '11:52',
    '15:05',
    '18:14',
    '09:09',
    '13:31',
    '17:42',
    '14:06',
    '19:18',
    '12:03',
    '18:55',
  ];

  static const List<String> _captionTides = [
    'Ice players, forever passionate. Repeat skating drills, progress lies in persistence.',
    'Soft palms, salt air, and one quiet laugh before the shore gets crowded.',
    'The best view was the tiny silver line where the rail met the afternoon sea.',
    'Blue water has its own pace when every paddle waits for the next small lift.',
    'Morning foam rolled in clean enough to make the whole path feel new.',
    'A fruit cup, two steps of shade, and the market bell made the stop worth it.',
    'Lagoon chairs are better when nobody is rushing the next plan.',
    'A quick turn on the pier before the sunset crowd claimed every bench.',
    'Outer sand stayed cool under the wind, so we kept walking past the flags.',
    'Boardwalk light landed perfectly for three seconds and then disappeared.',
    'Cold jasmine coffee after a bright walk is a small kind of victory.',
    'Skate wheels sounded like rain on the warm path beside the water.',
    'Marina light went gold just as the boats started leaning into the breeze.',
    'Reef picnic notes: bring extra water and never skip the mango slices.',
    'Dune trail evening had enough color to forgive the climb back up.',
  ];

  static const List<int> _likeTallies = [
    1290,
    884,
    642,
    1712,
    940,
    773,
    1208,
    999,
    531,
    1471,
    808,
    1134,
    1510,
    932,
    690,
  ];

  static const List<int> _replyTallies = [
    332,
    245,
    188,
    419,
    267,
    205,
    390,
    304,
    141,
    356,
    232,
    315,
    377,
    260,
    174,
  ];

  static const List<int> _infoTallies = [
    93,
    76,
    52,
    118,
    67,
    61,
    85,
    74,
    43,
    103,
    58,
    88,
    107,
    69,
    47,
  ];

  static const List<String> _replyMinutes = [
    '08:45',
    '09:12',
    '10:03',
    '12:19',
    '14:40',
    '16:08',
    '18:22',
  ];

  static const List<String> _replyLines = [
    'This hand brewed coffee is very fragrant and has a faint jasmine aroma.',
    'The light at that rail is unreal when the wind drops.',
    'Saved this spot for my next slow walk.',
    'That shade line looks perfect for late morning.',
    'The water color is softer than yesterday.',
    'I can hear the pier boards from this clip.',
    'Small places like this make the whole day easier.',
    'The sunset bench is never empty after six.',
    'Bring a cap there; the glare is stronger than it looks.',
    'That little wave near the edge is my favorite part.',
  ];
}
