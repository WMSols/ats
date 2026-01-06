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

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
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
              ),
              AppSpacing.vertical(context, 0.03),
              Obx(
                () => AppButton(
                  text: AppTexts.create,
                  icon: Iconsax.add,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.createDocumentType(
                        name: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        isRequired: false,
                      );
                    }
                  },
                  isLoading: controller.isLoading.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
