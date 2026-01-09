import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';

class AppCandidateProfileFormatters {
  AppCandidateProfileFormatters._();

  /// Formats phones list to display text
  static String formatPhones(CandidateProfileEntity? profile) {
    if (profile == null ||
        profile.phones == null ||
        profile.phones!.isEmpty) {
      return '';
    }
    return profile.phones!
        .map((phone) {
          final countryCode = phone['countryCode']?.toString() ?? '';
          final number = phone['number']?.toString() ?? '';
          if (number.isEmpty) return null;
          return countryCode.isNotEmpty
              ? '$countryCode $number'
              : number;
        })
        .where((phone) => phone != null)
        .join('\n');
  }

  /// Formats work history to display text
  static String formatWorkHistory(CandidateProfileEntity? profile) {
    if (profile == null ||
        profile.workHistory == null ||
        profile.workHistory!.isEmpty) {
      return 'No work history';
    }
    return profile.workHistory!
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final work = entry.value;
          final company = work['company']?.toString() ?? 'N/A';
          final position = work['position']?.toString() ?? 'N/A';
          final fromDate = work['fromDate']?.toString() ?? '';
          final toDate = work['toDate']?.toString() ?? '';
          final isOngoing = work['isOngoing'] == true;
          final description = work['description']?.toString() ?? '';

          final dateRange = isOngoing
              ? '$fromDate - ${AppTexts.ongoing}'
              : (fromDate.isNotEmpty && toDate.isNotEmpty
                  ? '$fromDate - $toDate'
                  : fromDate.isNotEmpty
                      ? fromDate
                      : '');

          final parts = <String>[
            '${index + 1}. $company - $position',
            if (dateRange.isNotEmpty) dateRange,
            if (description.isNotEmpty) description,
          ];

          return parts.join('\n');
        })
        .join('\n\n');
  }

  /// Formats education list to display text
  static String formatEducation(CandidateProfileEntity? profile) {
    if (profile == null ||
        profile.education == null ||
        profile.education!.isEmpty) {
      return '';
    }
    return profile.education!
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final edu = entry.value;
          final institution = edu['institutionName']?.toString() ?? 'N/A';
          final degree = edu['degree']?.toString() ?? 'N/A';
          final fromDate = edu['fromDate']?.toString() ?? '';
          final toDate = edu['toDate']?.toString() ?? '';
          final isOngoing = edu['isOngoing'] == true;

          final dateRange = isOngoing
              ? '$fromDate - ${AppTexts.ongoing}'
              : (fromDate.isNotEmpty && toDate.isNotEmpty
                  ? '$fromDate - $toDate'
                  : fromDate.isNotEmpty
                      ? fromDate
                      : '');

          final parts = <String>[
            '${index + 1}. $institution',
            if (degree.isNotEmpty && degree != 'N/A') degree,
            if (dateRange.isNotEmpty) dateRange,
          ];

          return parts.join('\n');
        })
        .join('\n\n');
  }

  /// Formats certifications list to display text
  static String formatCertifications(CandidateProfileEntity? profile) {
    if (profile == null ||
        profile.certifications == null ||
        profile.certifications!.isEmpty) {
      return '';
    }
    return profile.certifications!
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final cert = entry.value;
          final name = cert['name']?.toString() ?? 'N/A';
          final expiry = cert['expiry']?.toString();
          final hasNoExpiry = cert['hasNoExpiry'] == true;

          final parts = <String>[
            '${index + 1}. $name',
            if (hasNoExpiry)
              AppTexts.ongoing
            else if (expiry != null && expiry.isNotEmpty)
              '${AppTexts.expiry}: $expiry',
          ];

          return parts.join('\n');
        })
        .join('\n\n');
  }

  /// Gets full name from profile
  static String getFullName(CandidateProfileEntity? profile) {
    if (profile == null) return 'N/A';
    final parts = <String>[
      profile.firstName,
      if (profile.middleName != null && profile.middleName!.isNotEmpty)
        profile.middleName!,
      profile.lastName,
    ];
    return parts.join(' ').trim();
  }

  /// Gets full address from profile
  static String getFullAddress(CandidateProfileEntity? profile) {
    if (profile == null) return '';
    final parts = <String>[];
    if (profile.address1 != null && profile.address1!.isNotEmpty) {
      parts.add(profile.address1!);
    }
    if (profile.address2 != null && profile.address2!.isNotEmpty) {
      parts.add(profile.address2!);
    }
    final cityStateZip = <String>[];
    if (profile.city != null && profile.city!.isNotEmpty) {
      cityStateZip.add(profile.city!);
    }
    if (profile.state != null && profile.state!.isNotEmpty) {
      cityStateZip.add(profile.state!);
    }
    if (profile.zip != null && profile.zip!.isNotEmpty) {
      cityStateZip.add(profile.zip!);
    }
    if (cityStateZip.isNotEmpty) {
      parts.add(cityStateZip.join(', '));
    }
    return parts.join('\n');
  }
}
