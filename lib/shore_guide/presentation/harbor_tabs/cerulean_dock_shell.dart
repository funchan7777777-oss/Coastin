import 'package:flutter/cupertino.dart';

import '../coastal_feed/coastal_feed_page.dart';
import '../moments/share_moments_page.dart';
import '../sea_buddies/sea_buddies_page.dart';
import 'cerulean_tab_berth.dart';
import 'pages/pier_thread_page.dart';
import 'widgets/cerulean_trip_tabbar.dart';

class CeruleanDockShell extends StatefulWidget {
  const CeruleanDockShell({super.key});

  @override
  State<CeruleanDockShell> createState() => _CeruleanDockShellState();
}

class _CeruleanDockShellState extends State<CeruleanDockShell> {
  static const double _dockClearance = CeruleanTripTabbar.boardHeight + 20;

  CeruleanTabBerth _currentBerth = CeruleanTabBerth.beaconMap;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
      child: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentBerth.index,
              children: [
                const ShareMomentsPage(bottomDockClearance: _dockClearance),
                const CoastalFeedPage(bottomDockClearance: _dockClearance),
                const SeaBuddiesPage(bottomDockClearance: _dockClearance),
                const PierThreadPage(bottomDockClearance: _dockClearance),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CeruleanTripTabbar(
              currentBerth: _currentBerth,
              onBerthChanged: (berth) {
                if (berth == _currentBerth) {
                  return;
                }
                setState(() => _currentBerth = berth);
              },
            ),
          ),
        ],
      ),
    );
  }
}
