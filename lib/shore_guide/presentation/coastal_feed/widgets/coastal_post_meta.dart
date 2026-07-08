import '../../../domain/entities/feed/coastal_post_dispatch.dart';

String coastalPostOriginLine(CoastalPostDispatch post) {
  final age = _ageFromPlaceRibbon(post.placeRibbon) ??
      _fallbackAgeForHandle(post.authorHarbor.tideHandle);
  final country = _countryFromPlaceRibbon(post.placeRibbon);
  return '$age · $country';
}

int coastalPostReplyCount(CoastalPostDispatch post) => post.replyDrifts.length;

String _countryFromPlaceRibbon(String placeRibbon) {
  final parts = placeRibbon.split('-');
  final marker = (parts.length > 1 ? parts.last : parts.first).trim();
  const countryByMarker = {
    'Aruba': 'Aruba',
    'Australia': 'Australia',
    'Bali': 'Indonesia',
    'Cebu': 'Philippines',
    'Crete': 'Greece',
    'Durban': 'South Africa',
    'Kona': 'United States',
    'Lisbon': 'Portugal',
    'Nice': 'France',
    'Sanya': 'China',
  };
  return countryByMarker[marker] ?? marker;
}

int? _ageFromPlaceRibbon(String placeRibbon) {
  final firstPart = placeRibbon.split('-').first.trim();
  return int.tryParse(firstPart);
}

int _fallbackAgeForHandle(String tideHandle) {
  final handleSeed = tideHandle.codeUnits.fold<int>(
    0,
    (total, unit) => total + unit,
  );
  return 22 + handleSeed % 9;
}
