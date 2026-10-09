import 'package:flutter/material.dart';
import 'package:ats/core/constants/profile_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/widgets/profile/profile.dart';

/// Manages all form controllers and state for admin candidate profile creation/editing
class AdminProfileFormState {
  // Candidate Profile Controllers
  late final TextEditingController firstNameController;
  late final TextEditingController middleNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController address1Controller;
  late final TextEditingController address2Controller;
  late final TextEditingController cityController;
  late final TextEditingController stateController;
  late final TextEditingController zipController;
  late final TextEditingController ssnController;

  // Phones
  final List<PhoneEntry> phoneEntries = [];

  // Specialty
  String? selectedProfession;
  final List<String> selectedSpecialties = [];

  // Background History
  String? liabilityAction;
  String? licenseAction;
  String? previouslyTraveled;
  String? terminatedFromAssignment;

  // Licensure
  String? licensureState;
  final TextEditingController npiController = TextEditingController();

  // Education
  final List<EducationEntry> educationEntries = [];

  // Certifications
  final List<CertificationEntry> certificationEntries = [];

  // Work History
  final List<WorkHistoryEntry> workHistoryEntries = [];

  AdminProfileFormState() {
    _initializeControllers();
  }

  void _initializeControllers() {
    firstNameController = TextEditingController();
    middleNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    address1Controller = TextEditingController();
    address2Controller = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
    zipController = TextEditingController();
    ssnController = TextEditingController();
  }

  void loadFromProfile(dynamic profile) {
    if (profile == null) return;

    // Candidate Profile
    firstNameController.text = profile.firstName?.toString() ?? '';
    middleNameController.text = profile.middleName?.toString() ?? '';
    lastNameController.text = profile.lastName?.toString() ?? '';
    emailController.text = profile.email?.toString() ?? '';
    address1Controller.text = profile.address1?.toString() ?? '';
    address2Controller.text = profile.address2?.toString() ?? '';
    cityController.text = profile.city?.toString() ?? '';
    stateController.text = profile.state?.toString() ?? '';
    zipController.text = profile.zip?.toString() ?? '';
    ssnController.text = profile.ssn?.toString() ?? '';

    // Phones
    for (var phone in phoneEntries) {
      phone.countryCodeController.dispose();
      phone.numberController.dispose();
    }
    phoneEntries.clear();
    final phones = _asMapList(profile.phones);
    for (final phone in phones) {
      phoneEntries.add(
        PhoneEntry(
          countryCodeController: TextEditingController(
            text: phone['countryCode']?.toString().isNotEmpty == true
                ? phone['countryCode'].toString()
                : '+1',
          ),
          numberController: TextEditingController(
            text: phone['number']?.toString() ?? '',
          ),
        ),
      );
    }

    // Specialty — Firestore may store specialties as String OR List
    selectedProfession = _matchProfession(profile.profession?.toString());
    selectedSpecialties.clear();
    try {
      final dynamic specialtiesRaw = (profile as dynamic).specialties;
      for (final item in _parseSpecialtiesList(specialtiesRaw)) {
        selectedSpecialties.add(item);
      }
    } catch (_) {
      // Keep empty rather than crashing edit/update flow
    }

    // Background History
    liabilityAction = _normalizeYesNo(profile.liabilityAction?.toString());
    licenseAction = _normalizeYesNo(profile.licenseAction?.toString());
    previouslyTraveled = _normalizeYesNo(
      profile.previouslyTraveled?.toString(),
    );
    terminatedFromAssignment = _normalizeYesNo(
      profile.terminatedFromAssignment?.toString(),
    );

    // Licensure
    licensureState = _matchUsState(profile.licensureState?.toString());
    npiController.text = profile.npi?.toString() ?? '';

    // Education
    for (var edu in educationEntries) {
      edu.institutionController.dispose();
      edu.degreeController.dispose();
      edu.fromDateController.dispose();
      edu.toDateController.dispose();
    }
    educationEntries.clear();
    for (final edu in _asMapList(profile.education)) {
      educationEntries.add(
        EducationEntry(
          institutionController: TextEditingController(
            text:
                edu['institutionName']?.toString() ??
                edu['institution']?.toString() ??
                '',
          ),
          degreeController: TextEditingController(
            text: edu['degree']?.toString() ?? '',
          ),
          fromDateController: TextEditingController(
            text: edu['fromDate']?.toString() ?? '',
          ),
          toDateController: TextEditingController(
            text: edu['toDate']?.toString() ?? '',
          ),
          isOngoing: edu['isOngoing'] == true,
        ),
      );
    }

    // Certifications
    for (var cert in certificationEntries) {
      cert.nameController.dispose();
      cert.expiryController.dispose();
    }
    certificationEntries.clear();
    for (final cert in _asMapList(profile.certifications)) {
      certificationEntries.add(
        CertificationEntry(
          nameController: TextEditingController(
            text: cert['name']?.toString() ?? '',
          ),
          expiryController: TextEditingController(
            text: cert['expiry']?.toString() ?? '',
          ),
          hasNoExpiry: cert['hasNoExpiry'] == true,
        ),
      );
    }

    // Work History
    for (var work in workHistoryEntries) {
      work.companyController.dispose();
      work.positionController.dispose();
      work.descriptionController.dispose();
      work.fromDateController.dispose();
      work.toDateController.dispose();
    }
    workHistoryEntries.clear();
    for (final work in _asMapList(profile.workHistory)) {
      workHistoryEntries.add(
        WorkHistoryEntry(
          companyController: TextEditingController(
            text: work['company']?.toString() ?? '',
          ),
          positionController: TextEditingController(
            text: work['position']?.toString() ?? '',
          ),
          descriptionController: TextEditingController(
            text: work['description']?.toString() ?? '',
          ),
          fromDateController: TextEditingController(
            text: work['fromDate']?.toString() ?? '',
          ),
          toDateController: TextEditingController(
            text: work['toDate']?.toString() ?? '',
          ),
          isOngoing: work['isOngoing'] == true,
        ),
      );
    }
  }

