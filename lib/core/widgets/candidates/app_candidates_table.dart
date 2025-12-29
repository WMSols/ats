import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/entities/user_entity.dart';

class AppCandidatesTable extends StatelessWidget {
  final List<UserEntity> candidates;
  final String Function(String userId) getName;
  final String Function(String userId) getCompany;
  final String Function(String userId) getPosition;
  final String Function(String userId) getStatus;
  final Function(UserEntity) onCandidateTap;

  const AppCandidatesTable({
    super.key,
    required this.candidates,
    required this.getName,
    required this.getCompany,
    required this.getPosition,
    required this.getStatus,
    required this.onCandidateTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.padding(context).copyWith(left: 0, right: 0),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(AppColors.lightGrey),
          columns: [
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  AppTexts.name,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  AppTexts.email,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  AppTexts.company,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  AppTexts.position,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  AppTexts.status,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
          rows: candidates.map((candidate) {
            final name = getName(candidate.userId);
            final company = getCompany(candidate.userId);
            final position = getPosition(candidate.userId);
            final status = getStatus(candidate.userId);

            return DataRow(
              cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: InkWell(
                      onTap: () => onCandidateTap(candidate),
                      child: Text(
                        name,
                        style: AppTextStyles.bodyText(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: InkWell(
                      onTap: () => onCandidateTap(candidate),
                      child: Text(
                        candidate.email,
                        style: AppTextStyles.bodyText(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: InkWell(
                      onTap: () => onCandidateTap(candidate),
                      child: Text(
                        company,
                        style: AppTextStyles.bodyText(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: InkWell(
                      onTap: () => onCandidateTap(candidate),
                      child: Text(
                        position,
                        style: AppTextStyles.bodyText(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: InkWell(
                      onTap: () => onCandidateTap(candidate),
                      child: Text(
                        _formatStatus(status),
                        style: AppTextStyles.bodyText(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case AppConstants.documentStatusApproved:
        return AppTexts.approved;
      case AppConstants.documentStatusDenied:
        return AppTexts.denied;
      case AppConstants.documentStatusPending:
      default:
        return AppTexts.pending;
    }
  }
}
