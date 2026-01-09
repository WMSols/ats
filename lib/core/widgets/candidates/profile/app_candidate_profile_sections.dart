import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/core/widgets/candidates/components/app_candidate_agent_dropdown.dart';
import 'package:ats/core/widgets/candidates/profile/app_candidate_profile_formatters.dart';
import 'package:ats/core/widgets/candidates/profile/app_candidate_profile_data_row.dart';

class AppCandidateProfileSections {
  AppCandidateProfileSections._();

  /// Builds all profile rows organized by sections
  static List<DataRow> buildAllSections({
    required BuildContext context,
    required CandidateProfileEntity? profile,
    required String? fallbackEmail,
    required int documentsCount,
    required int applicationsCount,
    required String agentName,
    required bool isSuperAdmin,
    required List<AdminProfileEntity> availableAgents,
    required String? assignedAgentProfileId,
    required Future<void> Function(String? agentProfileId)? onAgentChanged,
    required String userId,
  }) {
    if (profile == null) {
      return AppCandidateProfileDataRow.buildEmptyStateRow(context);
    }

    final rows = <DataRow>[];

    // Build all sections
    rows.addAll(_buildCandidateProfileSection(context, profile, fallbackEmail));
    rows.addAll(_buildPhonesSection(context, profile));
    rows.addAll(_buildSpecialtySection(context, profile));
    rows.addAll(_buildBackgroundHistorySection(context, profile));
    rows.addAll(_buildLicensureSection(context, profile));
    rows.addAll(_buildWorkHistorySection(context, profile));
    rows.addAll(_buildEducationSection(context, profile));
    rows.addAll(_buildCertificationsSection(context, profile));
    rows.addAll(
      _buildStatisticsSection(context, documentsCount, applicationsCount),
    );
    rows.addAll(
      _buildAgentAssignmentSection(
        context,
        profile,
        agentName,
        isSuperAdmin,
        availableAgents,
        assignedAgentProfileId,
        onAgentChanged,
        userId,
      ),
    );

    return rows;
  }

