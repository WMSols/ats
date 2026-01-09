import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppCandidateTableColumns {
  AppCandidateTableColumns._();

  /// Builds all column definitions for the candidates table
  static List<DataColumn> buildColumns(
    BuildContext context, {
    required bool isSuperAdmin,
    required bool hasEditOrDelete,
  }) {
    return [
      _buildColumn(context, AppTexts.name),
      _buildColumn(context, AppTexts.email),
      _buildColumn(context, AppTexts.company),
      _buildColumn(context, AppTexts.position),
      _buildColumn(context, AppTexts.profession),
      _buildColumn(context, AppTexts.specialties),
      _buildColumn(context, AppTexts.status),
      _buildColumn(context, AppTexts.agent),
      if (isSuperAdmin && hasEditOrDelete)
        _buildColumn(context, AppTexts.actions),
    ];
  }

  static DataColumn _buildColumn(BuildContext context, String label) {
    return DataColumn(
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Text(
          label,
          style: AppTextStyles.bodyText(
            context,
          ).copyWith(color: AppColors.secondary, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
