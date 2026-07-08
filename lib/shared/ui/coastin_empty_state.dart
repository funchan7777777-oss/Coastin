import 'package:flutter/cupertino.dart';

import '../../app/assets/coastin_asset_registry.dart';

class CoastinEmptyState extends StatelessWidget {
  const CoastinEmptyState({super.key, this.width = 104});

  final double width;

  static Widget mark({double width = 104}) {
    return CoastinEmptyState(width: width);
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      CoastinAssetRegistry.kayakDateEmptyState,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
