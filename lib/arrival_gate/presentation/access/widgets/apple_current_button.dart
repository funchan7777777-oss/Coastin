import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';

class AppleCurrentButton extends StatelessWidget {
  const AppleCurrentButton({
    super.key,
    required this.onAppleCurrentPressed,
    this.isWorking = false,
  });

  final VoidCallback onAppleCurrentPressed;
  final bool isWorking;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isWorking ? null : onAppleCurrentPressed,
        child: Semantics(
          button: true,
          label: 'Apple',
          child: SizedBox(
            width: 47,
            height: 47,
            child: isWorking
                ? const CupertinoActivityIndicator(radius: 13)
                : Image.asset(
                    CoastinAssetRegistry.appleCurrentBadge,
                    fit: BoxFit.fill,
                  ),
          ),
        ),
      ),
    );
  }
}
