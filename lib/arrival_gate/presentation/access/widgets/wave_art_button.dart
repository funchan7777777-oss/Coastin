import 'package:flutter/cupertino.dart';

class WaveArtButton extends StatelessWidget {
  const WaveArtButton({
    super.key,
    required this.buttonAsset,
    required this.semanticCurrent,
    required this.onPressed,
    this.buttonHeight = 61,
    this.buttonWidth,
  });

  final String buttonAsset;
  final String semanticCurrent;
  final VoidCallback onPressed;
  final double buttonHeight;
  final double? buttonWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Semantics(
        button: true,
        label: semanticCurrent,
        child: Image.asset(
          buttonAsset,
          width: buttonWidth,
          height: buttonHeight,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
