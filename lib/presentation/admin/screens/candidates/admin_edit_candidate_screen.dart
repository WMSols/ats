import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_validators/app_validators.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminEditCandidateScreen extends StatelessWidget {
  const AdminEditCandidateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCandidatesController>();

    return AppAdminLayout(
      title: '${AppTexts.edit} ${AppTexts.candidate}',
      child: Obx(() {
        final candidate = controller.selectedCandidate.value;
        final profile = controller.selectedCandidateProfile.value;
        final isLoading = controller.isLoading.value;

        if (candidate == null) {
          return AppEmptyState(
            message: AppTexts.candidateNotFound,
            icon: Iconsax.profile_circle,
          );
        }

        if (profile == null) {
          return const AppLoadingIndicator();
        }

        // Key by profileId so form State is created only after profile exists
        // and loadFromProfile runs in initState before the first paint.
        return AppLoadingOverlay(
          isLoading: isLoading,
          child: _AdminEditCandidateForm(
            key: ValueKey('admin-edit-form-${profile.profileId}'),
            candidate: candidate,
            profile: profile,
            controller: controller,
          ),
        );
      }),
    );
  }
}

class _AdminEditCandidateForm extends StatefulWidget {
  final UserEntity candidate;
  final CandidateProfileEntity profile;
  final AdminCandidatesController controller;

  const _AdminEditCandidateForm({
    super.key,
    required this.candidate,
    required this.profile,
    required this.controller,
  });

  @override
  State<_AdminEditCandidateForm> createState() =>
      _AdminEditCandidateFormState();
}

class _AdminEditCandidateFormState extends State<_AdminEditCandidateForm> {
  late final AdminProfileFormState formState;
  final passwordController = TextEditingController(text: '••••••••');
  final passwordError = Rxn<String>();

  final firstNameError = Rxn<String>();
  final lastNameError = Rxn<String>();
  final address1Error = Rxn<String>();
  final cityError = Rxn<String>();
  final stateError = Rxn<String>();
  final zipError = Rxn<String>();
  final professionError = Rxn<String>();
  final specialtiesError = Rxn<String>();
  final licensureStateError = Rxn<String>();
  final phonesError = Rxn<String>();
  final educationError = Rxn<String>();
  final workHistoryError = Rxn<String>();
  final phoneErrors = <int, Rxn<String>>{}.obs;

  Worker? _profileWorker;
  String? _loadedProfileId;

  @override
  void initState() {
    super.initState();
    formState = AdminProfileFormState();
    _applyProfile(widget.profile);

    // Keep form in sync if the stream emits while list/dropdown state is incomplete
    _profileWorker = ever(widget.controller.selectedCandidateProfile, (
      profile,
    ) {
      if (profile == null || !mounted) return;
      if (profile.profileId != widget.profile.profileId) return;
      _applyProfile(profile);
    });
  }