  static List<Map<String, dynamic>> _asMapList(dynamic raw) {
    if (raw == null) return const [];
    if (raw is! List) return const [];
    final result = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map) {
        result.add(
          Map<String, dynamic>.from(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        );
      }
    }
    return result;
  }

  static List<String> _parseSpecialtiesList(dynamic raw) {
    if (raw == null) return const [];

    // Normalize List or String into the same comma-separated text first
    String text;
    if (raw is List) {
      final parts = <String>[];
      for (final item in raw) {
        final value = item?.toString().trim() ?? '';
        if (value.isNotEmpty) parts.add(value);
      }
      text = parts.join(', ');
    } else {
      text = raw.toString();
    }

    final seen = <String>{};
    final result = <String>[];
    for (final token in ProfileConstants.splitSpecialtyTokens(text)) {
      final label = ProfileConstants.canonicalizeSpecialty(token);
      if (label.isEmpty) continue;
      if (seen.add(label)) result.add(label);
    }
    return result;
  }

  void addPhone() {
    if (phoneEntries.length < 2) {
      phoneEntries.add(
        PhoneEntry(
          countryCodeController: TextEditingController(text: '+1'),
          numberController: TextEditingController(),
        ),
      );
    }
  }

  void removePhone(int index) {
    phoneEntries[index].countryCodeController.dispose();
    phoneEntries[index].numberController.dispose();
    phoneEntries.removeAt(index);
  }

  void addEducation() {
    educationEntries.add(
      EducationEntry(
        institutionController: TextEditingController(),
        degreeController: TextEditingController(),
        fromDateController: TextEditingController(),
        toDateController: TextEditingController(),
      ),
    );
  }

  void removeEducation(int index) {
    educationEntries[index].institutionController.dispose();
    educationEntries[index].degreeController.dispose();
    educationEntries[index].fromDateController.dispose();
    educationEntries[index].toDateController.dispose();
    educationEntries.removeAt(index);
  }

  void addCertification() {
    certificationEntries.add(
      CertificationEntry(
        nameController: TextEditingController(),
        expiryController: TextEditingController(),
      ),
    );
  }

  void removeCertification(int index) {
    certificationEntries[index].nameController.dispose();
    certificationEntries[index].expiryController.dispose();
    certificationEntries.removeAt(index);
  }

  void addWorkHistoryEntry() {
    workHistoryEntries.add(
      WorkHistoryEntry(
        companyController: TextEditingController(),
        positionController: TextEditingController(),
        descriptionController: TextEditingController(),
        fromDateController: TextEditingController(),
        toDateController: TextEditingController(),
      ),
    );
  }

  void removeWorkHistoryEntry(int index) {
    workHistoryEntries[index].companyController.dispose();
    workHistoryEntries[index].positionController.dispose();
    workHistoryEntries[index].descriptionController.dispose();
    workHistoryEntries[index].fromDateController.dispose();
    workHistoryEntries[index].toDateController.dispose();
    workHistoryEntries.removeAt(index);
  }

  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    ssnController.dispose();

    for (var phone in phoneEntries) {
      phone.countryCodeController.dispose();
      phone.numberController.dispose();
    }

    npiController.dispose();

    for (var edu in educationEntries) {
      edu.institutionController.dispose();
      edu.degreeController.dispose();
      edu.fromDateController.dispose();
      edu.toDateController.dispose();
    }

    for (var cert in certificationEntries) {
      cert.nameController.dispose();
      cert.expiryController.dispose();
    }

    for (var work in workHistoryEntries) {
      work.companyController.dispose();
      work.positionController.dispose();
      work.descriptionController.dispose();
      work.fromDateController.dispose();
      work.toDateController.dispose();
    }
  }

  static String? _normalizeYesNo(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final lower = trimmed.toLowerCase();
    if (lower == 'yes' || lower == 'y' || lower == 'true') return AppTexts.yes;
    if (lower == 'no' || lower == 'n' || lower == 'false') return AppTexts.no;
    if (trimmed == AppTexts.yes || trimmed == AppTexts.no) return trimmed;
    return trimmed;
  }

  static String? _matchProfession(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    for (final profession in ProfileConstants.professions) {
      if (profession.toLowerCase() == trimmed.toLowerCase()) return profession;
    }
    return trimmed;
  }

  static String? _matchUsState(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    for (final state in ProfileConstants.usStates) {
      if (state.toLowerCase() == trimmed.toLowerCase()) return state;
    }
    return trimmed;
  }
}
