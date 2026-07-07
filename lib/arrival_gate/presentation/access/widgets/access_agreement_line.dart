import 'package:flutter/cupertino.dart';

import '../../../domain/value_objects/harbor_policy_kind.dart';

class AccessAgreementLine extends StatelessWidget {
  const AccessAgreementLine({
    super.key,
    required this.agreementAnchored,
    required this.onAgreementChanged,
    required this.onPolicyOpened,
  });

  final bool agreementAnchored;
  final ValueChanged<bool> onAgreementChanged;
  final ValueChanged<HarborPolicyKind> onPolicyOpened;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onAgreementChanged(!agreementAnchored),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 10),
            child: Icon(
              agreementAnchored
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              size: 16,
              color: agreementAnchored
                  ? const Color(0xFF2F6ACE)
                  : const Color(0x7351767C),
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'I have read and agree to the ',
                style: _AgreementTextStyles.plain,
              ),
              _PolicyTapText(
                label: 'User Agreement',
                onTap: () => onPolicyOpened(HarborPolicyKind.userAgreement),
              ),
              const Text(' and ', style: _AgreementTextStyles.plain),
              _PolicyTapText(
                label: 'Privacy Policy',
                onTap: () => onPolicyOpened(HarborPolicyKind.privacyPolicy),
              ),
              const Text('.', style: _AgreementTextStyles.plain),
            ],
          ),
        ),
      ],
    );
  }
}

class _PolicyTapText extends StatelessWidget {
  const _PolicyTapText({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Text(label, style: _AgreementTextStyles.link),
      ),
    );
  }
}

class _AgreementTextStyles {
  const _AgreementTextStyles._();

  static const TextStyle plain = TextStyle(
    color: Color(0x945A747B),
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.32,
    letterSpacing: 0,
  );

  static const TextStyle link = TextStyle(
    color: Color(0xFF2F6ACE),
    fontSize: 10,
    fontWeight: FontWeight.w900,
    height: 1.32,
    letterSpacing: 0,
  );
}
