import 'package:flutter/cupertino.dart';

Future<String?> showCoastinCountryPicker({
  required BuildContext context,
  required String selectedCountry,
}) {
  return showCupertinoModalPopup<String>(
    context: context,
    builder: (context) {
      return _CountryPickerSheet(selectedCountry: selectedCountry);
    },
  );
}

Future<String?> showCoastinBirthDatePicker({
  required BuildContext context,
  required String selectedBirthLine,
}) {
  return showCupertinoModalPopup<String>(
    context: context,
    builder: (context) {
      return _BirthDatePickerSheet(selectedBirthLine: selectedBirthLine);
    },
  );
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({required this.selectedCountry});

  final String selectedCountry;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late final FixedExtentScrollController _countryController;
  late String _draftCountry;

  @override
  void initState() {
    super.initState();
    final initialIndex = _coastinCountryNames.indexOf(widget.selectedCountry);
    final selectedIndex = initialIndex < 0 ? 0 : initialIndex;
    _draftCountry = _coastinCountryNames[selectedIndex];
    _countryController = FixedExtentScrollController(
      initialItem: selectedIndex,
    );
  }

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PickerShell(
      title: 'Select country',
      onClear: () => Navigator.of(context).pop(''),
      onDone: () => Navigator.of(context).pop(_draftCountry),
      child: CupertinoPicker.builder(
        scrollController: _countryController,
        itemExtent: 42,
        useMagnifier: true,
        magnification: 1.08,
        onSelectedItemChanged: (index) {
          _draftCountry = _coastinCountryNames[index];
        },
        childCount: _coastinCountryNames.length,
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              _coastinCountryNames[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF087E7C),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BirthDatePickerSheet extends StatefulWidget {
  const _BirthDatePickerSheet({required this.selectedBirthLine});

  final String selectedBirthLine;

  @override
  State<_BirthDatePickerSheet> createState() => _BirthDatePickerSheetState();
}

class _BirthDatePickerSheetState extends State<_BirthDatePickerSheet> {
  late DateTime _draftBirthDate;

  @override
  void initState() {
    super.initState();
    _draftBirthDate = _clampBirthDate(
      _parseBirthDate(widget.selectedBirthLine),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return _PickerShell(
      title: 'Date of Birth',
      onClear: () => Navigator.of(context).pop(''),
      onDone: () =>
          Navigator.of(context).pop(_formatBirthDate(_draftBirthDate)),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: _draftBirthDate,
        minimumDate: DateTime(1900),
        maximumDate: DateTime(today.year, today.month, today.day),
        onDateTimeChanged: (value) {
          _draftBirthDate = value;
        },
      ),
    );
  }
}

class _PickerShell extends StatelessWidget {
  const _PickerShell({
    required this.title,
    required this.child,
    required this.onClear,
    required this.onDone,
  });

  final String title;
  final Widget child;
  final VoidCallback onClear;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 370,
        decoration: const BoxDecoration(
          color: Color(0xFFF7FFFD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF7D8E8E),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    onPressed: onDone,
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: const Color(0xFFE0ECEA)),
            CupertinoButton(
              minSize: 42,
              padding: EdgeInsets.zero,
              onPressed: onClear,
              child: const Text(
                'Do not show',
                style: TextStyle(
                  color: Color(0xFF0A8F89),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

DateTime _parseBirthDate(String birthLine) {
  final parts = birthLine
      .split(RegExp(r'\s+'))
      .where((part) => part.trim().isNotEmpty)
      .toList();
  if (parts.length != 3) {
    return DateTime(2000);
  }
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    return DateTime(2000);
  }
  if (month < 1 || month > 12 || day < 1 || day > 31) {
    return DateTime(2000);
  }
  return DateTime(year, month, day);
}

DateTime _clampBirthDate(DateTime value) {
  final today = DateTime.now();
  final earliest = DateTime(1900);
  final latest = DateTime(today.year, today.month, today.day);
  if (value.isBefore(earliest) || value.isAfter(latest)) {
    return DateTime(2000);
  }
  return value;
}

String _formatBirthDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year  $month  $day';
}

const List<String> _coastinCountryNames = [
  'Afghanistan',
  'Albania',
  'Algeria',
  'Andorra',
  'Angola',
  'Antigua and Barbuda',
  'Argentina',
  'Armenia',
  'Australia',
  'Austria',
  'Azerbaijan',
  'Bahamas',
  'Bahrain',
  'Bangladesh',
  'Barbados',
  'Belarus',
  'Belgium',
  'Belize',
  'Benin',
  'Bhutan',
  'Bolivia',
  'Bosnia and Herzegovina',
  'Botswana',
  'Brazil',
  'Brunei',
  'Bulgaria',
  'Burkina Faso',
  'Burundi',
  'Cabo Verde',
  'Cambodia',
  'Cameroon',
  'Canada',
  'Central African Republic',
  'Chad',
  'Chile',
  'China',
  'Colombia',
  'Comoros',
  'Congo',
  'Costa Rica',
  "Cote d'Ivoire",
  'Croatia',
  'Cuba',
  'Cyprus',
  'Czechia',
  'Democratic Republic of the Congo',
  'Denmark',
  'Djibouti',
  'Dominica',
  'Dominican Republic',
  'Ecuador',
  'Egypt',
  'El Salvador',
  'Equatorial Guinea',
  'Eritrea',
  'Estonia',
  'Eswatini',
  'Ethiopia',
  'Fiji',
  'Finland',
  'France',
  'Gabon',
  'Gambia',
  'Georgia',
  'Germany',
  'Ghana',
  'Greece',
  'Grenada',
  'Guatemala',
  'Guinea',
  'Guinea-Bissau',
  'Guyana',
  'Haiti',
  'Honduras',
  'Hungary',
  'Iceland',
  'India',
  'Indonesia',
  'Iran',
  'Iraq',
  'Ireland',
  'Israel',
  'Italy',
  'Jamaica',
  'Japan',
  'Jordan',
  'Kazakhstan',
  'Kenya',
  'Kiribati',
  'Kosovo',
  'Kuwait',
  'Kyrgyzstan',
  'Laos',
  'Latvia',
  'Lebanon',
  'Lesotho',
  'Liberia',
  'Libya',
  'Liechtenstein',
  'Lithuania',
  'Luxembourg',
  'Madagascar',
  'Malawi',
  'Malaysia',
  'Maldives',
  'Mali',
  'Malta',
  'Marshall Islands',
  'Mauritania',
  'Mauritius',
  'Mexico',
  'Micronesia',
  'Moldova',
  'Monaco',
  'Mongolia',
  'Montenegro',
  'Morocco',
  'Mozambique',
  'Myanmar',
  'Namibia',
  'Nauru',
  'Nepal',
  'Netherlands',
  'New Zealand',
  'Nicaragua',
  'Niger',
  'Nigeria',
  'North Korea',
  'North Macedonia',
  'Norway',
  'Oman',
  'Pakistan',
  'Palau',
  'Palestine',
  'Panama',
  'Papua New Guinea',
  'Paraguay',
  'Peru',
  'Philippines',
  'Poland',
  'Portugal',
  'Qatar',
  'Romania',
  'Russia',
  'Rwanda',
  'Saint Kitts and Nevis',
  'Saint Lucia',
  'Saint Vincent and the Grenadines',
  'Samoa',
  'San Marino',
  'Sao Tome and Principe',
  'Saudi Arabia',
  'Senegal',
  'Serbia',
  'Seychelles',
  'Sierra Leone',
  'Singapore',
  'Slovakia',
  'Slovenia',
  'Solomon Islands',
  'Somalia',
  'South Africa',
  'South Korea',
  'South Sudan',
  'Spain',
  'Sri Lanka',
  'Sudan',
  'Suriname',
  'Sweden',
  'Switzerland',
  'Syria',
  'Taiwan',
  'Tajikistan',
  'Tanzania',
  'Thailand',
  'Timor-Leste',
  'Togo',
  'Tonga',
  'Trinidad and Tobago',
  'Tunisia',
  'Turkey',
  'Turkmenistan',
  'Tuvalu',
  'Uganda',
  'Ukraine',
  'United Arab Emirates',
  'United Kingdom',
  'United States',
  'Uruguay',
  'Uzbekistan',
  'Vanuatu',
  'Vatican City',
  'Venezuela',
  'Vietnam',
  'Yemen',
  'Zambia',
  'Zimbabwe',
];
