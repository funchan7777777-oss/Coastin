import 'package:flutter/cupertino.dart';

class BrinePrimaryButton extends StatelessWidget {
  const BrinePrimaryButton({
    super.key,
    required this.buttonLabel,
    required this.onPressed,
    this.isWorking = false,
  });

  final String buttonLabel;
  final VoidCallback onPressed;
  final bool isWorking;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isWorking ? null : onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isWorking ? 0.64 : 1,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF2F68CF),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E58BB).withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: isWorking
              ? const CupertinoActivityIndicator(color: Color(0xFFFFFFFF))
              : Text(
                  buttonLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
        ),
      ),
    );
  }
}
