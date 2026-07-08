import '../../../domain/entities/buddies/sea_buddy_follow_request.dart';
import '../../../domain/entities/buddies/sea_buddy_harbor_thread.dart';
import '../shore_moment_harbor_catalog.dart';

class SeaBuddyHarborCatalog {
  const SeaBuddyHarborCatalog._();

  static final List<SeaBuddyHarborThread> buddyThreads = [
    SeaBuddyHarborThread(
      harborThreadMarker: 'leo-board-advice',
      buddyHarbor: ShoreMomentHarborCatalog.shorelinePeople[22],
      localApproachRibbon: '23 - Australia',
      lastSignalTime: '',
      lastSignalPreview: '',
      unreadSignalCount: 0,
      callWarmupLine: '',
      signalNotes: const [],
    ),
    SeaBuddyHarborThread(
      harborThreadMarker: 'nora-cafe-note',
      buddyHarbor: ShoreMomentHarborCatalog.shorelinePeople[10],
      localApproachRibbon: 'Seaglass Cafe',
      lastSignalTime: '',
      lastSignalPreview: '',
      unreadSignalCount: 0,
      callWarmupLine: '',
      signalNotes: const [],
    ),
    SeaBuddyHarborThread(
      harborThreadMarker: 'milo-sandbar',
      buddyHarbor: ShoreMomentHarborCatalog.shorelinePeople[5],
      localApproachRibbon: 'Sandbar Gate',
      lastSignalTime: '',
      lastSignalPreview: '',
      unreadSignalCount: 0,
      callWarmupLine: '',
      signalNotes: const [],
    ),
    SeaBuddyHarborThread(
      harborThreadMarker: 'isla-palms',
      buddyHarbor: ShoreMomentHarborCatalog.shorelinePeople[6],
      localApproachRibbon: 'Palm Walk',
      lastSignalTime: '',
      lastSignalPreview: '',
      unreadSignalCount: 0,
      callWarmupLine: '',
      signalNotes: const [],
    ),
    SeaBuddyHarborThread(
      harborThreadMarker: 'rowan-rail',
      buddyHarbor: ShoreMomentHarborCatalog.shorelinePeople[3],
      localApproachRibbon: 'Quiet Pier',
      lastSignalTime: '',
      lastSignalPreview: '',
      unreadSignalCount: 0,
      callWarmupLine: '',
      signalNotes: const [],
    ),
    SeaBuddyHarborThread(
      harborThreadMarker: 'celeste-foam',
      buddyHarbor: ShoreMomentHarborCatalog.shorelinePeople[4],
      localApproachRibbon: 'Foamline',
      lastSignalTime: '',
      lastSignalPreview: '',
      unreadSignalCount: 0,
      callWarmupLine: '',
      signalNotes: const [],
    ),
  ];

  static final List<SeaBuddyFollowRequest> buddyRequests = [
    SeaBuddyFollowRequest(
      followRequestMarker: 'donald-dressing',
      requestHarbor: ShoreMomentHarborCatalog.shorelinePeople[24],
      localApproachRibbon: '23 - Australia',
      approachNote:
          'Breeze by shore, collect soft light today. Long coastline, slow down for coastal tiny joys.',
      startsFollowed: false,
    ),
    SeaBuddyFollowRequest(
      followRequestMarker: 'evan-cuisine',
      requestHarbor: ShoreMomentHarborCatalog.shorelinePeople[12],
      localApproachRibbon: 'Lagoon Market',
      approachNote:
          'I found a quiet snack path near the lagoon and thought you might like it.',
      startsFollowed: false,
    ),
    SeaBuddyFollowRequest(
      followRequestMarker: 'dora-shell',
      requestHarbor: ShoreMomentHarborCatalog.shorelinePeople[36],
      localApproachRibbon: 'Beacon Steps',
      approachNote:
          'Your sunwear post matched my saved route. I saved the same shoreline notes.',
      startsFollowed: true,
    ),
    SeaBuddyFollowRequest(
      followRequestMarker: 'kai-reefline',
      requestHarbor: ShoreMomentHarborCatalog.shorelinePeople[19],
      localApproachRibbon: 'Reef Rail',
      approachNote:
          'I keep seeing your coast notes around the same tide window.',
      startsFollowed: false,
    ),
    SeaBuddyFollowRequest(
      followRequestMarker: 'opal-breeze',
      requestHarbor: ShoreMomentHarborCatalog.shorelinePeople[30],
      localApproachRibbon: 'Breeze Point',
      approachNote:
          'Your late walk list is useful. I want to follow the next update.',
      startsFollowed: false,
    ),
  ];
}
