import 'world_countries.dart';

class ProfileConstants {
  ProfileConstants._();

  // US States
  static const List<String> usStates = [
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming',
  ];

  // Country Codes for Phone Numbers
  // Note: Using comprehensive worldwide list from WorldCountries
  // Each entry has a unique 'id' to avoid duplicate values in dropdown
  // The 'code' is the actual phone country code, 'name' is the country name
  static List<Map<String, String>> get countryCodes =>
      WorldCountries.allCountries;

  // Professions (can be changed later as per user requirement)
  static const List<String> professions = [
    'Registered Nurse (RN)',
    'Licensed Practical Nurse (LPN)',
    'Certified Nursing Assistant (CNA)',
    'Nurse Practitioner (NP)',
    'Physician Assistant (PA)',
    'Medical Doctor (MD)',
    'Physical Therapist (PT)',
    'Occupational Therapist (OT)',
    'Respiratory Therapist (RT)',
    'Radiologic Technologist',
    'Medical Laboratory Technologist',
    'Pharmacy Technician',
    'Emergency Medical Technician (EMT)',
    'Paramedic',
    'Medical Assistant',
    'Surgical Technologist',
    'Sonographer',
    'Other',
  ];

  /// Managed specialties for filter + profile selection (canonical labels).
  static const List<String> specialties = [
    'Ambulatory',
    'Behavioral Health',
    'CCU',
    'Clinic',
    'Critical Care',
    'CVICU',
    'Doctor',
    'ED',
    'Emergency',
    'Emergency Department',
    'ER',
    'General Floors',
    'Hospice',
    'Hospital RN',
    'House Job',
    'ICU',
    'ICU/PCU',
    'Intensive Care Unit',
    'LTAC',
    'Med/Surg',
    'Med/Surg Telemetry',
    'MICU',
    'Neuro',
    'NICU',
    'Nursing',
    'Other',
    'PACU',
    'PCU',
    'Ped ER',
    'Peri-Op',
    'PICU',
    'Psych',
    'SICU',
    'Stepdown',
    'Surgical Telemetry',
    'Telemetry',
    'Transportation',
    'Trauma',
    'Trauma Surgical Stepdown',
    "Women's Health",
    'Wound Care',
  ];

  /// Maps historical free-text specialty spellings → canonical label.
  static const Map<String, String> specialtyAliases = {
    'ambulatory': 'Ambulatory',
    'behavioral': 'Behavioral Health',
    'behavioral health': 'Behavioral Health',
    'behavioral he': 'Behavioral Health',
    'ccu': 'CCU',
    'clinic': 'Clinic',
    'critical care': 'Critical Care',
    'cvicu': 'CVICU',
    'doctor': 'Doctor',
    'ed': 'ED',
    'er': 'ER',
    'emergency': 'Emergency',
    'emergency department': 'Emergency Department',
    'general floors': 'General Floors',
    'hospice': 'Hospice',
    'hospital rn': 'Hospital RN',
    'house job': 'House Job',
    'adult icu': 'ICU',
    'icu': 'ICU',
    'icu/pcu': 'ICU/PCU',
    'intensive care': 'Intensive Care Unit',
    'intensive care unit': 'Intensive Care Unit',
    'ltac': 'LTAC',
    'med surg': 'Med/Surg',
    'med surge': 'Med/Surg',
    'medsurg': 'Med/Surg',
    'med/surg': 'Med/Surg',
    'med-surg': 'Med/Surg',
    'medical surg': 'Med/Surg',
    'medical surge': 'Med/Surg',
    'medical surgical': 'Med/Surg',
    'medical-surgical': 'Med/Surg',
    'medical/ surgical': 'Med/Surg',
    'medical/surgical': 'Med/Surg',
    'med surg telemetry': 'Med/Surg Telemetry',
    'med/surg telemetry': 'Med/Surg Telemetry',
    'medsurg telemetry': 'Med/Surg Telemetry',
    'micu': 'MICU',
    'neuro': 'Neuro',
    'nicu': 'NICU',
    'nursing': 'Nursing',
    'pacu': 'PACU',
    'pcu': 'PCU',
    'ped er': 'Ped ER',
    'peri-op': 'Peri-Op',
    'peri op': 'Peri-Op',
    'picu': 'PICU',
    'psych': 'Psych',
    'sicu': 'SICU',
    'stepdown': 'Stepdown',
    'step down': 'Stepdown',
    'surgical telemetry': 'Surgical Telemetry',
    'surgical telem': 'Surgical Telemetry',
    'tele': 'Telemetry',
    'telemetry': 'Telemetry',
    'transportation': 'Transportation',
    'trauma': 'Trauma',
    'trauma surgical': 'Trauma',
    'trauma surgica': 'Trauma',
    'trauma surgical step down': 'Trauma Surgical Stepdown',
    'trauma surgical stepdown': 'Trauma Surgical Stepdown',
    "women's health": "Women's Health",
    'wound care': "Wound Care",
    // Common free-text combos seen in legacy data (treated as primary specialty)
    'intensive care ; telemetry': 'ICU',
    'intensive care; telemetry': 'ICU',
  };

