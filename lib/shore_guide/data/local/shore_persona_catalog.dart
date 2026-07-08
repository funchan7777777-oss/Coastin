import '../../domain/entities/buddies/sea_buddy_thread.dart';
import '../../domain/entities/shoreline_persona.dart';
import 'buddies/seeded_sea_buddy_deck.dart';
import 'seeded_shore_moment_deck.dart';

class ShorePersonaCatalog {
  const ShorePersonaCatalog._();

  static List<ShorelinePersona> get people {
    return SeededShoreMomentDeck.shorelinePeople;
  }

  static ShorelinePersona? findByHandle(String handle) {
    for (final persona in people) {
      if (persona.tideHandle == handle) {
        return persona;
      }
    }
    return null;
  }

  static SeaBuddyThread threadForPersona(ShorelinePersona persona) {
    for (final thread in SeededSeaBuddyDeck.buddyThreads) {
      if (thread.buddyPersona.tideHandle == persona.tideHandle) {
        return SeaBuddyThread(
          threadKey: thread.threadKey,
          buddyPersona: thread.buddyPersona,
          placeRibbon: thread.placeRibbon,
          lastHarborTime: thread.lastHarborTime,
          previewLine: '',
          unreadCount: 0,
          callGreeting: thread.callGreeting,
          notes: const [],
        );
      }
    }
    return SeaBuddyThread(
      threadKey: 'thread-${persona.tideHandle}',
      buddyPersona: persona,
      placeRibbon: persona.profileCurrent.isFeminine
          ? '23 - Australia'
          : 'Reef Rail',
      lastHarborTime: '',
      previewLine: '',
      unreadCount: 0,
      callGreeting: persona.coastalStamp,
      notes: const [],
    );
  }
}
