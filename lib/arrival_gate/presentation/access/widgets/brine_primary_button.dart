import 'package:flutter/cupertino.dart';

class BrinePrimaryButton extends StatelessWidget {
  const BrinePrimaryButton({
    super.key,
    required this.buttonLabel,
    required this.onPressed,
    this.isWorking = false,
    this.buttonHeight = 54,
    this.buttonWidth,
    this.fontSize = 16,
  });

  final String buttonLabel;
  final VoidCallback onPressed;
  final bool isWorking;
  final double buttonHeight;
  final double? buttonWidth;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isWorking ? null : onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isWorking ? 0.64 : 1,
        child: Container(
          width: buttonWidth,
          height: buttonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF2F68CF),
            borderRadius: BorderRadius.circular(buttonHeight / 2),
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
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
        ),
      ),
    );
  }
}