  /// Splits stored specialty text on commas and semicolons.
  static List<String> splitSpecialtyTokens(String? raw) {
    if (raw == null) return const [];
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'n/a') {
      return const [];
    }
    return trimmed
        .split(RegExp(r'[,;]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.toLowerCase() != 'n/a')
        .toList();
  }

  static String _normalizedKey(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s*/\s*'), '/')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Resolves a raw specialty token to its canonical label when possible.
  static String canonicalizeSpecialty(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    if (specialties.contains(trimmed)) return trimmed;

    final key = _normalizedKey(trimmed);
    final alias = specialtyAliases[key];
    if (alias != null) return alias;

    // Also try slash-normalized forms without spaces: "med / surg" → "med/surg"
    final slashKey = key.replaceAll(' ', '');
    for (final entry in specialtyAliases.entries) {
      if (entry.key.replaceAll(' ', '') == slashKey) return entry.value;
    }

    // Case-insensitive match against canonical list
    for (final s in specialties) {
      if (_normalizedKey(s) == key) return s;
      if (s.replaceAll(RegExp(r'[\s/_-]+'), '').toLowerCase() == slashKey) {
        return s;
      }
    }

    // Prefix / contains match for truncated legacy values (e.g. "medical surgic")
    for (final entry in specialtyAliases.entries) {
      if (key.startsWith(entry.key) || entry.key.startsWith(key)) {
        if (key.length >= 6 || entry.key.length >= 6) {
          return entry.value;
        }
      }
    }

    return trimmed;
  }

  /// Canonicalize + dedupe specialty tokens for display.
  static String formatSpecialtiesCanonical(String? raw) {
    final tokens = splitSpecialtyTokens(raw);
    if (tokens.isEmpty) return 'N/A';

    final seen = <String>{};
    final canonical = <String>[];
    for (final token in tokens) {
      final label = canonicalizeSpecialty(token);
      if (label.isEmpty) continue;
      if (seen.add(label)) canonical.add(label);
    }
    if (canonical.isEmpty) return 'N/A';
    if (canonical.length <= 2) return canonical.join(', ');
    return '${canonical.take(2).join(', ')}...';
  }

  /// Full canonical list (no truncation) for profile details.
  static String formatSpecialtiesCanonicalFull(String? raw) {
    final tokens = splitSpecialtyTokens(raw);
    if (tokens.isEmpty) return 'N/A';

    final seen = <String>{};
    final canonical = <String>[];
    for (final token in tokens) {
      final label = canonicalizeSpecialty(token);
      if (label.isEmpty) continue;
      if (seen.add(label)) canonical.add(label);
    }
    return canonical.isEmpty ? 'N/A' : canonical.join(', ');
  }

  /// True if stored specialty text matches the selected canonical filter.
  static bool specialtyMatchesFilter(String? storedSpecialties, String filter) {
    final tokens = splitSpecialtyTokens(storedSpecialties);
    if (tokens.isEmpty) return false;
    final canonicalFilter = canonicalizeSpecialty(filter);
    for (final token in tokens) {
      final canonical = canonicalizeSpecialty(token);
      if (canonical == canonicalFilter) return true;
      if (token.toLowerCase().contains(canonicalFilter.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}
