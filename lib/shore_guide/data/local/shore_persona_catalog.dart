import '../../domain/entities/buddies/sea_buddy_harbor_thread.dart';
import '../../domain/entities/shoreline_persona.dart';
import 'buddies/sea_buddy_harbor_catalog.dart';
import 'shore_moment_harbor_catalog.dart';

class ShorePersonaCatalog {
  const ShorePersonaCatalog._();

  static List<ShorelinePersona> get people {
    return ShoreMomentHarborCatalog.shorelinePeople;
  }

  static ShorelinePersona? findByHandle(String handle) {
    for (final persona in people) {
      if (persona.tideHandle == handle) {
        return persona;
      }
    }
    return null;
  }

  static SeaBuddyHarborThread harborThreadForPersona(ShorelinePersona persona) {
    for (final buddyThread in SeaBuddyHarborCatalog.buddyThreads) {
      if (buddyThread.buddyHarbor.tideHandle == persona.tideHandle) {
        return SeaBuddyHarborThread(
          harborThreadMarker: buddyThread.harborThreadMarker,
          buddyHarbor: buddyThread.buddyHarbor,
          localApproachRibbon: buddyThread.localApproachRibbon,
          lastSignalTime: buddyThread.lastSignalTime,
          lastSignalPreview: '',
          unreadSignalCount: 0,
          callWarmupLine: buddyThread.callWarmupLine,
          signalNotes: const [],
        );
      }
    }
    return SeaBuddyHarborThread(
      harborThreadMarker: 'harbor-${persona.tideHandle}',
      buddyHarbor: persona,
      localApproachRibbon: persona.profileCurrent.isFeminine
          ? '23 - Australia'
          : 'Reef Rail',
      lastSignalTime: '',
      lastSignalPreview: '',
      unreadSignalCount: 0,
      callWarmupLine: persona.coastalStamp,
      signalNotes: const [],
    );
  }
}
