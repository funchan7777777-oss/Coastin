import 'package:flutter/cupertino.dart';

class SeaBuddyWash extends StatelessWidget {
  const SeaBuddyWash({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF7DA),
            const Color(0xFFE9F8E7),
            const Color(0xFFBEF8F1).withValues(alpha: 0.98),
          ],
        ),
      ),
    );
  }
}
