import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/presentation/candidate/controllers/resume_controller.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/widgets/common/forms/app_required_label.dart';
import 'package:ats/core/widgets/documents/components/app_document_viewer.dart';
import 'package:ats/core/widgets/common/buttons/app_action_button.dart';

/// Reusable resume block for candidate profile: upload, view, replace, delete.
class ResumeSection extends StatelessWidget {
  const ResumeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final resumeController = Get.find<ResumeController>();

    return Obx(() {
      // Effective resume = pending upload or saved on profile (null if pending delete)
      resumeController.pendingResumeUrl.value;
      resumeController.pendingResumeDelete.value;
      final effectiveUrl = resumeController.effectiveResumeUrl;
      final hasResume =
          effectiveUrl != null && effectiveUrl.isNotEmpty;
      final fileName =
          resumeController.effectiveResumeFileName ?? AppTexts.resume;
      final isUploading = resumeController.isUploading.value;
      final progress = resumeController.uploadProgress.value;
      final resumeError = resumeController.errorMessage.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ResumeSectionHeader(),
          AppSpacing.vertical(context, 0.01),
          Text(
            AppTexts.resumeFormatsHint,
            style: AppTextStyles.hintText(context),
          ),
          if (resumeError.isNotEmpty) ...[
            AppSpacing.vertical(context, 0.01),
            AppErrorMessage(message: resumeError, icon: Iconsax.info_circle),
          ],
          if (isUploading) ...[
            AppSpacing.vertical(context, 0.01),
            LinearProgressIndicator(value: progress),
          ],
          AppSpacing.vertical(context, 0.01),
          ResumeSectionActions(
            hasResume: hasResume,
            isUploading: isUploading,
            fileName: fileName,
            onUploadReplace: resumeController.uploadResume,
            onView: () {
              final url = resumeController.effectiveResumeUrl;
              if (url != null && url.isNotEmpty) {
                AppDocumentViewer.show(
                  documentUrl: url,
                  documentName: fileName,
                );
              }
            },
            onDelete: resumeController.deleteResume,
          ),
          if (hasResume) ...[
            AppSpacing.vertical(context, 0.01),
            Text(
              fileName,
              style: AppTextStyles.bodyText(
                context,
              ).copyWith(color: AppColors.success),
              overflow: TextOverflow.ellipsis,
            ),
          ],
          AppSpacing.vertical(context, 0.02),
        ],
      );
    });
  }
}

class _ResumeSectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.bodyText(context).copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.secondary,
    );
    return Row(
      children: [
        Icon(
          Iconsax.document_text,
          size: AppResponsive.iconSize(context),
          color: AppColors.primary,
        ),
        SizedBox(width: AppSpacing.horizontal(context, 0.01).width),
        AppRequiredLabel(
          text: AppTexts.resume,
          style: labelStyle,
        ),
      ],
    );
  }
}

/// Row of action buttons: Upload/Replace, View, Delete (using AppActionButton).
class ResumeSectionActions extends StatelessWidget {
  final bool hasResume;
  final bool isUploading;
  final String fileName;
  final VoidCallback onUploadReplace;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const ResumeSectionActions({
    super.key,
    required this.hasResume,
    required this.isUploading,
    required this.fileName,
    required this.onUploadReplace,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isUploading;
    final spacing = AppSpacing.horizontal(context, 0.005).width;

    return Row(
      children: [
        AppActionButton(
          text: hasResume ? AppTexts.replaceResume : AppTexts.uploadResume,
          onPressed: disabled ? null : onUploadReplace,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
        if (hasResume) ...[
          SizedBox(width: spacing),
          AppActionButton(
            text: AppTexts.viewCurrentResume,
            onPressed: disabled ? null : onView,
            backgroundColor: AppColors.information,
            foregroundColor: AppColors.white,
          ),
          SizedBox(width: spacing),
          AppActionButton.delete(onPressed: disabled ? null : onDelete),
        ],
      ],
    );
  }
}
