import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminJobsListScreen extends StatelessWidget {
  const AdminJobsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminJobsController>();

    return AppAdminLayout(
      title: AppTexts.jobs,
      child: Column(
        children: [
          Column(
            children: [
              // Search Field and Create Button Row
              AppSearchCreateBar(
                searchHint: AppTexts.searchJobs,
                createButtonText: AppTexts.createJob,
                createButtonIcon: Iconsax.add,
                onSearchChanged: (value) => controller.setSearchQuery(value),
                onCreatePressed: () =>
                    Get.toNamed(AppConstants.routeAdminJobCreate),
              ),
              AppSpacing.vertical(context, 0.02),
              // Status Filter Tabs
              Obx(
                () => AppFilterTabs(
                  selectedFilter: controller.selectedStatusFilter.value,
                  onFilterChanged: (filter) {
                    controller.setStatusFilter(
                      filter == 'open'
                          ? AppConstants.jobStatusOpen
                          : filter == 'closed'
                          ? AppConstants.jobStatusClosed
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
          // Jobs List
          Expanded(
            child: Obx(() {
              if (controller.filteredJobs.isEmpty) {
                return AppEmptyState(
                  message: controller.jobs.isEmpty
                      ? AppTexts.noJobsAvailable
                      : AppTexts.noJobsFound,
                  icon: Iconsax.briefcase,
                );
              }

              return ListView.builder(
                padding: AppSpacing.padding(context),
                itemCount: controller.filteredJobs.length,
                itemBuilder: (context, index) {
                  final job = controller.filteredJobs[index];
                  final applicationCount = controller.getApplicationCount(
                    job.jobId,
                  );

                  return AppJobCard(
                    job: job,
                    applicationCount: applicationCount,
                    onTap: () {
                      controller.selectJob(job);
                      Get.toNamed(AppConstants.routeAdminJobDetails);
                    },
                    onEdit: () {
                      controller.selectJob(job);
                      Get.toNamed(AppConstants.routeAdminJobEdit);
                    },
                    onDelete: () => _showDeleteConfirmation(
                      context,
                      controller,
                      job.jobId,
                      job.title,
                    ),
                    onStatusToggle: () {
                      final newStatus = job.status == AppConstants.jobStatusOpen
                          ? AppConstants.jobStatusClosed
                          : AppConstants.jobStatusOpen;
                      controller.changeJobStatus(job.jobId, newStatus);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AdminJobsController controller,
    String jobId,
    String jobTitle,
  ) {
    AppDeleteConfirmationDialog.show(
      title: AppTexts.deleteJob,
      message:
          '${AppTexts.deleteJobConfirmation} "$jobTitle"?\n\n${AppTexts.deleteJobWarning}',
      onConfirm: () => controller.deleteJob(jobId),
    );
  }
}
