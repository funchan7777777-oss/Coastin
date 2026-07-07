import 'package:flutter/cupertino.dart';

Future<void> showHarborNotice({
  required BuildContext context,
  required String title,
  required String message,
  String actionLabel = 'Got it',
}) {
  return showCupertinoDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FFFC),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D5F8B).withValues(alpha: 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38D5D5), Color(0xFF2F68CF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      CupertinoIcons.waveform_path,
                      color: Color(0xFFFFFFFF),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF17324A),
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0x9951767C),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.36,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 19),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F68CF),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
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
        'Please read and agree to the User Agreement and Privacy Policy before continuing.',
    actionLabel: 'Review',
  );
}