  @override
  void didUpdateWidget(covariant _AdminEditCandidateForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.profileId != widget.profile.profileId) {
      _applyProfile(widget.profile, force: true);
    }
  }

  void _applyProfile(CandidateProfileEntity profile, {bool force = false}) {
    if (!force &&
        _loadedProfileId == profile.profileId &&
        !_formLooksIncomplete(profile)) {
      return;
    }
    try {
      formState.loadFromProfile(profile);
      _loadedProfileId = profile.profileId;
      if (mounted) setState(() {});
    } catch (_) {
      // Profile field type mismatches (e.g. specialties List vs String on web)
      // must not take down the edit screen after an update.
      _loadedProfileId = profile.profileId;
    }
  }

  bool _formLooksIncomplete(CandidateProfileEntity profile) {
    final hasPhones = profile.phones != null && profile.phones!.isNotEmpty;
    if (hasPhones && formState.phoneEntries.isEmpty) return true;

    final hasProfession =
        profile.profession != null && profile.profession!.trim().isNotEmpty;
    if (hasProfession &&
        (formState.selectedProfession == null ||
            formState.selectedProfession!.isEmpty)) {
      return true;
    }

    final hasSpecialties = () {
      final raw = profile.specialties;
      if (raw == null) return false;
      return raw.toString().trim().isNotEmpty;
    }();
    if (hasSpecialties && formState.selectedSpecialties.isEmpty) return true;

    final hasEducation =
        profile.education != null && profile.education!.isNotEmpty;
    if (hasEducation && formState.educationEntries.isEmpty) return true;

    final hasCerts =
        profile.certifications != null && profile.certifications!.isNotEmpty;
    if (hasCerts && formState.certificationEntries.isEmpty) return true;

    final hasWork =
        profile.workHistory != null && profile.workHistory!.isNotEmpty;
    if (hasWork && formState.workHistoryEntries.isEmpty) return true;

    final hasBg =
        (profile.liabilityAction != null &&
            profile.liabilityAction!.trim().isNotEmpty) ||
        (profile.licenseAction != null &&
            profile.licenseAction!.trim().isNotEmpty);
    if (hasBg && formState.liabilityAction == null) return true;

    final hasLicensure =
        profile.licensureState != null &&
        profile.licensureState!.trim().isNotEmpty;
    if (hasLicensure &&
        (formState.licensureState == null ||
            formState.licensureState!.isEmpty)) {
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    _profileWorker?.dispose();
    formState.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final profileData = AdminProfileFormDataHelper.getProfileData(formState);

    widget.controller.updateCandidateProfile(
      firstName: formState.firstNameController.text.trim(),
      lastName: formState.lastNameController.text.trim(),
      middleName: profileData['middleName'] as String?,
      email: formState.emailController.text.trim().isEmpty
          ? null
          : formState.emailController.text.trim(),
      address1: profileData['address1'] as String?,
      address2: profileData['address2'] as String?,
      city: profileData['city'] as String?,
      state: profileData['state'] as String?,
      zip: profileData['zip'] as String?,
      ssn: profileData['ssn'] as String?,
      phones: profileData['phones'] as List<Map<String, dynamic>>?,
      profession: profileData['profession'] as String?,
      specialties: profileData['specialties'] as String?,
      liabilityAction: profileData['liabilityAction'] as String?,
      licenseAction: profileData['licenseAction'] as String?,
      previouslyTraveled: profileData['previouslyTraveled'] as String?,
      terminatedFromAssignment:
          profileData['terminatedFromAssignment'] as String?,
      licensureState: profileData['licensureState'] as String?,
      npi: profileData['npi'] as String?,
      education: profileData['education'] as List<Map<String, dynamic>>?,
      certifications:
          profileData['certifications'] as List<Map<String, dynamic>>?,
      workHistory: profileData['workHistory'] as List<Map<String, dynamic>>?,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CandidateProfileSection(
            firstNameController: formState.firstNameController,
            middleNameController: formState.middleNameController,
            lastNameController: formState.lastNameController,
            emailController: formState.emailController,
            passwordController: passwordController,
            emailEnabled: false,
            passwordEnabled: false,
            showEmailField: true,
            showPasswordField: true,
            address1Controller: formState.address1Controller,
            address2Controller: formState.address2Controller,
            cityController: formState.cityController,
            stateController: formState.stateController,
            zipController: formState.zipController,
            ssnController: formState.ssnController,
            firstNameError: firstNameError,
            lastNameError: lastNameError,
            emailError: Rxn<String>(),
            passwordError: passwordError,
            address1Error: address1Error,
            cityError: cityError,
            stateError: stateError,
            zipError: zipError,
            onFirstNameChanged: (_) => null,
            onLastNameChanged: (_) => null,
            onEmailChanged: (_) => null,
            onPasswordChanged: (value) {
              passwordError.value = AppValidators.validatePassword(value);
              return null;
            },
            onAddress1Changed: (_) => null,
            onCityChanged: (_) => null,
            onStateChanged: (_) => null,
            onZipChanged: (_) => null,
            hasError: false,
          ),
          AppSpacing.vertical(context, 0.02),
          PhonesSection(
            phoneEntries: formState.phoneEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final phone = entry.value;
              return PhoneEntry(
                countryCodeController: phone.countryCodeController,
                numberController: phone.numberController,
                numberError: phoneErrors[index] ?? Rxn<String>(null),
              );
            }).toList(),
            onCountryCodeChanged: (index, countryCode) {},
            onNumberChanged: (index, number) {},
            onAddPhone: () {
              setState(() => formState.addPhone());
            },
            onRemovePhone: (index) {
              setState(() => formState.removePhone(index));
            },
            hasError:
                phonesError.value != null ||
                phoneErrors.values.any((e) => e.value != null),
          ),
          AppSpacing.vertical(context, 0.02),
          SpecialtySection(
            selectedProfession: formState.selectedProfession,
            selectedSpecialties: List<String>.from(
              formState.selectedSpecialties,
            ),
            professionError: professionError,
            specialtiesError: specialtiesError,
            onProfessionChanged: (value) {
              setState(() => formState.selectedProfession = value);
            },
            onSpecialtiesChanged: (specialties) {
              setState(() {
                formState.selectedSpecialties.clear();
                formState.selectedSpecialties.addAll(specialties);
              });
            },
            hasError:
                professionError.value != null || specialtiesError.value != null,
          ),
          AppSpacing.vertical(context, 0.02),
          BackgroundHistorySection(
            liabilityAction: formState.liabilityAction,
            licenseAction: formState.licenseAction,
            previouslyTraveled: formState.previouslyTraveled,
            terminatedFromAssignment: formState.terminatedFromAssignment,
            onLiabilityActionChanged: (value) {
              setState(() => formState.liabilityAction = value);
            },
            onLicenseActionChanged: (value) {
              setState(() => formState.licenseAction = value);
            },
            onPreviouslyTraveledChanged: (value) {
              setState(() => formState.previouslyTraveled = value);
            },
            onTerminatedFromAssignmentChanged: (value) {
              setState(() => formState.terminatedFromAssignment = value);
            },
          ),
          AppSpacing.vertical(context, 0.02),
          LicensureSection(
            selectedState: formState.licensureState,
            npiController: formState.npiController,
            onStateChanged: (value) {
              setState(() => formState.licensureState = value);
            },
            stateError: licensureStateError,
            hasError: licensureStateError.value != null,
          ),
          AppSpacing.vertical(context, 0.02),
          EducationSection(
            educationEntries: formState.educationEntries,
            onOngoingChanged: (index, isOngoing) {
              setState(() {
                formState.educationEntries[index] = EducationEntry(
                  institutionController:
                      formState.educationEntries[index].institutionController,
                  degreeController:
                      formState.educationEntries[index].degreeController,
                  fromDateController:
                      formState.educationEntries[index].fromDateController,
                  toDateController:
                      formState.educationEntries[index].toDateController,
                  isOngoing: isOngoing,
                );
              });
            },
            onInstitutionChanged: (index, institution) {},
            onDegreeChanged: (index, degree) {},
            onFromDateChanged: (index, fromDate) {},
            onToDateChanged: (index, toDate) {},
            onAddEducation: () {
              setState(() => formState.addEducation());
            },
            onRemoveEducation: (index) {
              setState(() => formState.removeEducation(index));
            },
            generalError: educationError,
            hasError: educationError.value != null,
          ),
          AppSpacing.vertical(context, 0.02),
          CertificationsSection(
            certificationEntries: formState.certificationEntries,
            onNoExpiryChanged: (index, hasNoExpiry) {
              setState(() {
                formState.certificationEntries[index] = CertificationEntry(
                  nameController:
                      formState.certificationEntries[index].nameController,
                  expiryController:
                      formState.certificationEntries[index].expiryController,
                  hasNoExpiry: hasNoExpiry,
                );
              });
            },
            onAddCertification: () {
              setState(() => formState.addCertification());
            },
            onRemoveCertification: (index) {
              setState(() => formState.removeCertification(index));
            },
          ),
          AppSpacing.vertical(context, 0.02),
          WorkHistorySectionWidget(
            workHistoryEntries: formState.workHistoryEntries,
            onOngoingChanged: (index, isOngoing) {
              setState(() {
                formState.workHistoryEntries[index] = WorkHistoryEntry(
                  companyController:
                      formState.workHistoryEntries[index].companyController,
                  positionController:
                      formState.workHistoryEntries[index].positionController,
                  descriptionController:
                      formState.workHistoryEntries[index].descriptionController,
                  fromDateController:
                      formState.workHistoryEntries[index].fromDateController,
                  toDateController:
                      formState.workHistoryEntries[index].toDateController,
                  isOngoing: isOngoing,
                );
              });
            },
            onCompanyChanged: (index, company) {},
            onPositionChanged: (index, position) {},
            onFromDateChanged: (index, fromDate) {},
            onToDateChanged: (index, toDate) {},
            onAdd: () {
              setState(() => formState.addWorkHistoryEntry());
            },
            onRemove: (index) {
              setState(() => formState.removeWorkHistoryEntry(index));
            },
            generalError: workHistoryError,
            hasError: workHistoryError.value != null,
          ),
          AppSpacing.vertical(context, 0.03),
          Obx(
            () => widget.controller.errorMessage.value.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(
                      bottom: AppSpacing.vertical(context, 0.02).height!,
                    ),
                    child: AppErrorMessage(
                      message: widget.controller.errorMessage.value,
                      icon: Iconsax.info_circle,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Obx(
            () => AppButton(
              text: AppTexts.update,
              onPressed: _saveProfile,
              isLoading: widget.controller.isLoading.value,
            ),
          ),
        ],
      ),
    );
  }
}
