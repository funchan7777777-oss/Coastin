import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/buddies/sea_buddy_note.dart';

class SeaBuddyMessageStore {
  const SeaBuddyMessageStore();

  static const String _threadKeysKey = 'coastin.buddies.threadKeys';

  String _threadNotesKey(String threadKey) {
    return 'coastin.buddies.thread.$threadKey.notes';
  }

  Future<Set<String>> restoreThreadKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_threadKeysKey)?.toSet() ?? {};
  }

  Future<List<SeaBuddyNote>> restoreNotes(String threadKey) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedNotes = prefs.getStringList(_threadNotesKey(threadKey)) ?? [];
    return [
      for (final encoded in encodedNotes)
        if (_decodeNote(encoded) != null) _decodeNote(encoded)!,
    ];
  }

  Future<void> appendNote(String threadKey, SeaBuddyNote note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = prefs.getStringList(_threadNotesKey(threadKey)) ?? [];
    notes.add(
      jsonEncode({
        'noteKey': note.noteKey,
        'noteText': note.noteText,
        'sentByViewer': note.sentByViewer,
      }),
    );
    await prefs.setStringList(_threadNotesKey(threadKey), notes);

    final threadKeys = prefs.getStringList(_threadKeysKey)?.toSet() ?? {};
    threadKeys.add(threadKey);
    await prefs.setStringList(_threadKeysKey, threadKeys.toList()..sort());
  }

  Future<void> clearThread(String threadKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_threadNotesKey(threadKey));
    final threadKeys = prefs.getStringList(_threadKeysKey)?.toSet() ?? {};
    threadKeys.remove(threadKey);
    await prefs.setStringList(_threadKeysKey, threadKeys.toList()..sort());
  }

  SeaBuddyNote? _decodeNote(String encoded) {
    try {
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      return SeaBuddyNote(
        noteKey: decoded['noteKey'] as String? ?? '',
        noteText: decoded['noteText'] as String? ?? '',
        sentByViewer: decoded['sentByViewer'] as bool? ?? true,
      );
    } catch (_) {
      return null;
    }
  }
}
