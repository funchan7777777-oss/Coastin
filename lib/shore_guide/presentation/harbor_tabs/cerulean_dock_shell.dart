import 'package:flutter/cupertino.dart';

import '../../domain/entities/shoreline_day_plan.dart';
import '../board/shoreline_board_page.dart';
import 'cerulean_tab_berth.dart';
import 'pages/coral_gallery_page.dart';
import 'pages/pier_thread_page.dart';
import 'pages/sunrise_plan_page.dart';
import 'widgets/cerulean_trip_tabbar.dart';

class CeruleanDockShell extends StatefulWidget {
  const CeruleanDockShell({super.key, required this.harborBoard});

  final ShorelineDayPlan harborBoard;

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
                ShorelineBoardPage(
                  harborBoard: widget.harborBoard,
                  bottomDockClearance: _dockClearance,
                ),
                const SunrisePlanPage(bottomDockClearance: _dockClearance),
                const CoralGalleryPage(bottomDockClearance: _dockClearance),
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
