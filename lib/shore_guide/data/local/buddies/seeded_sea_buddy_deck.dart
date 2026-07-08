import '../../../domain/entities/buddies/sea_buddy_request.dart';
import '../../../domain/entities/buddies/sea_buddy_thread.dart';
import '../seeded_shore_moment_deck.dart';

class SeededSeaBuddyDeck {
  const SeededSeaBuddyDeck._();

  static final List<SeaBuddyThread> buddyThreads = [
    SeaBuddyThread(
      threadKey: 'leo-board-advice',
      buddyPersona: SeededShoreMomentDeck.shorelinePeople[22],
      placeRibbon: '23 - Australia',
      lastHarborTime: '',
      previewLine: '',
      unreadCount: 0,
      callGreeting: '',
      notes: const [],
    ),
    SeaBuddyThread(
      threadKey: 'nora-cafe-note',
      buddyPersona: SeededShoreMomentDeck.shorelinePeople[10],
      placeRibbon: 'Seaglass Cafe',
      lastHarborTime: '',
      previewLine: '',
      unreadCount: 0,
      callGreeting: '',
      notes: const [],
    ),
    SeaBuddyThread(
      threadKey: 'milo-sandbar',
      buddyPersona: SeededShoreMomentDeck.shorelinePeople[5],
      placeRibbon: 'Sandbar Gate',
      lastHarborTime: '',
      previewLine: '',
      unreadCount: 0,
      callGreeting: '',
      notes: const [],
    ),
    SeaBuddyThread(
      threadKey: 'isla-palms',
      buddyPersona: SeededShoreMomentDeck.shorelinePeople[6],
      placeRibbon: 'Palm Walk',
      lastHarborTime: '',
      previewLine: '',
      unreadCount: 0,
      callGreeting: '',
      notes: const [],
    ),
    SeaBuddyThread(
      threadKey: 'rowan-rail',
      buddyPersona: SeededShoreMomentDeck.shorelinePeople[3],
      placeRibbon: 'Quiet Pier',
      lastHarborTime: '',
      previewLine: '',
      unreadCount: 0,
      callGreeting: '',
      notes: const [],
    ),
    SeaBuddyThread(
      threadKey: 'celeste-foam',
      buddyPersona: SeededShoreMomentDeck.shorelinePeople[4],
      placeRibbon: 'Foamline',
      lastHarborTime: '',
      previewLine: '',
      unreadCount: 0,
      callGreeting: '',
      notes: const [],
    ),
  ];

  static final List<SeaBuddyRequest> buddyRequests = [
    SeaBuddyRequest(
      requestKey: 'donald-dressing',
      requestPersona: SeededShoreMomentDeck.shorelinePeople[24],
      placeRibbon: '23 - Australia',
      requestLine:
          'Breeze by shore, collect soft light today. Long coastline, slow down for coastal tiny joys.',
      isInitiallyFollowed: false,
    ),
    SeaBuddyRequest(
      requestKey: 'evan-cuisine',
      requestPersona: SeededShoreMomentDeck.shorelinePeople[12],
      placeRibbon: 'Lagoon Market',
      requestLine:
          'I found a quiet snack path near the lagoon and thought you might like it.',
      isInitiallyFollowed: false,
    ),
    SeaBuddyRequest(
      requestKey: 'dora-shell',
      requestPersona: SeededShoreMomentDeck.shorelinePeople[36],
      placeRibbon: 'Beacon Steps',
      requestLine:
          'Your sunwear post matched my saved route. I saved the same shoreline notes.',
      isInitiallyFollowed: true,
    ),
    SeaBuddyRequest(
      requestKey: 'kai-reefline',
      requestPersona: SeededShoreMomentDeck.shorelinePeople[19],
      placeRibbon: 'Reef Rail',
      requestLine:
          'I keep seeing your coast notes around the same tide window.',
      isInitiallyFollowed: false,
    ),
    SeaBuddyRequest(
      requestKey: 'opal-breeze',
      requestPersona: SeededShoreMomentDeck.shorelinePeople[30],
      placeRibbon: 'Breeze Point',
      requestLine:
          'Your late walk list is useful. I want to follow the next update.',
      isInitiallyFollowed: false,
    ),
  ];
}
