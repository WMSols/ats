import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AppRequestedDocumentsList extends StatelessWidget {
  final List<DocumentTypeEntity> requestedDocuments;
  final List<CandidateDocumentEntity> candidateDocuments;
  final Function(String docTypeId) onRevoke;
  final Function(String storageUrl)? onView;

  const AppRequestedDocumentsList({
    super.key,
    required this.requestedDocuments,
    required this.candidateDocuments,
    required this.onRevoke,
    this.onView,
  });

  /// Check if a requested document has been uploaded
  bool isDocumentUploaded(String docTypeId) {
    return candidateDocuments.any((doc) => doc.docTypeId == docTypeId);
  }

  /// Get the uploaded document for a requested document type
  CandidateDocumentEntity? getUploadedDocument(String docTypeId) {
    try {
      return candidateDocuments.firstWhere((doc) => doc.docTypeId == docTypeId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (requestedDocuments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.padding(context),
          child: Text(
            AppTexts.requestedDocuments,
            style: AppTextStyles.heading(context).copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: AppSpacing.symmetric(context, h: 0.02).horizontal,
            right: AppSpacing.symmetric(context, h: 0.02).horizontal,
            bottom: AppSpacing.symmetric(context, v: 0.02).vertical,
          ),
          itemCount: requestedDocuments.length,
          itemBuilder: (context, index) {
            final docType = requestedDocuments[index];
            final isUploaded = isDocumentUploaded(docType.docTypeId);
            final uploadedDoc = getUploadedDocument(docType.docTypeId);
            final documentStatus = uploadedDoc?.status ?? '';
            final hasStorageUrl = uploadedDoc?.storageUrl.isNotEmpty ?? false;

            return AppListCard(
              key: ValueKey('requested_doc_${docType.docTypeId}'),
              title: docType.name,
              subtitle: docType.description,
              icon: Iconsax.document_text,
              trailing: AppActionButton(
                text: AppTexts.revoke,
                onPressed: () => onRevoke(docType.docTypeId),
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              contentBelowSubtitle: Wrap(
                spacing: AppResponsive.screenWidth(context) * 0.01,
                runSpacing: AppResponsive.screenHeight(context) * 0.005,
                children: [
                  // Requested badge
                  AppStatusChip(
                    status: AppConstants.documentStatusRequested,
                    showIcon: false,
                  ),
                  // Completion status
                  if (isUploaded) ...[
                    AppStatusChip(
                      status: AppConstants.documentStatusApproved,
                      customText: 'Uploaded',
                    ),
                    // Show document status if uploaded
                    if (documentStatus.isNotEmpty)
                      AppStatusChip(status: documentStatus),
                    // Show view button if document has storage URL
                    if (hasStorageUrl && onView != null)
                      AppActionButton(
                        text: AppTexts.view,
                        onPressed: () => onView!(uploadedDoc!.storageUrl),
                        backgroundColor: AppColors.information,
                        foregroundColor: AppColors.white,
                      ),
                  ] else
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppResponsive.screenWidth(context) * 0.01,
                        vertical: AppResponsive.screenHeight(context) * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppResponsive.radius(context, factor: 5),
                        ),
                      ),
                      child: Text(
                        'NOT UPLOADED',
                        style: AppTextStyles.bodyText(context).copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: null,
            );
          },
        ),
      ],
    );
  }
}
