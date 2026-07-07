import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../domain/entities/buddies/sea_buddy_note.dart';
import '../../../domain/entities/buddies/sea_buddy_thread.dart';
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
  late final List<SeaBuddyNote> _notes = List.of(widget.thread.notes);
  final TextEditingController _replyController = TextEditingController();

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
                        ),
                        const SizedBox(height: 26),
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

  void _sendNote() {
    final text = _replyController.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _notes.add(
        SeaBuddyNote(
          noteKey: 'local-${DateTime.now().microsecondsSinceEpoch}',
          noteText: text,
          sentByViewer: true,
        ),
      );
      _replyController.clear();
    });
  }

  void _openVideoCall() {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => SeaBuddyCallPage(thread: widget.thread),
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Start video call'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(),
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
  const _ChatBuddyHeader({required this.thread, required this.onVideoTap});

  final SeaBuddyThread thread;
  final VoidCallback onVideoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            thread.buddyPersona.avatarAsset,
            width: 92,
            height: 92,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          thread.buddyPersona.displayHarborName,
          style: const TextStyle(
            color: TidewashPalette.inkBlue,
            fontSize: 20,
            fontWeight: FontWeight.w900,
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
