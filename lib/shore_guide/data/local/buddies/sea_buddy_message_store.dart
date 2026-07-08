import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/buddies/sea_buddy_signal_note.dart';

class SeaBuddyMessageStore {
  const SeaBuddyMessageStore();

  static const String _harborThreadMarkersKey = 'coastin.buddies.harborThreadMarkers';

  String _threadNotesKey(String harborThreadMarker) {
    return 'coastin.buddies.thread.$harborThreadMarker.signalNotes';
  }

  Future<Set<String>> restoreThreadKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_harborThreadMarkersKey)?.toSet() ?? {};
  }

  Future<List<SeaBuddySignalNote>> restoreNotes(String harborThreadMarker) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedNotes = prefs.getStringList(_threadNotesKey(harborThreadMarker)) ?? [];
    return [
      for (final encoded in encodedNotes)
        if (_decodeNote(encoded) != null) _decodeNote(encoded)!,
    ];
  }

  Future<Map<String, SeaBuddySignalNote>> restoreLatestNotes() async {
    final harborThreadMarkers = await restoreThreadKeys();
    final latestNotes = <String, SeaBuddySignalNote>{};
    for (final harborThreadMarker in harborThreadMarkers) {
      final notes = await restoreNotes(harborThreadMarker);
      if (notes.isNotEmpty) {
        latestNotes[harborThreadMarker] = notes.last;
      }
    }
    return latestNotes;
  }

  Future<void> appendNote(String harborThreadMarker, SeaBuddySignalNote note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = prefs.getStringList(_threadNotesKey(harborThreadMarker)) ?? [];
    notes.add(
      jsonEncode({
        'signalMarker': note.signalMarker,
        'signalText': note.signalText,
        'sentFromViewerHarbor': note.sentFromViewerHarbor,
      }),
    );
    await prefs.setStringList(_threadNotesKey(harborThreadMarker), notes);

    final harborThreadMarkers = prefs.getStringList(_harborThreadMarkersKey)?.toSet() ?? {};
    harborThreadMarkers.add(harborThreadMarker);
    await prefs.setStringList(_harborThreadMarkersKey, harborThreadMarkers.toList()..sort());
  }

  Future<void> clearThread(String harborThreadMarker) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_threadNotesKey(harborThreadMarker));
    final harborThreadMarkers = prefs.getStringList(_harborThreadMarkersKey)?.toSet() ?? {};
    harborThreadMarkers.remove(harborThreadMarker);
    await prefs.setStringList(_harborThreadMarkersKey, harborThreadMarkers.toList()..sort());
  }

  Future<void> clearAllThreads() async {
    final prefs = await SharedPreferences.getInstance();
    final harborThreadMarkers = prefs.getStringList(_harborThreadMarkersKey) ?? [];
    for (final harborThreadMarker in harborThreadMarkers) {
      await prefs.remove(_threadNotesKey(harborThreadMarker));
    }
    await prefs.remove(_harborThreadMarkersKey);
  }

  SeaBuddySignalNote? _decodeNote(String encoded) {
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
