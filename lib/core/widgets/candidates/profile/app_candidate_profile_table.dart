import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/core/widgets/candidates/profile/app_candidate_profile_data_row.dart';
import 'package:ats/core/widgets/candidates/profile/app_candidate_profile_sections.dart';

class AppCandidateProfileTable extends StatelessWidget {
  final CandidateProfileEntity? profile;
  final String? fallbackEmail;
  final int documentsCount;
  final int applicationsCount;
  final String agentName;
  final bool isSuperAdmin;
  final List<AdminProfileEntity> availableAgents;
  final String? assignedAgentProfileId;
  final Future<void> Function(String? agentProfileId)? onAgentChanged;
  final String userId;

  const AppCandidateProfileTable({
    super.key,
    required this.profile,
    this.fallbackEmail,
    required this.documentsCount,
    required this.applicationsCount,
    required this.agentName,
    required this.isSuperAdmin,
    required this.availableAgents,
    this.assignedAgentProfileId,
    this.onAgentChanged,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.padding(context).copyWith(left: 0, right: 0),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(AppColors.lightGrey),
          dataRowMinHeight: 40.0,
          dataRowMaxHeight: double.infinity,
          columns: AppCandidateProfileDataRow.buildColumns(context),
          rows: AppCandidateProfileSections.buildAllSections(
            context: context,
            profile: profile,
            fallbackEmail: fallbackEmail,
            documentsCount: documentsCount,
            applicationsCount: applicationsCount,
            agentName: agentName,
            isSuperAdmin: isSuperAdmin,
            availableAgents: availableAgents,
            assignedAgentProfileId: assignedAgentProfileId,
            onAgentChanged: onAgentChanged,
            userId: userId,
          ),
        ),
      ),
    );
  }
}
