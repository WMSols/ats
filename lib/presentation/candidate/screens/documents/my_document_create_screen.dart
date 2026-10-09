import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ats/presentation/candidate/controllers/documents_controller.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/widgets/common/forms/app_dropdown_field.dart'
    as dropdown;

class MyDocumentCreateScreen extends StatefulWidget {
  const MyDocumentCreateScreen({super.key});

  @override
  State<MyDocumentCreateScreen> createState() => _MyDocumentCreateScreenState();
}

class _MyDocumentCreateScreenState extends State<MyDocumentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController expiryController;
  final selectedDocTypeId = Rxn<String>();
  bool hasNoExpiry = false;

  // Validation errors
  final titleError = Rxn<String>();
  final descriptionError = Rxn<String>();
  final expiryError = Rxn<String>();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    expiryController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    expiryController.dispose();
    // Clear selected file when screen is disposed
    final controller = Get.find<DocumentsController>();
    controller.clearSelectedFile();
    super.dispose();
  }

  void _onDocumentTypeSelected(DocumentTypeEntity? value) {
    selectedDocTypeId.value = value?.docTypeId;
    if (value != null) {
      descriptionController.text = value.description;
      validateDescription(value.description);
    }
    setState(() {});
  }

  // Validation methods
  void validateTitle(String? value) {
    // Title is optional; clear any prior error
    titleError.value = null;
  }

  void validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      descriptionError.value = AppTexts.descriptionRequired;
    } else if (value.trim().length < 10) {
      descriptionError.value = AppTexts.descriptionMinLength;
    } else {
      descriptionError.value = null;
    }
  }

  void validateExpiry() {
    if (!hasNoExpiry && expiryController.text.trim().isEmpty) {
      expiryError.value = 'Please select an expiry date or check "No Expiry"';
    } else if (!hasNoExpiry && expiryController.text.trim().isNotEmpty) {
      // Validate that expiry date is not in the past
      try {
        final format = DateFormat('MM/yyyy');
        final expiryDate = format.parse(expiryController.text.trim());
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month);
        final selectedMonth = DateTime(expiryDate.year, expiryDate.month);

        if (selectedMonth.isBefore(currentMonth)) {
          expiryError.value = 'Expiry date cannot be in the past';
        } else {
          expiryError.value = null;
        }
      } catch (e) {
        // Invalid date format - will be caught by other validation
        expiryError.value = null;
      }
    } else {
      expiryError.value = null;
    }
  }

  bool _validateForm() {
    // Validate all fields
    validateTitle(titleController.text);
    validateDescription(descriptionController.text);
    validateExpiry();

    final controller = Get.find<DocumentsController>();

    if (selectedDocTypeId.value == null || selectedDocTypeId.value!.isEmpty) {
      AppSnackbar.error('Please select a document type');
      return false;
    }

    if (titleError.value != null ||
        descriptionError.value != null ||
        expiryError.value != null) {
      return false;
    }

    if (controller.selectedFile.value == null) {
      AppSnackbar.error(AppTexts.documentFileRequired);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();

    return AppCandidateLayout(
      title: AppTexts.addNewDocument,
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
                    final documentTypes = controller.documentTypes.toList();
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
                    expiryController: expiryController,
                    hasNoExpiry: hasNoExpiry,
                    onTitleChanged: (value) {
                      validateTitle(value);
                    },
                    onDescriptionChanged: (value) {
                      validateDescription(value);
                    },
                    onExpiryChanged: () {
                      validateExpiry();
                    },
                    titleError: titleError,
                    descriptionError: descriptionError,
                    expiryError: expiryError,
                    onNoExpiryChanged: (value) {
                      setState(() {
                        hasNoExpiry = value;
                        if (value) {
                          expiryController.clear();
                        }
                        validateExpiry();
                      });
                    },
                  ),
                  AppSpacing.vertical(context, 0.03),
                  AppDocumentUploadWidget(controller: controller),
                  AppSpacing.vertical(context, 0.03),
                  Obx(() {
                    final hasFile = controller.selectedFile.value != null;
                    final hasDocType =
                        selectedDocTypeId.value != null &&
                        selectedDocTypeId.value!.isNotEmpty;
                    final hasExpiry =
                        hasNoExpiry || expiryController.text.trim().isNotEmpty;
                    final hasNoErrors =
                        titleError.value == null &&
                        descriptionError.value == null &&
                        expiryError.value == null;
                    final canCreate =
                        hasDocType &&
                        hasFile &&
                        descriptionController.text.trim().isNotEmpty &&
                        hasExpiry &&
                        hasNoErrors;

                    return AppButton(
                      text: AppTexts.create,
                      icon: Iconsax.add,
                      onPressed: canCreate && !controller.isLoading.value
                          ? () {
                              if (_validateForm()) {
                                // Parse expiry date if provided
                                DateTime? expiryDate;
                                if (!hasNoExpiry &&
                                    expiryController.text.isNotEmpty) {
                                  try {
                                    final format = DateFormat('MM/yyyy');
                                    expiryDate = format.parse(
                                      expiryController.text,
                                    );
                                  } catch (e) {
                                    AppSnackbar.error(
                                      'Invalid expiry date format. Please use MM/YYYY',
                                    );
                                    return;
                                  }
                                }

                                String resolvedName = titleController.text
                                    .trim();
                                if (resolvedName.isEmpty) {
                                  try {
                                    final dt = controller.documentTypes
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

                                controller.uploadDocumentWithSelectedFile(
                                  docTypeId: selectedDocTypeId.value!,
                                  docTypeName: resolvedName,
                                  expiryDate: expiryDate,
                                  hasNoExpiry: hasNoExpiry,
                                );
                              }
                            }
                          : null,
                      isLoading: controller.isLoading.value,
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
