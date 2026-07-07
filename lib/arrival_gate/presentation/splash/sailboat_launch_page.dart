import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../app/assets/coastin_asset_registry.dart';

class SailboatLaunchPage extends StatefulWidget {
  const SailboatLaunchPage({super.key});

  @override
  State<SailboatLaunchPage> createState() => _SailboatLaunchPageState();
}

class _SailboatLaunchPageState extends State<SailboatLaunchPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _wakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: const Color(0x00000000),
      ),
      child: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0x00000000),
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _LaunchBackdrop(),
              Positioned(
                left: 0,
                right: 0,
                bottom: 86,
                child: _OpeningWakeDots(controller: _wakeController),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpeningWakeDots extends StatelessWidget {
  const _OpeningWakeDots({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final phase = (controller.value + index * 0.22) % 1;
            final lift = 1 - (phase - 0.5).abs() * 2;
            return Transform.translate(
              offset: Offset(0, -5 * lift),
              child: Container(
                width: 8 + 4 * lift,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Color.lerp(
                    const Color(0xFF58D4D5),
                    const Color(0xFF2F6ACE),
                    lift,
                  ),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38CBD1).withValues(alpha: 0.24),
                      blurRadius: 10 + lift * 10,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _LaunchBackdrop extends StatelessWidget {
  const _LaunchBackdrop();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Image(
        image: AssetImage(CoastinAssetRegistry.sailboatRideBackdrop),
        fit: BoxFit.fill,
      ),
    );
  }
}
