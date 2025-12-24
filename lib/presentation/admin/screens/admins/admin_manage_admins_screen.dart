import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/presentation/admin/controllers/admin_manage_admins_controller.dart';

class AdminManageAdminsScreen extends StatelessWidget {
  const AdminManageAdminsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminManageAdminsController>();

    return AppAdminLayout(
      title: AppTexts.manageAdmins,
      child: SingleChildScrollView(
        padding: AppSpacing.all(context, factor: 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Admin or Recruiter',
              style: AppTextStyles.heading(context),
            ),
            SizedBox(height: AppResponsive.screenHeight(context) * 0.02),
            Padding(
              padding: AppSpacing.all(context, factor: 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: controller.nameController,
                    labelText: 'Full Name',
                    prefixIcon: Iconsax.user,
                    onChanged: (value) {
                      controller.validateName(value);
                    },
                  ),
                  Obx(
                    () => controller.nameError.value != null
                        ? Padding(
                            padding: EdgeInsets.only(
                              top: AppResponsive.screenHeight(context) * 0.01,
                            ),
                            child: AppErrorMessage(
                              message: controller.nameError.value!,
                              icon: Iconsax.info_circle,
                              messageColor: AppColors.error,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: AppResponsive.screenHeight(context) * 0.02),
                  AppTextField(
                    controller: controller.emailController,
                    labelText: AppTexts.email,
                    prefixIcon: Iconsax.sms,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      controller.validateEmail(value);
                    },
                  ),
                  Obx(
                    () => controller.emailError.value != null
                        ? Padding(
                            padding: EdgeInsets.only(
                              top: AppResponsive.screenHeight(context) * 0.01,
                            ),
                            child: AppErrorMessage(
                              message: controller.emailError.value!,
                              icon: Iconsax.info_circle,
                              messageColor: AppColors.error,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: AppResponsive.screenHeight(context) * 0.02),
                  AppTextField(
                    controller: controller.passwordController,
                    labelText: AppTexts.password,
                    prefixIcon: Iconsax.lock,
                    obscureText: true,
                    onChanged: (value) {
                      controller.validatePassword(value);
                    },
                  ),
                  Obx(
                    () => controller.passwordError.value != null
                        ? Padding(
                            padding: EdgeInsets.only(
                              top: AppResponsive.screenHeight(context) * 0.01,
                            ),
                            child: AppErrorMessage(
                              message: controller.passwordError.value!,
                              icon: Iconsax.info_circle,
                              messageColor: AppColors.error,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: AppResponsive.screenHeight(context) * 0.02),
                  DropdownButtonFormField<String>(
                    value: controller.roleValue.value,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(
                        Iconsax.user_tag,
                        size: AppResponsive.iconSize(context),
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppResponsive.radius(context, factor: 5),
                        ),
                        borderSide: BorderSide(
                          color: AppColors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppResponsive.radius(context, factor: 5),
                        ),
                        borderSide: BorderSide(
                          color: AppColors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppResponsive.radius(context, factor: 5),
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: AppSpacing.symmetric(
                        context,
                        h: 0.04,
                        v: 0.02,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                        value: 'recruiter',
                        child: Text('Recruiter'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setRole(value);
                      }
                    },
                  ),
                  Obx(
                    () => controller.roleError.value != null
                        ? Padding(
                            padding: EdgeInsets.only(
                              top: AppResponsive.screenHeight(context) * 0.01,
                            ),
                            child: AppErrorMessage(
                              message: controller.roleError.value!,
                              icon: Iconsax.info_circle,
                              messageColor: AppColors.error,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: AppResponsive.screenHeight(context) * 0.03),
                  Obx(
                    () => controller.errorMessage.value.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  AppResponsive.screenHeight(context) * 0.02,
                            ),
                            child: AppErrorMessage(
                              message: controller.errorMessage.value,
                              icon: Iconsax.info_circle,
                              messageColor: AppColors.error,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => AppButton(
                      text:
                          'Create ${controller.roleValue.value == 'admin' ? 'Admin' : 'Recruiter'}',
                      onPressed: controller.createAdmin,
                      isLoading: controller.isLoading.value,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
