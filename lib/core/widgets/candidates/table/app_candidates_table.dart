import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/core/widgets/candidates/table/app_candidate_table_columns.dart';
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
    // Calculate minimum width needed for all columns
    // Name(180) + Email(250) + Company(180) + Position(180) + Profession(220) + Specialties(250) + Status(120) + Agent(180) + Actions(120) = ~1680
    // Adding extra padding and spacing: ~1800 to ensure all columns are visible
    const minTableWidth = 1800.0;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.padding(context).copyWith(left: 0, right: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: minTableWidth,
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: WidgetStateProperty.all(AppColors.lightGrey),
            columns: AppCandidateTableColumns.buildColumns(
              context,
              isSuperAdmin: isSuperAdmin,
              hasEditOrDelete: onCandidateEdit != null || onCandidateDelete != null,
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
                assignedAgentProfileId: getAssignedAgentProfileId(candidate.userId),
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
