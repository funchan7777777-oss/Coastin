import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/coastin_empty_state.dart';
import '../../../data/local/buddies/sea_buddy_message_store.dart';
import '../../../data/local/safety/shore_safety_store.dart';
import '../../../domain/entities/buddies/sea_buddy_note.dart';
import '../../../domain/entities/buddies/sea_buddy_thread.dart';
import '../../people/shore_persona_detail_page.dart';
import '../../safety/shore_safety_reef.dart';
import '../call/sea_buddy_call_page.dart';
import '../widgets/sea_buddy_top_bar.dart';
import '../widgets/sea_buddy_wash.dart';

class SeaBuddyChatPage extends StatefulWidget {
  const SeaBuddyChatPage({super.key, required this.thread});

  final SeaBuddyThread thread;

  @override
  State<SeaBuddyChatPage> createState() => _SeaBuddyChatPageState();
}

class _SeaBuddyChatPageState extends State<SeaBuddyChatPage> {
  final SeaBuddyMessageStore _messageStore = const SeaBuddyMessageStore();
  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();
  List<SeaBuddyNote> _notes = const [];
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _restoreNotes();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFFF7DA),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            const Positioned.fill(child: SeaBuddyWash()),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 54, 20, 126),
                    child: Column(
                      children: [
                        SeaBuddyTopBar(
                          title: '',
                          onBack: () => Navigator.of(context).pop(),
                          onInfo: _showThreadInfo,
                        ),
                        const SizedBox(height: 10),
                        _ChatBuddyHeader(
                          thread: widget.thread,
                          onVideoTap: _openVideoCall,
                          onPersonaTap: _openPersona,
                        ),
                        const SizedBox(height: 26),
                        if (_notes.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 80),
                            child: CoastinEmptyState(width: 104),
                          )
                        else
                          for (final note in _notes) ...[
                            _SeaChatBubble(note: note),
                            const SizedBox(height: 20),
                          ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: _SeaReplyComposer(
                controller: _replyController,
                onSend: _sendNote,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restoreNotes() async {
    final notes = await _messageStore.restoreNotes(widget.thread.threadKey);
    if (!mounted) {
      return;
    }
    setState(() => _notes = notes);
  }

  Future<bool> _ensureMutual() async {
    final handle = widget.thread.buddyPersona.tideHandle;
    final canChat = await _safetyStore.isMutual(handle);
    if (canChat) {
      return true;
    }
    if (!mounted) {
      return false;
    }
    await ShoreSafetyReef.showFollowRequired(
      context: context,
      displayName: widget.thread.buddyPersona.displayHarborName,
      onGoFollow: () async {
        await _safetyStore.follow(handle);
      },
    );
    return false;
  }

  Future<void> _sendNote() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) {
      return;
    }
    if (!await _ensureMutual()) {
      return;
    }
    final note = SeaBuddyNote(
      noteKey: 'local-${DateTime.now().microsecondsSinceEpoch}',
      noteText: text,
      sentByViewer: true,
    );
    await _messageStore.appendNote(widget.thread.threadKey, note);
    if (!mounted) {
      return;
    }
    setState(() {
      _notes = [..._notes, note];
      _replyController.clear();
    });
  }

  Future<void> _openVideoCall() async {
    if (!await _ensureMutual()) {
      return;
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => SeaBuddyCallPage(thread: widget.thread),
      ),
    );
  }

  void _openPersona() {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShorePersonaDetailPage(
          persona: widget.thread.buddyPersona,
          placeRibbon: widget.thread.placeRibbon,
        ),
      ),
    );
  }

  void _showThreadInfo() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(widget.thread.buddyPersona.displayHarborName),
          message: Text(widget.thread.buddyPersona.coastalStamp),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _openVideoCall();
              },
              child: const Text('Start video call'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(context).pop();
                await _messageStore.clearThread(widget.thread.threadKey);
                await _restoreNotes();
              },
              child: const Text('Clear conversation'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }
}

class _ChatBuddyHeader extends StatelessWidget {
  const _ChatBuddyHeader({
    required this.thread,
    required this.onVideoTap,
    required this.onPersonaTap,
  });

  final SeaBuddyThread thread;
  final VoidCallback onVideoTap;
  final VoidCallback onPersonaTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPersonaTap,
          child: ClipOval(
            child: Image.asset(
              thread.buddyPersona.avatarAsset,
              width: 92,
              height: 92,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPersonaTap,
          child: Text(
            thread.buddyPersona.displayHarborName,
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onVideoTap,
          child: SizedBox(
            width: 86,
            height: 42,
            child: Image.asset(
              CoastinAssetRegistry.videoCallPlate,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ],
    );
  }
}

class _SeaChatBubble extends StatelessWidget {
  const _SeaChatBubble({required this.note});

  final SeaBuddyNote note;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: note.sentByViewer
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            color: note.sentByViewer
                ? const Color(0xFF2F68D3)
                : const Color(0xFFFFFFFF).withValues(alpha: 0.92),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(note.sentByViewer ? 18 : 6),
              bottomRight: Radius.circular(note.sentByViewer ? 6 : 18),
            ),
          ),
          child: Text(
            note.noteText,
            style: TextStyle(
              color: note.sentByViewer
                  ? const Color(0xFFFFFFFF)
                  : TidewashPalette.inkBlue,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SeaReplyComposer extends StatelessWidget {
  const _SeaReplyComposer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Please enter...',
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(24),
            ),
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSend,
          child: SizedBox(
            width: 82,
            height: 44,
            child: Image.asset(
              CoastinAssetRegistry.commentButtonPlate,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ],
    );
  }
}
