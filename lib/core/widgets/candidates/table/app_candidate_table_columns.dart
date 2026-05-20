import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/candidates/table/app_candidate_table_layout.dart';

class AppCandidateTableColumns {
  AppCandidateTableColumns._();

  /// Builds all column definitions for the candidates table
  static List<DataColumn> buildColumns(
    BuildContext context, {
    required bool isSuperAdmin,
    required bool hasEditOrDelete,
  }) {
    return [
      _buildColumn(context, AppTexts.name, AppCandidateTableLayout.name),
      _buildColumn(context, AppTexts.email, AppCandidateTableLayout.email),
      _buildColumn(context, AppTexts.company, AppCandidateTableLayout.company),
      _buildColumn(
        context,
        AppTexts.position,
        AppCandidateTableLayout.position,
      ),
      _buildColumn(
        context,
        AppTexts.profession,
        AppCandidateTableLayout.profession,
      ),
      _buildColumn(
        context,
        AppTexts.specialties,
        AppCandidateTableLayout.specialties,
      ),
      _buildColumn(context, AppTexts.status, AppCandidateTableLayout.status),
      _buildColumn(context, AppTexts.agent, AppCandidateTableLayout.agent),
      if (isSuperAdmin && hasEditOrDelete)
        _buildColumn(
          context,
          AppTexts.actions,
          AppCandidateTableLayout.actions,
        ),
    ];
  }

  static DataColumn _buildColumn(
    BuildContext context,
    String label,
    double width,
  ) {
    return DataColumn(
      label: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text(
            label,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}
