import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminJobEditScreen extends StatefulWidget {
  const AdminJobEditScreen({super.key});

  @override
  State<AdminJobEditScreen> createState() => _AdminJobEditScreenState();
}

class _AdminJobEditScreenState extends State<AdminJobEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController requirementsController;
  String? selectedStatus;
  final Set<String> selectedDocumentIds = {};
  String? _lastSyncedJobId; // Track the last synced job ID
  int _selectionVersion = 0; // Version counter to force rebuilds

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    requirementsController = TextEditingController();
    selectedStatus = null;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsController = Get.find<AdminJobsController>();
    final documentsController = Get.find<AdminDocumentsController>();

    return AppAdminLayout(
      title: AppTexts.editJob,
      child: Obx(() {
        final job = jobsController.selectedJob.value;
        if (job == null) {
          return AppEmptyState(
            message: AppTexts.jobNotFound,
            icon: Iconsax.document,
          );
        }

        // Sync local state with job data whenever job changes
        final currentDocIds = Set<String>.from(job.requiredDocumentIds);
        final docsChanged =
            _lastSyncedJobId == job.jobId &&
            (selectedDocumentIds.length != currentDocIds.length ||
                !selectedDocumentIds.containsAll(currentDocIds) ||
                !currentDocIds.containsAll(selectedDocumentIds));

        if (_lastSyncedJobId != job.jobId) {
          // New job or job ID changed - sync everything immediately
          titleController.text = job.title;
          descriptionController.text = job.description;
          requirementsController.text = job.requirements;
          selectedStatus = job.status;
          selectedDocumentIds.clear();
          selectedDocumentIds.addAll(job.requiredDocumentIds);
          _lastSyncedJobId = job.jobId;
          _selectionVersion++; // Increment version to force rebuild
        } else if (docsChanged) {
          // Same job - document IDs were updated externally, sync them immediately
          selectedDocumentIds.clear();
          selectedDocumentIds.addAll(job.requiredDocumentIds);
          _selectionVersion++; // Increment version to force rebuild
        }

        return _buildForm(context, documentsController, jobsController, job);
      }),
    );
  }

  Widget _buildDocumentSelector(
    BuildContext context,
    AdminDocumentsController documentsController,
  ) {
    return Obx(() {
      final documents = documentsController.filteredDocumentTypes.toList();
      // Use version counter in key to force rebuild when selection is synced
      return StatefulBuilder(
        key: ValueKey('doc_selector_v$_selectionVersion'),
        builder: (context, setStateBuilder) {
          return AppDocumentSelector(
            documents: documents,
            selectedDocumentIds: selectedDocumentIds,
            onSelectionChanged: (docId, isSelected) {
              // Update the Set
              if (isSelected) {
                selectedDocumentIds.add(docId);
              } else {
                selectedDocumentIds.remove(docId);
              }
              // Trigger rebuild using both builders
              setStateBuilder(() {});
              if (mounted) {
                setState(() {
                  _selectionVersion++; // Increment version on user selection too
                });
              }
            },
          );
        },
      );
    });
  }

  Widget _buildForm(
    BuildContext context,
    AdminDocumentsController documentsController,
    AdminJobsController jobsController,
    dynamic job,
  ) {
    return SingleChildScrollView(
      padding: AppSpacing.padding(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppJobFormFields(
              titleController: titleController,
              descriptionController: descriptionController,
              requirementsController: requirementsController,
            ),
            AppSpacing.vertical(context, 0.02),
            AppStatusDropdown(
              value: selectedStatus,
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
            ),
            AppSpacing.vertical(context, 0.02),
            Text(
              AppTexts.requiredDocuments,
              style: AppTextStyles.bodyText(
                context,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
            AppSpacing.vertical(context, 0.01),
            _buildDocumentSelector(context, documentsController),
            AppSpacing.vertical(context, 0.03),
            Obx(
              () => AppButton(
                text: AppTexts.updateJob,
                icon: Iconsax.edit,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    jobsController.updateJob(
                      jobId: job.jobId,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      requirements: requirementsController.text.trim(),
                      requiredDocumentIds: selectedDocumentIds.toList(),
                      status: selectedStatus,
                    );
                  }
                },
                isLoading: jobsController.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
