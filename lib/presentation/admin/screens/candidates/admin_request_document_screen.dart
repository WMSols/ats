import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/widgets/common/forms/app_dropdown_field.dart'
    as dropdown;

class AdminRequestDocumentScreen extends StatefulWidget {
  const AdminRequestDocumentScreen({super.key});

  @override
  State<AdminRequestDocumentScreen> createState() =>
      _AdminRequestDocumentScreenState();
}

class _AdminRequestDocumentScreenState
    extends State<AdminRequestDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  final selectedDocTypeId = Rxn<String>();
  final _canSubmit = false.obs;

  bool get canSubmit {
    return selectedDocTypeId.value != null &&
        selectedDocTypeId.value!.isNotEmpty &&
        descriptionController.text.trim().isNotEmpty;
  }

  void _onFieldChanged() {
    _canSubmit.value = canSubmit;
    setState(() {});
  }

  void _onDocumentTypeSelected(DocumentTypeEntity? value) {
    selectedDocTypeId.value = value?.docTypeId;
    if (value != null) {
      // Prefill from selected type; title stays optional (defaults to type name)
      descriptionController.text = value.description;
    }
    _onFieldChanged();
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    titleController.addListener(_onFieldChanged);
    descriptionController.addListener(_onFieldChanged);
    _canSubmit.value = canSubmit;
  }

  @override
  void dispose() {
    titleController.removeListener(_onFieldChanged);
    descriptionController.removeListener(_onFieldChanged);
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCandidatesController>();
    final documentsController = Get.find<AdminDocumentsController>();

    return AppAdminLayout(
      title: AppTexts.requestDocument,
      child: Obx(
        () => AppLoadingOverlay(
          isLoading: controller.isLoading.value,
          child: SingleChildScrollView(
            padding: AppSpacing.padding(context),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() {
                    final documentTypes = documentsController.documentTypes
                        .toList();
                    DocumentTypeEntity? selectedDocType;
                    try {
                      selectedDocType = documentTypes.firstWhere(
                        (dt) => dt.docTypeId == selectedDocTypeId.value,
                      );
                    } catch (e) {
                      selectedDocType = null;
                    }
                    return dropdown.AppDropDownField<DocumentTypeEntity>(
                      labelText: '${AppTexts.documentType}(*)',
                      showLabelAbove: true,
                      hintText: 'Select document type',
                      value: selectedDocType,
                      items: documentTypes
                          .map(
                            (dt) => DropdownMenuItem<DocumentTypeEntity>(
                              value: dt,
                              child: Text(dt.name),
                            ),
                          )
                          .toList(),
                      onChanged: _onDocumentTypeSelected,
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a document type';
                        }
                        return null;
                      },
                    );
                  }),
                  AppSpacing.vertical(context, 0.02),
                  AppDocumentFormFields(
                    titleController: titleController,
                    descriptionController: descriptionController,
                  ),
                  AppSpacing.vertical(context, 0.03),
                  Obx(() {
                    final isLoading = controller.isLoading.value;
                    return AppButton(
                      text: AppTexts.create,
                      icon: Iconsax.add,
                      onPressed: _canSubmit.value && !isLoading
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                if (selectedDocTypeId.value == null) {
                                  AppSnackbar.error(
                                    'Please select a document type',
                                  );
                                  return;
                                }

                                String resolvedName = titleController.text
                                    .trim();
                                if (resolvedName.isEmpty) {
                                  try {
                                    final dt = documentsController.documentTypes
                                        .firstWhere(
                                          (d) =>
                                              d.docTypeId ==
                                              selectedDocTypeId.value,
                                        );
                                    resolvedName = dt.name;
                                  } catch (_) {
                                    AppSnackbar.error(
                                      'Please select a document type',
                                    );
                                    return;
                                  }
                                }

                                controller.requestDocumentForCandidate(
                                  name: resolvedName,
                                  description: descriptionController.text
                                      .trim(),
                                );
                              }
                            }
                          : null,
                      isLoading: isLoading,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
