import '../../../app/assets/coastin_asset_registry.dart';

enum CeruleanTabBerth {
  beaconMap(
    activeGlyph: CoastinAssetRegistry.beaconMapActive,
    quietGlyph: CoastinAssetRegistry.beaconMapQuiet,
    spokenName: 'Coastal route board',
  ),
  sunrisePlan(
    activeGlyph: CoastinAssetRegistry.sunrisePlanActive,
    quietGlyph: CoastinAssetRegistry.sunrisePlanQuiet,
    spokenName: 'Sunrise plan shelf',
  ),
  coralGallery(
    activeGlyph: CoastinAssetRegistry.coralGalleryActive,
    quietGlyph: CoastinAssetRegistry.coralGalleryQuiet,
    spokenName: 'Coral memory gallery',
  ),
  pierThread(
    activeGlyph: CoastinAssetRegistry.pierThreadActive,
    quietGlyph: CoastinAssetRegistry.pierThreadQuiet,
    spokenName: 'Pier note thread',
  );

  const CeruleanTabBerth({
    required this.activeGlyph,
    required this.quietGlyph,
    required this.spokenName,
  });

  final String activeGlyph;
  final String quietGlyph;
  final String spokenName;
}
