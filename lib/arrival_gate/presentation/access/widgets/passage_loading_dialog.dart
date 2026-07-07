import 'package:flutter/cupertino.dart';

Future<void> showPassageLoadingDialog({
  required BuildContext context,
  required Duration duration,
  String message = 'Settling your harbor pass...',
}) async {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => _PassageLoadingOverlay(message: message),
  );
  overlay.insert(entry);
  await Future<void>.delayed(duration);
  entry.remove();
}

class _PassageLoadingOverlay extends StatelessWidget {
  const _PassageLoadingOverlay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x55223645),
      child: Center(child: _PassageLoadingCard(message: message)),
    );
  }
}

class _PassageLoadingCard extends StatefulWidget {
  const _PassageLoadingCard({required this.message});

  final String message;

  @override
  State<_PassageLoadingCard> createState() => _PassageLoadingCardState();
}

class _PassageLoadingCardState extends State<_PassageLoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _barController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D5F8B).withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CupertinoActivityIndicator(radius: 16),
          const SizedBox(height: 16),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF17324A),
              fontSize: 15,
              fontWeight: FontWeight.w900,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: _barController,
            builder: (context, _) {
              return Row(
                children: List.generate(5, (index) {
                  final distance = (_barController.value * 4 - index).abs();
                  final glow = (1 - distance.clamp(0.0, 1.0)).toDouble();
                  return Expanded(
                    child: Container(
                      height: 6 + glow * 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          const Color(0x4438D5D5),
                          const Color(0xFF2F68CF),
                          glow,
                        ),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
