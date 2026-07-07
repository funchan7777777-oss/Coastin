import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';

enum UndertowGuardChoice { report, block }

class UndertowGuardSheet extends StatefulWidget {
  const UndertowGuardSheet({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onConfirmed,
  });

  final bool isOpen;
  final VoidCallback onClose;
  final ValueChanged<UndertowGuardChoice> onConfirmed;

  @override
  State<UndertowGuardSheet> createState() => _UndertowGuardSheetState();
}

class _UndertowGuardSheetState extends State<UndertowGuardSheet> {
  UndertowGuardChoice _choice = UndertowGuardChoice.report;

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.36;

    return Stack(
      children: [
        IgnorePointer(
          ignoring: !widget.isOpen,
          child: AnimatedOpacity(
            opacity: widget.isOpen ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onClose,
              child: Container(color: const Color(0x99000000)),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          left: 0,
          right: 0,
          bottom: widget.isOpen ? 0 : -sheetHeight,
          height: sheetHeight,
          child: IgnorePointer(
            ignoring: !widget.isOpen,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    CoastinAssetRegistry.wavePanelBackdrop,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 18,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onClose,
                    child: const Icon(
                      CupertinoIcons.xmark_circle,
                      color: Color(0xFFFFFFFF),
                      size: 28,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 46, 24, 22),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _GuardChoiceTile(
                              choice: UndertowGuardChoice.report,
                              currentChoice: _choice,
                              iconAsset: CoastinAssetRegistry.warningBlueBadge,
                              title: 'Report',
                              onTap: _choose,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: _GuardChoiceTile(
                              choice: UndertowGuardChoice.block,
                              currentChoice: _choice,
                              iconAsset: CoastinAssetRegistry.warningMutedBadge,
                              title: 'Block',
                              onTap: _choose,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onConfirmed(_choice),
                        child: SizedBox(
                          width: 264,
                          height: 58,
                          child: Image.asset(
                            CoastinAssetRegistry.confirmButtonPlate,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _choose(UndertowGuardChoice choice) {
    setState(() => _choice = choice);
  }
}

class _GuardChoiceTile extends StatelessWidget {
  const _GuardChoiceTile({
    required this.choice,
    required this.currentChoice,
    required this.iconAsset,
    required this.title,
    required this.onTap,
  });

  final UndertowGuardChoice choice;
  final UndertowGuardChoice currentChoice;
  final String iconAsset;
  final String title;
  final ValueChanged<UndertowGuardChoice> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = choice == currentChoice;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(choice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 118,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE7F0FF).withValues(alpha: 0.94)
              : const Color(0xFFFFFFFF).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF2F68D3)
                : TidewashPalette.pierLine.withValues(alpha: 0.4),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconAsset,
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF2F68D3)
                    : TidewashPalette.harborSlate.withValues(alpha: 0.58),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
