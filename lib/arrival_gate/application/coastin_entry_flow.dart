import 'package:flutter/cupertino.dart';

import '../../app/navigation/coastin_home_route.dart';
import '../../shore_guide/data/local/buddies/shore_system_notice_store.dart';
import '../data/local/harbor_passage_store.dart';
import '../presentation/access/harbor_access_page.dart';
import '../presentation/splash/sailboat_launch_page.dart';

class CoastinEntryFlow extends StatefulWidget {
  const CoastinEntryFlow({super.key});

  @override
  State<CoastinEntryFlow> createState() => _CoastinEntryFlowState();
}

class _CoastinEntryFlowState extends State<CoastinEntryFlow> {
  final HarborPassageStore _passageStore = const HarborPassageStore();
  final ShoreSystemNoticeStore _noticeStore = const ShoreSystemNoticeStore();
  _CoastinEntryPhase _entryPhase = _CoastinEntryPhase.loading;

  @override
  void initState() {
    super.initState();
    _prepareHarborGate();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: switch (_entryPhase) {
        _CoastinEntryPhase.loading => const SailboatLaunchPage(),
        _CoastinEntryPhase.harborAccess => HarborAccessPage(
          passageStore: _passageStore,
          onHarborCleared: _openMorningBoard,
        ),
        _CoastinEntryPhase.morningBoard => CoastinHomeRoute.openingBoard(),
      },
    );
  }

  Future<void> _prepareHarborGate() async {
    await Future<void>.delayed(const Duration(milliseconds: 1650));
    final restoredPassage = await _passageStore.restoreSettledPassage();
    if (!mounted) {
      return;
    }
    if (restoredPassage != null) {
      await _noticeStore.ensureLoginFollowerArrivals();
      if (!mounted) {
        return;
      }
      setState(() => _entryPhase = _CoastinEntryPhase.morningBoard);
      return;
    }

    setState(() => _entryPhase = _CoastinEntryPhase.harborAccess);
  }

  void _openMorningBoard() {
    _openBoardAfterFollowerArrivals();
  }

  Future<void> _openBoardAfterFollowerArrivals() async {
    await _noticeStore.ensureLoginFollowerArrivals();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute<void>(builder: (_) => CoastinHomeRoute.openingBoard()),
      (_) => false,
    );
  }
}

enum _CoastinEntryPhase { loading, harborAccess, morningBoard }
