import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_auth_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminCandidatesListScreen extends StatelessWidget {
  const AdminCandidatesListScreen({super.key});

  void _showDeleteConfirmation(
    BuildContext context,
    AdminCandidatesController controller,
    String candidateName,
    String candidateUserId,
    String candidateProfileId,
  ) {
    AppAlertDialog.show(
      title: AppTexts.deleteCandidate,
      subtitle:
          '${AppTexts.deleteCandidateConfirmation} "$candidateName"?\n\n${AppTexts.deleteCandidateWarning}',
      primaryButtonText: AppTexts.delete,
      secondaryButtonText: AppTexts.cancel,
      onPrimaryPressed: () => controller.deleteCandidateById(
        userId: candidateUserId,
        profileId: candidateProfileId,
      ),
      onSecondaryPressed: () {},
      primaryButtonColor: AppColors.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCandidatesController>();

    return AppAdminLayout(
      title: AppTexts.candidates,
      child: Column(
        children: [
          // Search Section
          Obx(
            () => AppSearchCreateBar(
              searchHint: AppTexts.searchCandidates,
              createButtonText: AppTexts.createCandidate,
              createButtonIcon: Iconsax.add,
              onSearchChanged: (value) => controller.setSearchQuery(value),
              onCreatePressed: controller.isSuperAdmin
                  ? () {
                      Get.toNamed(AppConstants.routeAdminCreateCandidate);
                    }
                  : null, // Recruiters can't create candidates
            ),
          ),
          // Candidates List
          Expanded(
            child: Obx(() {
              // Observe admin profile to rebuild when it loads (for role-based filtering)
              try {
                final authController = Get.find<AdminAuthController>();
                authController.currentAdminProfile.value;
              } catch (e) {
                // AdminAuthController not found, continue
              }

              if (controller.candidates.isEmpty) {
                return AppEmptyState(
                  message: AppTexts.noCandidatesAvailable,
                  icon: Iconsax.profile_circle,
                );
              }

              if (controller.filteredCandidates.isEmpty) {
                return AppEmptyState(
                  message: AppTexts.noCandidatesFound,
                  icon: Iconsax.profile_circle,
                );
              }

              // Observe candidateProfiles and candidateDocumentsMap to rebuild when data loads
              // Access the maps to ensure GetX tracks changes
              for (var candidate in controller.filteredCandidates) {
                controller.candidateProfiles[candidate.userId];
                controller.candidateDocumentsMap[candidate.userId];
              }

              // Observe availableAgents to rebuild when agents load
              final agents = controller.availableAgents.toList();

              return AppCandidatesTable(
                candidates: controller.filteredCandidates,
                getName: (userId) => controller.getCandidateName(userId),
                getCompany: (userId) => controller.getCandidateCompany(userId),
                getPosition: (userId) =>
                    controller.getCandidatePosition(userId),
                getStatus: (userId) => controller.getCandidateStatus(userId),
                getAgentName: (userId) =>
                    controller.getCandidateAgentName(userId),
                getAssignedAgentProfileId: (userId) =>
                    controller.getAssignedAgentProfileId(userId),
                isSuperAdmin: controller.isSuperAdmin,
                availableAgents: agents,
                onAgentChanged: (userId, agentId) => controller
                    .updateCandidateAgent(userId: userId, agentId: agentId),
                onCandidateTap: (candidate) {
                  controller.selectCandidate(candidate);
                  Get.toNamed(AppConstants.routeAdminCandidateDetails);
                },
                onCandidateEdit: controller.isSuperAdmin
                    ? (candidate) {
                        controller.selectCandidate(candidate);
                        Get.toNamed(AppConstants.routeAdminEditCandidate);
                      }
                    : null,
                onCandidateDelete: controller.isSuperAdmin
                    ? (candidate) {
                        // Get candidate name and profile info
                        final candidateName = controller.getCandidateName(
                          candidate.userId,
                        );
                        final profile =
                            controller.candidateProfiles[candidate.userId];
                        final profileId = profile?.profileId ?? '';

                        if (profileId.isEmpty) {
                          AppSnackbar.error(
                            'Unable to delete: Profile ID not found',
                          );
                          return;
                        }

                        _showDeleteConfirmation(
                          context,
                          controller,
                          candidateName,
                          candidate.userId,
                          profileId,
                        );
                      }
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }
}
