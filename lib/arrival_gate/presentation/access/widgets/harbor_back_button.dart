import 'package:flutter/cupertino.dart';

class HarborBackButton extends StatelessWidget {
  const HarborBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: const SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Icon(
            CupertinoIcons.chevron_left,
            color: Color(0xFF17324A),
            size: 30,
          ),
        ),
      ),
    );
  }
}
