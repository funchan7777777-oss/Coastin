import 'package:flutter/cupertino.dart';

class HarborCredentialField extends StatelessWidget {
  const HarborCredentialField({
    super.key,
    required this.berthLabel,
    required this.hintCurrent,
    required this.tideController,
    required this.keyboardTrail,
    required this.textInputAction,
    required this.trailingAsset,
    required this.onTrailingTap,
    this.isHiddenCurrent = false,
  });

  final String berthLabel;
  final String hintCurrent;
  final TextEditingController tideController;
  final TextInputType keyboardTrail;
  final TextInputAction textInputAction;
  final String trailingAsset;
  final VoidCallback onTrailingTap;
  final bool isHiddenCurrent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          berthLabel,
          style: const TextStyle(
            color: Color(0x8A5B767D),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 7),
        CupertinoTextField(
          controller: tideController,
          obscureText: isHiddenCurrent,
          keyboardType: keyboardTrail,
          textInputAction: textInputAction,
          autocorrect: false,
          enableSuggestions: !isHiddenCurrent,
          padding: const EdgeInsets.fromLTRB(20, 15, 47, 15),
          placeholder: hintCurrent,
          placeholderStyle: const TextStyle(
            color: Color(0x4D859BA2),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          style: const TextStyle(
            color: Color(0xFF224554),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xF7FFFFFF),
            borderRadius: BorderRadius.circular(28),
          ),
          suffix: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTrailingTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Image.asset(
                trailingAsset,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
