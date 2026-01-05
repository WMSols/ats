import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/utils/app_validators/app_validators.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/domain/usecases/admin/create_candidate_usecase.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminCreateCandidateController extends GetxController {
  final AdminRepository adminRepository;
  late final CreateCandidateUseCase createCandidateUseCase;

  AdminCreateCandidateController(this.adminRepository) {
    createCandidateUseCase = CreateCandidateUseCase(adminRepository);
  }

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Validation errors
  final firstNameError = Rxn<String>();
  final lastNameError = Rxn<String>();
  final emailError = Rxn<String>();
  final passwordError = Rxn<String>();
  final phoneError = Rxn<String>();
  final addressError = Rxn<String>();

  // Current field values
  final firstNameValue = ''.obs;
  final lastNameValue = ''.obs;
  final emailValue = ''.obs;
  final passwordValue = ''.obs;
  final phoneValue = ''.obs;
  final addressValue = ''.obs;

  // Text controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void validateFirstName(String? value) {
    firstNameValue.value = value ?? '';
    firstNameError.value = AppValidators.validateFirstName(value);
  }

  void validateLastName(String? value) {
    lastNameValue.value = value ?? '';
    lastNameError.value = AppValidators.validateLastName(value);
  }

  void validateEmail(String? value) {
    emailValue.value = value ?? '';
    emailError.value = AppValidators.validateEmail(value);
  }

  void validatePassword(String? value) {
    passwordValue.value = value ?? '';
    passwordError.value = AppValidators.validatePassword(value);
  }

  void validatePhone(String? value) {
    phoneValue.value = value ?? '';
    phoneError.value = AppValidators.validatePhone(value);
  }

  void validateAddress(String? value) {
    addressValue.value = value ?? '';
    addressError.value = AppValidators.validateAddress(value);
  }

  bool validateForm() {
    validateFirstName(firstNameController.text);
    validateLastName(lastNameController.text);
    validateEmail(emailController.text);
    validatePassword(passwordController.text);
    validatePhone(phoneController.text);
    validateAddress(addressController.text);

    return firstNameError.value == null &&
        lastNameError.value == null &&
        emailError.value == null &&
        passwordError.value == null &&
        phoneError.value == null &&
        addressError.value == null;
  }

  Future<void> createCandidate() async {
    if (!validateForm()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await createCandidateUseCase(
      email: emailValue.value.trim(),
      password: passwordValue.value,
      firstName: firstNameValue.value.trim(),
      lastName: lastNameValue.value.trim(),
      phone: phoneValue.value.trim().isNotEmpty ? phoneValue.value.trim() : null,
      address: addressValue.value.trim().isNotEmpty ? addressValue.value.trim() : null,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error(failure.message);
      },
      (candidateProfile) {
        isLoading.value = false;
        errorMessage.value = '';
        // Clear form
        firstNameController.clear();
        lastNameController.clear();
        emailController.clear();
        passwordController.clear();
        phoneController.clear();
        addressController.clear();
        firstNameValue.value = '';
        lastNameValue.value = '';
        emailValue.value = '';
        passwordValue.value = '';
        phoneValue.value = '';
        addressValue.value = '';
        firstNameError.value = null;
        lastNameError.value = null;
        emailError.value = null;
        passwordError.value = null;
        phoneError.value = null;
        addressError.value = null;
        
        AppSnackbar.success('Candidate created successfully');
        // Navigate to AdminCandidatesListScreen
        Get.offNamed(AppConstants.routeAdminCandidates);
        // Refresh the list in candidates screen
        if (Get.isRegistered<AdminCandidatesController>()) {
          final candidatesController = Get.find<AdminCandidatesController>();
          candidatesController.loadCandidates();
        }
      },
    );
  }
}
