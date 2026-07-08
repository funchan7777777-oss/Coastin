import '../entities/shoreline_persona.dart';

String coastinCountryFromApproachRibbon(String? localApproachRibbon) {
  return _countryFromApproachRibbon(localApproachRibbon) ?? '';
}

String coastinCountryForPersona(
  ShorelinePersona persona, {
  String? localApproachRibbon,
}) {
  final country = _countryFromApproachRibbon(localApproachRibbon);
  if (country != null) {
    return country;
  }
  return _fallbackCountryForPersona(persona);
}

String? _countryFromApproachRibbon(String? localApproachRibbon) {
  final marker = _approachMarker(localApproachRibbon);
  if (marker.isEmpty) {
    return null;
  }
  return _countryByMarker[marker];
}

String _approachMarker(String? localApproachRibbon) {
  final rawApproach = localApproachRibbon?.trim() ?? '';
  if (rawApproach.isEmpty) {
    return '';
  }
  final parts = rawApproach.split(RegExp(r'\s+-\s+'));
  return (parts.length > 1 ? parts.last : parts.first).trim();
}

const Map<String, String> _countryByMarker = {
  'Aruba': 'Aruba',
  'Australia': 'Australia',
  'Bali': 'Indonesia',
  'Beacon Steps': 'China',
  'Boardwalk': 'United States',
  'Breeze Point': 'Australia',
  'Cebu': 'Philippines',
  'China': 'China',
  'Coral Cove': 'Australia',
  'Cove Lane': 'Philippines',
  'Crete': 'Greece',
  'Durban': 'South Africa',
  'Dune Court': 'South Africa',
  'Dune Trail': 'South Africa',
  'Foamline': 'Indonesia',
  'France': 'France',
  'Greece': 'Greece',
  'Harbor Cart': 'Portugal',
  'Indonesia': 'Indonesia',
  'Kona': 'United States',
  'Lagoon Chair': 'Aruba',
  'Lagoon Market': 'Aruba',
  'Lagos': 'Nigeria',
  'Lisbon': 'Portugal',
  'Marina Glow': 'France',
  'Maui': 'United States',
  'Miami': 'United States',
  'Morning Foam': 'Indonesia',
  'Nice': 'France',
  'Nigeria': 'Nigeria',
  'Outer Sand': 'Thailand',
  'Palm Cove': 'Philippines',
  'Palm Rail': 'United States',
  'Palm Walk': 'United States',
  'Phuket': 'Thailand',
  'Philippines': 'Philippines',
  'Pier Table': 'Portugal',
  'Pier Turn': 'China',
  'Portugal': 'Portugal',
  'Quiet Pier': 'Nigeria',
  'Reef Picnic': 'United States',
  'Reef Rail': 'Indonesia',
  'Sandbar Gate': 'United States',
  'Sanya': 'China',
  'Seaglass Cafe': 'Greece',
  'Shell Lane': 'United States',
  'Shore Skate': 'United States',
  'South Africa': 'South Africa',
  'Thailand': 'Thailand',
  'United States': 'United States',
  'Venice': 'United States',
};

String _fallbackCountryForPersona(ShorelinePersona persona) {
  final seed = persona.tideHandle.codeUnits.fold<int>(
    0,
    (total, unit) => total + unit,
  );
  return _fallbackCountries[seed % _fallbackCountries.length];
}

const List<String> _fallbackCountries = [
  'Australia',
  'United States',
  'Philippines',
  'Nigeria',
  'Indonesia',
  'Portugal',
  'Aruba',
  'China',
  'Thailand',
  'Greece',
  'France',
  'South Africa',
];
