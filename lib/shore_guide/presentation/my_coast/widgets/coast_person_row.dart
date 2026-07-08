import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../domain/entities/shoreline_persona.dart';
import '../../../domain/value_objects/shore_profile_current.dart';

class CoastPersonRow extends StatelessWidget {
  const CoastPersonRow({
    super.key,
    required this.persona,
    required this.localApproachRibbon,
    required this.summaryLine,
    required this.actionAsset,
    required this.onActionTap,
    this.onOpen,
  });

  final ShorelinePersona persona;
  final String localApproachRibbon;
  final String summaryLine;
  final String actionAsset;
  final VoidCallback onActionTap;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final genderGlyph = persona.profileCurrent == ShoreProfileCurrent.feminine
        ? CoastinAssetRegistry.feminineTideGlyph
        : CoastinAssetRegistry.masculineTideGlyph;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: Image.asset(
                    persona.avatarAsset,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  right: -3,
                  bottom: -2,
                  child: Image.asset(genderGlyph, width: 17, height: 17),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    persona.displayHarborName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: TidewashPalette.inkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.location_solid,
                        color: Color(0xFFFF62AC),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          localApproachRibbon,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFFF62AC),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    summaryLine,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: TidewashPalette.harborSlate,
                      fontSize: 13,
                      height: 1.32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onActionTap,
              child: SizedBox(
                width: 72,
                height: 30,
                child: Image.asset(
                  actionAsset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
