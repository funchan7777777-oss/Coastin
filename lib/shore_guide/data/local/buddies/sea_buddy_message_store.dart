import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/buddies/sea_buddy_signal_note.dart';

class SeaBuddyMessageStore {
  const SeaBuddyMessageStore();

  static const String _harborThreadMarkersKey =
      'coastin.buddies.harborThreadMarkers';

  String _harborSignalLedgerKey(String harborThreadMarker) {
    return 'coastin.buddies.harborSignal.$harborThreadMarker.signalNotes';
  }

  Future<Set<String>> restoreHarborSignalMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_harborThreadMarkersKey)?.toSet() ?? {};
  }

  Future<List<SeaBuddySignalNote>> restoreSignals(
    String harborThreadMarker,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedSignals =
        prefs.getStringList(_harborSignalLedgerKey(harborThreadMarker)) ?? [];
    return [
      for (final encoded in encodedSignals)
        if (_decodeSignal(encoded) != null) _decodeSignal(encoded)!,
    ];
  }

  Future<Map<String, SeaBuddySignalNote>> restoreLatestSignals() async {
    final harborThreadMarkers = await restoreHarborSignalMarkers();
    final latestSignals = <String, SeaBuddySignalNote>{};
    for (final harborThreadMarker in harborThreadMarkers) {
      final signals = await restoreSignals(harborThreadMarker);
      if (signals.isNotEmpty) {
        latestSignals[harborThreadMarker] = signals.last;
      }
    }
    return latestSignals;
  }

  Future<void> appendSignal(
    String harborThreadMarker,
    SeaBuddySignalNote signal,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final signals =
        prefs.getStringList(_harborSignalLedgerKey(harborThreadMarker)) ?? [];
    signals.add(
      jsonEncode({
        'signalMarker': signal.signalMarker,
        'signalText': signal.signalText,
        'sentFromViewerHarbor': signal.sentFromViewerHarbor,
      }),
    );
    await prefs.setStringList(
      _harborSignalLedgerKey(harborThreadMarker),
      signals,
    );

    final harborThreadMarkers =
        prefs.getStringList(_harborThreadMarkersKey)?.toSet() ?? {};
    harborThreadMarkers.add(harborThreadMarker);
    await prefs.setStringList(
      _harborThreadMarkersKey,
      harborThreadMarkers.toList()..sort(),
    );
  }

  Future<void> clearHarborSignals(String harborThreadMarker) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_harborSignalLedgerKey(harborThreadMarker));
    final harborThreadMarkers =
        prefs.getStringList(_harborThreadMarkersKey)?.toSet() ?? {};
    harborThreadMarkers.remove(harborThreadMarker);
    await prefs.setStringList(
      _harborThreadMarkersKey,
      harborThreadMarkers.toList()..sort(),
    );
  }

  Future<void> clearAllHarborSignals() async {
    final prefs = await SharedPreferences.getInstance();
    final harborThreadMarkers =
        prefs.getStringList(_harborThreadMarkersKey) ?? [];
    for (final harborThreadMarker in harborThreadMarkers) {
      await prefs.remove(_harborSignalLedgerKey(harborThreadMarker));
    }
    await prefs.remove(_harborThreadMarkersKey);
  }

  SeaBuddySignalNote? _decodeSignal(String encoded) {
    try {
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      return SeaBuddySignalNote(
        signalMarker: decoded['signalMarker'] as String? ?? '',
        signalText: decoded['signalText'] as String? ?? '',
        sentFromViewerHarbor: decoded['sentFromViewerHarbor'] as bool? ?? true,
      );
    } catch (_) {
      return null;
    }
  }
}
