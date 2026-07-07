import '../../../domain/entities/buddies/sea_buddy_note.dart';
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
      lastHarborTime: '08:06',
      previewLine: 'Slide into bowl/ramp from edge',
      unreadCount: 3,
      callGreeting:
          'Help! I don’t know what coat to match with my new floral dress, please give me advice.',
      notes: const [
        SeaBuddyNote(
          noteKey: 'leo-1',
          noteText:
              'Help! I don’t know what coat to match with my new floral dress, please give me advice.',
          sentByViewer: false,
        ),
        SeaBuddyNote(
          noteKey: 'leo-2',
          noteText:
              'Matching a floral dress with a short knitted cardigan is the softest look, light colors work perfectly!',
          sentByViewer: true,
        ),
        SeaBuddyNote(
          noteKey: 'leo-3',
          noteText:
              'Really? I happen to have an off-white cardigan, I’m afraid it will look bulky when matched.',
          sentByViewer: false,
        ),
        SeaBuddyNote(
          noteKey: 'leo-4',
          noteText:
              'No way! Short styles just raise the waistline, try taking a photo of your upper body and show me~',
          sentByViewer: true,
        ),
      ],
    ),
    SeaBuddyThread(
      threadKey: 'nora-cafe-note',
      buddyPersona: SeededShoreMomentDeck.shorelinePeople[10],
      placeRibbon: 'Seaglass Cafe',
      lastHarborTime: '08:06',
      previewLine: 'The lemon table is open again',
      unreadCount: 3,
      callGreeting: 'The lemon table is open again if you want a quiet stop.',
      notes: const [
        SeaBuddyNote(
          noteKey: 'nora-1',
          noteText: 'The lemon table is open again if you want a quiet stop.',
          sentByViewer: false,
        ),
        SeaBuddyNote(
          noteKey: 'nora-2',
          noteText: 'Save it for me. I am five minutes from the pier.',
          sentByViewer: true,
        ),
      ],
    ),
    SeaBuddyThread(
      threadKey: 'milo-sandbar',
      buddyPersona: SeededShoreMomentDeck.shorelinePeople[5],
      placeRibbon: 'Sandbar Gate',
      lastHarborTime: '08:06',
      previewLine: 'Low tide gave us a wider path',
      unreadCount: 3,
      callGreeting: 'Low tide gave us a wider path; you should see it today.',
      notes: const [
        SeaBuddyNote(
          noteKey: 'milo-1',
          noteText: 'Low tide gave us a wider path; you should see it today.',
          sentByViewer: false,
        ),
        SeaBuddyNote(
          noteKey: 'milo-2',
          noteText: 'I can come after lunch. Keep the easy route.',
          sentByViewer: true,
        ),
      ],
    ),
    SeaBuddyThread(
      threadKey: 'isla-palms',
      buddyPersona: SeededShoreMomentDeck.shorelinePeople[6],
      placeRibbon: 'Palm Walk',
      lastHarborTime: '08:06',
      previewLine: 'Bring the blue wrap, wind is strong',
      unreadCount: 3,
      callGreeting: 'Bring the blue wrap, wind is strong near the north rail.',
      notes: const [
        SeaBuddyNote(
          noteKey: 'isla-1',
          noteText: 'Bring the blue wrap, wind is strong near the north rail.',
          sentByViewer: false,
        ),
        SeaBuddyNote(
          noteKey: 'isla-2',
          noteText: 'Good call. I almost packed the light scarf.',
          sentByViewer: true,
        ),
      ],
    ),
    SeaBuddyThread(
      threadKey: 'rowan-rail',
      buddyPersona: SeededShoreMomentDeck.shorelinePeople[3],
      placeRibbon: 'Quiet Pier',
      lastHarborTime: '08:06',
      previewLine: 'The back rail has the best shade',
      unreadCount: 3,
      callGreeting: 'The back rail has the best shade and almost no crowd.',
      notes: const [
        SeaBuddyNote(
          noteKey: 'rowan-1',
          noteText: 'The back rail has the best shade and almost no crowd.',
          sentByViewer: false,
        ),
      ],
    ),
    SeaBuddyThread(
      threadKey: 'celeste-foam',
      buddyPersona: SeededShoreMomentDeck.shorelinePeople[4],
      placeRibbon: 'Foamline',
      lastHarborTime: '08:06',
      previewLine: 'The water looks brighter today',
      unreadCount: 3,
      callGreeting: 'The water looks brighter today; perfect for quick photos.',
      notes: const [
        SeaBuddyNote(
          noteKey: 'celeste-1',
          noteText: 'The water looks brighter today; perfect for quick photos.',
          sentByViewer: false,
        ),
      ],
    ),
  ];

  static final List<SeaBuddyRequest> buddyRequests = [
    SeaBuddyRequest(
      requestKey: 'donald-dressing',
      requestPersona: SeededShoreMomentDeck.shorelinePeople[24],
      placeRibbon: '23 - Australia',
      requestLine:
          'Breeze by shore, collect seaside romance today. Long coastline, slow down for coastal tiny joys.',
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
          'Your sunwear post matched my saved route. Let’s trade shoreline ideas.',
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