  /// Builds the candidate profile section (name, email, address, SSN)
  static List<DataRow> _buildCandidateProfileSection(
    BuildContext context,
    CandidateProfileEntity profile,
    String? fallbackEmail,
  ) {
    final rows = <DataRow>[];

    rows.add(
      AppCandidateProfileDataRow.buildDataRow(
        context,
        AppTexts.candidateProfile,
        '',
        isSectionHeader: true,
      ),
    );

    // Full Name
    final fullName = AppCandidateProfileFormatters.getFullName(profile);
    rows.add(
      AppCandidateProfileDataRow.buildDataRow(context, AppTexts.name, fullName),
    );

    // Email
    final email = profile.email ?? fallbackEmail ?? 'N/A';
    rows.add(
      AppCandidateProfileDataRow.buildDataRow(context, AppTexts.email, email),
    );

    // Full Address (if all components exist)
    final fullAddress = AppCandidateProfileFormatters.getFullAddress(profile);
    if (fullAddress.isNotEmpty) {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.address,
          fullAddress,
          isMultiline: true,
        ),
      );
    } else {
      // Show individual address components if full address not available
      if (profile.address1 != null && profile.address1!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.address1,
            profile.address1!,
          ),
        );
      }

      if (profile.address2 != null && profile.address2!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.address2,
            profile.address2!,
          ),
        );
      }

      if (profile.city != null && profile.city!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.city,
            profile.city!,
          ),
        );
      }

      if (profile.state != null && profile.state!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.state,
            profile.state!,
          ),
        );
      }

      if (profile.zip != null && profile.zip!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.zip,
            profile.zip!,
          ),
        );
      }
    }

    // SSN
    if (profile.ssn != null && profile.ssn!.isNotEmpty) {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.ssn,
          profile.ssn!,
        ),
      );
    }

    return rows;
  }

  /// Builds the phones section
  static List<DataRow> _buildPhonesSection(
    BuildContext context,
    CandidateProfileEntity profile,
  ) {
    final rows = <DataRow>[];
    final phonesText = AppCandidateProfileFormatters.formatPhones(profile);

    if (phonesText.isNotEmpty) {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.phones,
          '',
          isSectionHeader: true,
        ),
      );
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.phoneNumber,
          phonesText,
          isMultiline: true,
        ),
      );
    }

    return rows;
  }

  /// Builds the specialty section (profession, specialties)
  static List<DataRow> _buildSpecialtySection(
    BuildContext context,
    CandidateProfileEntity profile,
  ) {
    final rows = <DataRow>[];

    if ((profile.profession != null && profile.profession!.isNotEmpty) ||
        (profile.specialties != null && profile.specialties!.isNotEmpty)) {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.specialty,
          '',
          isSectionHeader: true,
        ),
      );

      // Profession
      if (profile.profession != null && profile.profession!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.profession,
            profile.profession!,
          ),
        );
      }

      // Specialties
      if (profile.specialties != null && profile.specialties!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.specialties,
            profile.specialties!,
          ),
        );
      }
    }

    return rows;
  }

  /// Builds the background history section
  static List<DataRow> _buildBackgroundHistorySection(
    BuildContext context,
    CandidateProfileEntity profile,
  ) {
    final rows = <DataRow>[];

    if (profile.liabilityAction != null ||
        profile.licenseAction != null ||
        profile.previouslyTraveled != null ||
        profile.terminatedFromAssignment != null) {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.backgroundHistory,
          '',
          isSectionHeader: true,
        ),
      );

      // Liability Action
      if (profile.liabilityAction != null &&
          profile.liabilityAction!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.liabilityAction,
            profile.liabilityAction == 'Yes' ? AppTexts.yes : AppTexts.no,
          ),
        );
      }

      // License Action
      if (profile.licenseAction != null && profile.licenseAction!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.licenseAction,
            profile.licenseAction == 'Yes' ? AppTexts.yes : AppTexts.no,
          ),
        );
      }

      // Previously Traveled
      if (profile.previouslyTraveled != null &&
          profile.previouslyTraveled!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.previouslyTraveled,
            profile.previouslyTraveled == 'Yes' ? AppTexts.yes : AppTexts.no,
          ),
        );
      }

      // Terminated From Assignment
      if (profile.terminatedFromAssignment != null &&
          profile.terminatedFromAssignment!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.terminatedFromAssignment,
            profile.terminatedFromAssignment == 'Yes'
                ? AppTexts.yes
                : AppTexts.no,
          ),
        );
      }
    }

    // Also add a duplicate section (as in original code)
    rows.add(
      AppCandidateProfileDataRow.buildDataRow(
        context,
        AppTexts.backgroundHistory,
        '',
        isSectionHeader: true,
      ),
    );

    // Liability Action
    if (profile.liabilityAction != null &&
        profile.liabilityAction!.isNotEmpty) {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.liabilityAction,
          profile.liabilityAction == 'Yes' ? AppTexts.yes : AppTexts.no,
        ),
      );
    }

    // License Action
    if (profile.licenseAction != null && profile.licenseAction!.isNotEmpty) {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.licenseAction,
          profile.licenseAction == 'Yes' ? AppTexts.yes : AppTexts.no,
        ),
      );
    }

    // Previously Traveled
    if (profile.previouslyTraveled != null &&
        profile.previouslyTraveled!.isNotEmpty) {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.previouslyTraveled,
          profile.previouslyTraveled == 'Yes' ? AppTexts.yes : AppTexts.no,
        ),
      );
    }

    // Terminated From Assignment
    if (profile.terminatedFromAssignment != null &&
        profile.terminatedFromAssignment!.isNotEmpty) {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.terminatedFromAssignment,
          profile.terminatedFromAssignment == 'Yes'
              ? AppTexts.yes
              : AppTexts.no,
        ),
      );
    }

    return rows;
  }

  /// Builds the licensure section
  static List<DataRow> _buildLicensureSection(
    BuildContext context,
    CandidateProfileEntity profile,
  ) {
    final rows = <DataRow>[];

    if ((profile.licensureState != null &&
            profile.licensureState!.isNotEmpty) ||
        (profile.npi != null && profile.npi!.isNotEmpty)) {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.licensure,
          '',
          isSectionHeader: true,
        ),
      );

      // Licensure State
      if (profile.licensureState != null &&
          profile.licensureState!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.state,
            profile.licensureState!,
          ),
        );
      }

      // NPI
      if (profile.npi != null && profile.npi!.isNotEmpty) {
        rows.add(
          AppCandidateProfileDataRow.buildDataRow(
            context,
            AppTexts.npi,
            profile.npi!,
          ),
        );
      }
    }

    return rows;
  }

  /// Builds the work history section
  static List<DataRow> _buildWorkHistorySection(
    BuildContext context,
    CandidateProfileEntity profile,
  ) {
    final rows = <DataRow>[];
    final workHistoryText = AppCandidateProfileFormatters.formatWorkHistory(
      profile,
    );

    if (workHistoryText.isNotEmpty && workHistoryText != 'No work history') {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.workHistory,
          '',
          isSectionHeader: true,
        ),
      );
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          '',
          workHistoryText,
          isMultiline: true,
        ),
      );
    }

    return rows;
  }

  /// Builds the education section
  static List<DataRow> _buildEducationSection(
    BuildContext context,
    CandidateProfileEntity profile,
  ) {
    final rows = <DataRow>[];
    final educationText = AppCandidateProfileFormatters.formatEducation(
      profile,
    );

    if (educationText.isNotEmpty) {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.education,
          '',
          isSectionHeader: true,
        ),
      );
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          '',
          educationText,
          isMultiline: true,
        ),
      );
    }

    return rows;
  }

  /// Builds the certifications section
  static List<DataRow> _buildCertificationsSection(
    BuildContext context,
    CandidateProfileEntity profile,
  ) {
    final rows = <DataRow>[];
    final certificationsText =
        AppCandidateProfileFormatters.formatCertifications(profile);

    if (certificationsText.isNotEmpty) {
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          AppTexts.certifications,
          '',
          isSectionHeader: true,
        ),
      );
      rows.add(
        AppCandidateProfileDataRow.buildDataRow(
          context,
          '',
          certificationsText,
          isMultiline: true,
        ),
      );
    }

    return rows;
  }

  /// Builds the statistics section
  static List<DataRow> _buildStatisticsSection(
    BuildContext context,
    int documentsCount,
    int applicationsCount,
  ) {
    final rows = <DataRow>[];

    rows.add(
      AppCandidateProfileDataRow.buildDataRow(
        context,
        'Statistics',
        '',
        isSectionHeader: true,
      ),
    );

    // Documents Count
    rows.add(
      AppCandidateProfileDataRow.buildDataRow(
        context,
        AppTexts.documentsUploadedCount,
        documentsCount.toString(),
      ),
    );

    // Applications Count
    rows.add(
      AppCandidateProfileDataRow.buildDataRow(
        context,
        AppTexts.jobsAppliedCount,
        applicationsCount.toString(),
      ),
    );

    return rows;
  }

  /// Builds the agent assignment section
  static List<DataRow> _buildAgentAssignmentSection(
    BuildContext context,
    CandidateProfileEntity profile,
    String agentName,
    bool isSuperAdmin,
    List<AdminProfileEntity> availableAgents,
    String? assignedAgentProfileId,
    Future<void> Function(String? agentProfileId)? onAgentChanged,
    String userId,
  ) {
    final rows = <DataRow>[];

    rows.add(
      AppCandidateProfileDataRow.buildDataRow(
        context,
        'Agent Assignment',
        '',
        isSectionHeader: true,
      ),
    );

    // Agent
    final agentCallback = onAgentChanged;
    rows.add(
      DataRow(
        cells: [
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              child: Text(
                AppTexts.agent,
                style: AppTextStyles.bodyText(context),
              ),
            ),
          ),
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              child: isSuperAdmin && agentCallback != null
                  ? AppCandidateAgentDropdown(
                      userId: userId,
                      currentAgentName: agentName,
                      assignedAgentProfileId: assignedAgentProfileId,
                      availableAgents: availableAgents,
                      onAgentChanged: (_, agentId) async {
                        await agentCallback(agentId);
                      },
                    )
                  : Text(
                      agentName,
                      style: AppTextStyles.bodyText(context),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        ],
      ),
    );

    return rows;
  }
}
