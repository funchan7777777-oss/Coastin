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
    required ShoreSafetyContentChannel contentChannel,
    required String ownerName,
    required String? ownerHandle,
  }) async {
    return showCupertinoModalPopup<ShoreSafetyOutcome>(
      context: context,
      barrierColor: const Color(0x9904121C),
      builder: (context) {
        return _SafetyWavePanel(
          contentId: contentId,
          contentChannel: contentChannel,
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
          showHeaderVisuals: false,
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
    required this.contentChannel,
    required this.ownerName,
    required this.ownerHandle,
    required this.store,
  });

  final String contentId;
  final ShoreSafetyContentChannel contentChannel;
  final String ownerName;
  final String? ownerHandle;
  final ShoreSafetyStore store;

  @override
  State<_SafetyWavePanel> createState() => _SafetyWavePanelState();
}

class _SafetyWavePanelState extends State<_SafetyWavePanel> {
  bool _isReport = true;
  static const String _defaultReportReason = 'Safety review requested';

  @override
  Widget build(BuildContext context) {
    final viewportSize = MediaQuery.sizeOf(context);
    const panelSize = Size(420, 300);
    final panelWidth = viewportSize.width < panelSize.width
        ? viewportSize.width
        : panelSize.width;
    final panelHeight = viewportSize.height < panelSize.height
        ? viewportSize.height
        : panelSize.height;
    const contentDrop = 28.0;

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
              width: panelWidth,
              height: panelHeight,
              padding: const EdgeInsets.fromLTRB(34, 42 + contentDrop, 34, 24),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          CoastinAssetRegistry.commentSectionWordmark,
                          width: 150,
                          height: 19,
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFFFFFFFF,
                            ).withValues(alpha: 0.96),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF095B81,
                                ).withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.xmark,
                            color: Color(0xFF2F68D3),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _SafetyModeCard(
                        title: 'Report',
                        activeIconAsset: CoastinAssetRegistry.safetyReportMark,
                        quietIconAsset: CoastinAssetRegistry.safetyMutedMark,
                        isSelected: _isReport,
                        onTap: () => setState(() => _isReport = true),
                      ),
                      const SizedBox(width: 16),
                      _SafetyModeCard(
                        title: 'Block',
                        activeIconAsset: CoastinAssetRegistry.warningBlueBadge,
                        quietIconAsset: CoastinAssetRegistry.warningMutedBadge,
                        isSelected: !_isReport,
                        onTap: () => setState(() => _isReport = false),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _submit,
                    child: Center(
                      child: SizedBox(
                        width: 226,
                        height: 44,
                        child: Image.asset(
                          CoastinAssetRegistry.confirmButtonPlate,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
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
        contentChannel: widget.contentChannel.label,
        reason: _defaultReportReason,
        ownerHandle: widget.ownerHandle,
      );
    } else if (widget.ownerHandle != null) {
      await widget.store.blockHandle(widget.ownerHandle!);
    }
    if (!mounted) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    Navigator.of(
      context,
    ).pop(_isReport ? ShoreSafetyOutcome.reported : ShoreSafetyOutcome.blocked);
    await _showSavedNotice(rootContext, isReport: _isReport);
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

class _SafetyModeCard extends StatelessWidget {
  const _SafetyModeCard({
    required this.title,
    required this.activeIconAsset,
    required this.quietIconAsset,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String activeIconAsset;
  final String quietIconAsset;
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
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFDCEAFF).withValues(alpha: 0.92)
                : const Color(0xFFFFFFFF).withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2F68D3)
                  : const Color(0x00FFFFFF),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A6F84).withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: isSelected ? 1 : 0.44,
                child: Image.asset(
                  isSelected ? activeIconAsset : quietIconAsset,
                  width: 26,
                  height: 26,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF2F68D3)
                      : TidewashPalette.harborSlate.withValues(alpha: 0.52),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
    this.showHeaderVisuals = true,
  });

  final String wordmark;
  final String iconAsset;
  final String title;
  final String message;
  final VoidCallback onAction;
  final String? actionAsset;
  final String? actionLabel;
  final bool showHeaderVisuals;

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
              if (showHeaderVisuals) ...[
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
              ],
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
