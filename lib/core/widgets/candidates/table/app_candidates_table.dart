import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/core/widgets/candidates/table/app_candidate_table_columns.dart';
import 'package:ats/core/widgets/candidates/table/app_candidate_table_layout.dart';
import 'package:ats/core/widgets/candidates/table/app_candidate_table_rows.dart';

class AppCandidatesTable extends StatelessWidget {
  final List<UserEntity> candidates;
  final String Function(String userId) getName;
  final String Function(String userId) getCompany;
  final String Function(String userId) getPosition;
  final String Function(String userId) getStatus;
  final String Function(String userId) getAgentName;
  final String? Function(String userId) getAssignedAgentProfileId;
  final String Function(String userId) getProfession;
  final String Function(String userId) getSpecialties;
  final Function(UserEntity) onCandidateTap;
  final Function(UserEntity)? onCandidateEdit;
  final Function(UserEntity)? onCandidateDelete;
  final bool isSuperAdmin;
  final List<AdminProfileEntity> availableAgents;
  final Future<void> Function(String userId, String? agentId) onAgentChanged;

  const AppCandidatesTable({
    super.key,
    required this.candidates,
    required this.getName,
    required this.getCompany,
    required this.getPosition,
    required this.getStatus,
    required this.getAgentName,
    required this.getAssignedAgentProfileId,
    required this.getProfession,
    required this.getSpecialties,
    required this.onCandidateTap,
    this.onCandidateEdit,
    this.onCandidateDelete,
    required this.isSuperAdmin,
    required this.availableAgents,
    required this.onAgentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasActionsColumn =
        isSuperAdmin && (onCandidateEdit != null || onCandidateDelete != null);
    final tableWidth = AppCandidateTableLayout.tableWidth(
      includeActions: hasActionsColumn,
    );

    // Vertical scroll outside, horizontal inside — otherwise the inner
    // vertical scroll view is clamped to viewport width and Agent/Actions
    // columns cannot be reached by horizontal scroll.
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: AppSpacing.padding(context).copyWith(top: 0, bottom: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: hasActionsColumn ? 16.0 : 0),
        child: SizedBox(
          width: tableWidth,
          child: DataTable(
            columnSpacing: AppCandidateTableLayout.columnSpacing,
            headingRowColor: WidgetStateProperty.all(AppColors.lightGrey),
            columns: AppCandidateTableColumns.buildColumns(
              context,
              isSuperAdmin: isSuperAdmin,
              hasEditOrDelete:
                  onCandidateEdit != null || onCandidateDelete != null,
            ),
            rows: candidates.map((candidate) {
              final name = getName(candidate.userId);
              final company = getCompany(candidate.userId);
              final position = getPosition(candidate.userId);
              final profession = getProfession(candidate.userId);
              final specialties = getSpecialties(candidate.userId);
              final status = getStatus(candidate.userId);
              final agentName = getAgentName(candidate.userId);

              return AppCandidateTableRows.buildRow(
                context,
                candidate,
                name: name,
                email: candidate.email,
                company: company,
                position: position,
                profession: profession,
                specialties: specialties,
                status: status,
                agentName: agentName,
                assignedAgentProfileId: getAssignedAgentProfileId(
                  candidate.userId,
                ),
                isSuperAdmin: isSuperAdmin,
                availableAgents: availableAgents,
                onAgentChanged: onAgentChanged,
                onCandidateTap: () => onCandidateTap(candidate),
                onCandidateEdit: onCandidateEdit,
                onCandidateDelete: onCandidateDelete,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
