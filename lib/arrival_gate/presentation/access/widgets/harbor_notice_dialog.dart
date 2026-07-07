import 'package:flutter/cupertino.dart';

import '../../../domain/value_objects/harbor_policy_kind.dart';
import '../../policy/harbor_policy_webview_page.dart';

Future<void> showHarborNotice({
  required BuildContext context,
  required String title,
  required String message,
  String actionLabel = 'Got it',
  String? secondaryLabel,
  VoidCallback? onAction,
}) {
  return showCupertinoDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      void closeThenAct() {
        Navigator.of(dialogContext).pop();
        onAction?.call();
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xF8F9FFFC),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0x22FFFFFF)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0C4F73).withValues(alpha: 0.18),
                  blurRadius: 26,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _NoticeHeader(),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF17324A),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xB051767C),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.36,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SoftDivider(),
                  const SizedBox(height: 12),
                  if (secondaryLabel == null)
                    _NoticeActionButton(
                      label: actionLabel,
                      isPrimary: true,
                      onPressed: closeThenAct,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _NoticeActionButton(
                            label: secondaryLabel,
                            isPrimary: false,
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _NoticeActionButton(
                            label: actionLabel,
                            isPrimary: true,
                            onPressed: closeThenAct,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showAgreementRequiredNotice(BuildContext context) {
  return showHarborNotice(
    context: context,
    title: 'Agreement needed',
    message:
        'Please review and accept the Terms of Service and Privacy Policy before continuing.',
    actionLabel: 'Review',
    secondaryLabel: 'Later',
    onAction: () {
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => const HarborPolicyWebviewPage(
            policyKind: HarborPolicyKind.userAgreement,
          ),
        ),
      );
    },
  );
}

class _NoticeHeader extends StatelessWidget {
  const _NoticeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0x2238D5D5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            CupertinoIcons.checkmark_seal,
            color: Color(0xFF2F68CF),
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Coastin',
          style: TextStyle(
            color: Color(0xFF2F68CF),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x0038D5D5), Color(0x4438D5D5), Color(0x0038D5D5)],
        ),
      ),
    );
  }
}

class _NoticeActionButton extends StatelessWidget {
  const _NoticeActionButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF2F68CF) : const Color(0x1F2F68CF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF2F68CF),
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
