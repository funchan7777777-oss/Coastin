import 'package:flutter/cupertino.dart';

class WaveArtButton extends StatelessWidget {
  const WaveArtButton({
    super.key,
    required this.buttonAsset,
    required this.semanticCurrent,
    required this.onPressed,
  });

  final String buttonAsset;
  final String semanticCurrent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Semantics(
        button: true,
        label: semanticCurrent,
        child: Image.asset(buttonAsset, height: 61, fit: BoxFit.fill),
      ),
    );
  }
}
