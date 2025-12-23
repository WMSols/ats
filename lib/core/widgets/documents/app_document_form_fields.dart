import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AppDocumentFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const AppDocumentFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: titleController,
          labelText: AppTexts.documentTitle,
          prefixIcon: Iconsax.document_text,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppTexts.documentTitleRequired;
            }
            if (value.trim().length < 3) {
              return AppTexts.documentTitleMinLength;
            }
            return null;
          },
        ),
        AppSpacing.vertical(context, 0.02),
        AppTextField(
          controller: descriptionController,
          labelText: AppTexts.description,
          prefixIcon: Iconsax.document_text_1,
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
      ],
    );
  }
}

