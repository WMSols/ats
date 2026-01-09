import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppCandidateProfileDataRow {
  AppCandidateProfileDataRow._();

  /// Builds the column definitions for the profile table
  static List<DataColumn> buildColumns(BuildContext context) {
    return [
      DataColumn(
        label: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 4.0,
          ),
          child: Text(
            AppTexts.field,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      DataColumn(
        label: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 4.0,
          ),
          child: Text(
            AppTexts.value,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ];
  }

  /// Builds a data row with field label and value
  static DataRow buildDataRow(
    BuildContext context,
    String fieldLabel,
    String value, {
    bool isMultiline = false,
    bool isSectionHeader = false,
  }) {
    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: isMultiline ? 12.0 : 8.0,
              horizontal: 4.0,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: fieldLabel.isEmpty
                  ? const SizedBox.shrink()
                  : Text(
                      fieldLabel,
                      style: AppTextStyles.bodyText(context).copyWith(
                        fontWeight: isSectionHeader
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSectionHeader
                            ? AppColors.secondary
                            : null,
                      ),
                    ),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: isMultiline ? 12.0 : 8.0,
              horizontal: 4.0,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: isMultiline
                  ? ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 200,
                        maxWidth: double.infinity,
                      ),
                      child: Text(
                        value,
                        style: AppTextStyles.bodyText(context).copyWith(
                          height: 1.5, // Line height for better readability
                        ),
                        maxLines: null,
                        softWrap: true,
                      ),
                    )
                  : Text(
                      value,
                      style: AppTextStyles.bodyText(context),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds an empty state row when profile is null
  static List<DataRow> buildEmptyStateRow(BuildContext context) {
    return [
      DataRow(
        cells: [
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              child: Text(
                'Profile',
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
              child: Text(
                'No profile data available',
                style: AppTextStyles.bodyText(context),
              ),
            ),
          ),
        ],
      ),
    ];
  }
}
