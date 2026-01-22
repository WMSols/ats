import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminCreateDocumentTypeScreen extends StatefulWidget {
  const AdminCreateDocumentTypeScreen({super.key});

  @override
  State<AdminCreateDocumentTypeScreen> createState() =>
      _AdminCreateDocumentTypeScreenState();
}

class _AdminCreateDocumentTypeScreenState
    extends State<AdminCreateDocumentTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  final _canSubmit = false.obs;

  // Validation errors
  final titleError = Rxn<String>();
  final descriptionError = Rxn<String>();

  bool get canSubmit {
    return titleController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty &&
        titleError.value == null &&
        descriptionError.value == null;
  }

  // Validation methods
  void validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      titleError.value = AppTexts.documentTitleRequired;
    } else if (value.trim().length < 3) {
      titleError.value = AppTexts.documentTitleMinLength;
    } else {
      titleError.value = null;
    }
    _canSubmit.value = canSubmit;
  }

  void validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      descriptionError.value = AppTexts.descriptionRequired;
    } else if (value.trim().length < 10) {
      descriptionError.value = AppTexts.descriptionMinLength;
    } else {
      descriptionError.value = null;
    }
    _canSubmit.value = canSubmit;
  }

  bool _validateForm() {
    // Validate all fields
    validateTitle(titleController.text);
    validateDescription(descriptionController.text);

    if (titleError.value != null || descriptionError.value != null) {
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    _canSubmit.value = canSubmit;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDocumentsController>();

    return AppAdminLayout(
      title: AppTexts.createDocumentType,
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDocumentFormFields(
                titleController: titleController,
                descriptionController: descriptionController,
                onTitleChanged: (value) {
                  validateTitle(value);
                },
                onDescriptionChanged: (value) {
                  validateDescription(value);
                },
                titleError: titleError,
                descriptionError: descriptionError,
              ),
              AppSpacing.vertical(context, 0.03),
              Obx(() {
                final isLoading = controller.isLoading.value;
                return AppButton(
                  text: AppTexts.create,
                  icon: Iconsax.add,
                  onPressed: _canSubmit.value && !isLoading
                      ? () {
                          if (_validateForm()) {
                            controller.createDocumentType(
                              name: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              isRequired: false,
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
    );
  }
}
