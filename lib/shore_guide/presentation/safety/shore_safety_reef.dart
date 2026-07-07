import 'package:flutter/cupertino.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../../app/theme/tidewash_palette.dart';
import '../../data/local/safety/shore_safety_store.dart';
import 'shore_safety_action.dart';

class ShoreSafetyReef {
  const ShoreSafetyReef._();

  static const ShoreSafetyStore _store = ShoreSafetyStore();

  static Future<ShoreSafetyOutcome?> showGuard({
    required BuildContext context,
    required String contentId,
    required ShoreSafetyContentKind contentKind,
    required String ownerName,
    required String? ownerHandle,
  }) async {
    return showCupertinoModalPopup<ShoreSafetyOutcome>(
      context: context,
      barrierColor: const Color(0x9904121C),
      builder: (context) {
        return _SafetyWavePanel(
          contentId: contentId,
          contentKind: contentKind,
          ownerName: ownerName,
          ownerHandle: ownerHandle,
          store: _store,
        );
      },
    );
  }

  static Future<void> showFollowRequired({
    required BuildContext context,
    required String displayName,
    required VoidCallback onGoFollow,
  }) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _WaveNoticeDialog(
          wordmark: CoastinAssetRegistry.pleaseConfirmWordmark,
          iconAsset: CoastinAssetRegistry.safetyMutedMark,
          title: 'Mutual follow needed',
          message:
              'Please confirm you and $displayName follow each other before starting chat or video call.',
          actionAsset: CoastinAssetRegistry.goFollowPlate,
          onAction: () {
            Navigator.of(dialogContext).pop();
            onGoFollow();
          },
        );
      },
    );
  }

  static Future<void> showModerationQueued({
    required BuildContext context,
    required VoidCallback onDone,
  }) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _WaveNoticeDialog(
          wordmark: CoastinAssetRegistry.pleaseConfirmWordmark,
          iconAsset: CoastinAssetRegistry.safetyReportMark,
          title: 'Shared for review',
          message:
              'Your Coastin update was submitted successfully. It will stay in background review and only appear after approval.',
          actionLabel: 'Done',
          onAction: () {
            Navigator.of(dialogContext).pop();
            onDone();
          },
        );
      },
    );
  }

  static Future<bool> showCallChargeConfirm({
    required BuildContext context,
    required String displayName,
  }) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _WaveNoticeDialog(
          wordmark: CoastinAssetRegistry.consumptionConfirmWordmark,
          iconAsset: CoastinAssetRegistry.detailInfoGlyph,
          title: 'Video call',
          message:
              'The current operation will consume 50 shells. Confirm before calling $displayName.',
          actionLabel: 'Confirm',
          onAction: () => Navigator.of(dialogContext).pop(true),
        );
      },
    );
    return confirmed ?? false;
  }

  static Future<void> showAccountDone({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _WaveNoticeDialog(
          wordmark: CoastinAssetRegistry.pleaseConfirmWordmark,
          iconAsset: CoastinAssetRegistry.safetyReportMark,
          title: title,
          message: message,
          actionLabel: 'Continue',
          onAction: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }
}

class _SafetyWavePanel extends StatefulWidget {
  const _SafetyWavePanel({
    required this.contentId,
    required this.contentKind,
    required this.ownerName,
    required this.ownerHandle,
    required this.store,
  });

  final String contentId;
  final ShoreSafetyContentKind contentKind;
  final String ownerName;
  final String? ownerHandle;
  final ShoreSafetyStore store;

  @override
  State<_SafetyWavePanel> createState() => _SafetyWavePanelState();
}

class _SafetyWavePanelState extends State<_SafetyWavePanel> {
  bool _isReport = true;
  String _reason = 'Harassment or bullying';

  static const List<String> _reasons = [
    'Harassment or bullying',
    'Unsafe or illegal content',
    'Spam or misleading content',
    'Sexual or adult content',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox.expand(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.48,
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(CoastinAssetRegistry.profileWavePanel),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        _isReport
                            ? CoastinAssetRegistry.safetyReportMark
                            : CoastinAssetRegistry.safetyMutedMark,
                        width: 42,
                        height: 42,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isReport
                              ? 'Report ${widget.contentKind.label}'
                              : 'Block ${widget.ownerName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: TidewashPalette.inkBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          CupertinoIcons.xmark_circle,
                          color: Color(0xFFFFFFFF),
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _ModePill(
                        title: 'Report',
                        isSelected: _isReport,
                        onTap: () => setState(() => _isReport = true),
                      ),
                      const SizedBox(width: 12),
                      _ModePill(
                        title: 'Block',
                        isSelected: !_isReport,
                        onTap: () => setState(() => _isReport = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (_isReport)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final reason in _reasons)
                          _ReasonChip(
                            reason: reason,
                            isSelected: _reason == reason,
                            onTap: () => setState(() => _reason = reason),
                          ),
                      ],
                    )
                  else
                    Text(
                      'Blocked people and their content will be hidden across Coastin, including feeds, comments, and messages.',
                      style: TextStyle(
                        color: TidewashPalette.harborSlate.withValues(alpha: 0.78),
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _submit,
                    child: Container(
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F68D3),
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2F68D3).withValues(alpha: 0.2),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        _isReport ? 'Submit report' : 'Block profile',
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_isReport) {
      await widget.store.reportContent(
        contentId: widget.contentId,
        contentKind: widget.contentKind.label,
        reason: _reason,
        ownerHandle: widget.ownerHandle,
      );
    } else if (widget.ownerHandle != null) {
      await widget.store.blockHandle(widget.ownerHandle!);
    }
    if (!mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pop(_isReport ? ShoreSafetyOutcome.reported : ShoreSafetyOutcome.blocked);
    await _showSavedNotice(context, isReport: _isReport);
  }

  Future<void> _showSavedNotice(
    BuildContext context, {
    required bool isReport,
  }) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _WaveNoticeDialog(
          wordmark: CoastinAssetRegistry.pleaseConfirmWordmark,
          iconAsset: isReport
              ? CoastinAssetRegistry.safetyReportMark
              : CoastinAssetRegistry.safetyMutedMark,
          title: isReport ? 'Report saved' : 'Profile blocked',
          message: isReport
              ? 'Thanks for helping keep Coastin safe. This item will no longer appear for you.'
              : '${widget.ownerName} and their content will stay hidden from your Coastin experience.',
          actionLabel: 'OK',
          onAction: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2F68D3)
                : const Color(0xFFFFFFFF).withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(21),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFFFFFFF)
                  : TidewashPalette.inkBlue,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  final String reason;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFE894)
              : const Color(0xFFFFFFFF).withValues(alpha: 0.76),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFE9B22A) : const Color(0x00FFFFFF),
          ),
        ),
        child: Text(
          reason,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFB98000)
                : TidewashPalette.harborSlate,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _WaveNoticeDialog extends StatelessWidget {
  const _WaveNoticeDialog({
    required this.wordmark,
    required this.iconAsset,
    required this.title,
    required this.message,
    required this.onAction,
    this.actionAsset,
    this.actionLabel,
  });

  final String wordmark;
  final String iconAsset;
  final String title;
  final String message;
  final VoidCallback onAction;
  final String? actionAsset;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoPopupSurface(
        isSurfacePainted: false,
        child: Container(
          width: 314,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            image: const DecorationImage(
              image: AssetImage(CoastinAssetRegistry.profileWavePanel),
              fit: BoxFit.fill,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F5D94).withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                wordmark,
                width: 205,
                height: 34,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: 16),
              Image.asset(iconAsset, width: 48, height: 48),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TidewashPalette.inkBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TidewashPalette.inkBlue.withValues(alpha: 0.76),
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onAction,
                child: actionAsset == null
                    ? Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F68D3),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Text(
                          actionLabel ?? 'OK',
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 44,
                        child: Image.asset(
                          actionAsset!,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
