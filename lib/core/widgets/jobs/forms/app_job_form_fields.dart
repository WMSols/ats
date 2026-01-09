import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AppJobFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController requirementsController;

  const AppJobFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.requirementsController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: titleController,
          labelText: AppTexts.jobTitle,
          prefixIcon: Iconsax.briefcase,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppTexts.jobTitleRequired;
            }
            if (value.trim().length < 3) {
              return AppTexts.jobTitleMinLength;
            }
            return null;
          },
        ),
        AppSpacing.vertical(context, 0.02),
        AppTextField(
          controller: descriptionController,
          labelText: AppTexts.description,
          prefixIcon: Iconsax.document_text,
          maxLines: 5,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppTexts.descriptionRequired;
            }
            if (value.trim().length < 10) {
              return AppTexts.descriptionMinLength;
            }
            return null;
          },
        ),
        AppSpacing.vertical(context, 0.02),
        AppTextField(
          controller: requirementsController,
          labelText: AppTexts.requirements,
          prefixIcon: Iconsax.tick_circle,
          maxLines: 5,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppTexts.requirementsRequired;
            }
            return null;
          },
        ),
      ],
    );
  }
}
