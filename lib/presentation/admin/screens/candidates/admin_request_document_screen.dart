import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

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
  final _canSubmit = false.obs;

  bool get canSubmit {
    return titleController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty;
  }

  void _onTextChanged() {
    _canSubmit.value = canSubmit;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    titleController.addListener(_onTextChanged);
    descriptionController.addListener(_onTextChanged);
    _canSubmit.value = canSubmit;
  }

  @override
  void dispose() {
    titleController.removeListener(_onTextChanged);
    descriptionController.removeListener(_onTextChanged);
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCandidatesController>();

    return AppAdminLayout(
      title: AppTexts.requestDocument,
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
              ),
              AppSpacing.vertical(context, 0.03),
              Obx(
                () {
                  final isLoading = controller.isLoading.value;
                  return AppButton(
                    text: AppTexts.create,
                    icon: Iconsax.add,
                    onPressed: _canSubmit.value && !isLoading
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              controller.requestDocumentForCandidate(
                                name: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                              );
                            }
                          }
                        : null,
                    isLoading: isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
