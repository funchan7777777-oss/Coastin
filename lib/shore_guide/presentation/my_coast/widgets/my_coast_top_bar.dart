import 'package:flutter/cupertino.dart';

import '../../../../app/theme/tidewash_palette.dart';

class MyCoastTopBar extends StatelessWidget {
  const MyCoastTopBar({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              CupertinoIcons.chevron_left,
              color: TidewashPalette.inkBlue,
              size: 28,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }
}
