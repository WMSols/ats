import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/core/widgets/candidates/profile/app_candidate_profile_data_row.dart';
import 'package:ats/core/widgets/documents/components/app_document_viewer.dart';
import 'package:ats/core/widgets/common/buttons/app_action_button.dart';

/// Builds resume section rows for admin candidate details table.
class AppAdminResumeSection {
  AppAdminResumeSection._();

  static List<DataRow> buildRows(
    BuildContext context,
    CandidateProfileEntity profile,
  ) {
    final rows = <DataRow>[];

    rows.add(
      AppCandidateProfileDataRow.buildDataRow(
        context,
        AppTexts.resume,
        '',
        isSectionHeader: true,
      ),
    );

    final hasResume =
        profile.resumeUrl != null && profile.resumeUrl!.isNotEmpty;
    final fileName = profile.resumeFileName ?? AppTexts.resume;

    rows.add(
      DataRow(
        cells: [
          DataCell(
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppTexts.resume,
                style: AppTextStyles.bodyText(context),
              ),
            ),
          ),
          DataCell(
            Padding(
              padding: AppSpacing.symmetric(context, h: 0.0, v: 0.01),
              child: hasResume
                  ? AppActionButton(
                      text: AppTexts.downloadPreview,
                      onPressed: () {
                        AppDocumentViewer.show(
                          documentUrl: profile.resumeUrl!,
                          documentName: fileName,
                        );
                      },
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    )
                  : Text(
                      AppTexts.notUploaded,
                      style: AppTextStyles.bodyText(
                        context,
                      ).copyWith(color: AppColors.error),
                    ),
            ),
          ),
        ],
      ),
    );

    return rows;
  }
}
