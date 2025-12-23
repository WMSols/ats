import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/auth_repository.dart';
import 'package:ats/domain/usecases/auth/sign_up_usecase.dart';
import 'package:ats/domain/usecases/auth/sign_in_usecase.dart';
import 'package:ats/domain/usecases/auth/sign_out_usecase.dart';
import 'package:ats/core/utils/app_validators/app_validators.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController(this.authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Validation errors
  final emailError = Rxn<String>();
  final passwordError = Rxn<String>();
  final firstNameError = Rxn<String>();
  final lastNameError = Rxn<String>();

  // Current field values - updated in real-time as user types
  // This ensures we always have the latest values regardless of controller sync issues
  final emailValue = ''.obs;
  final passwordValue = ''.obs;
  final firstNameValue = ''.obs;
  final lastNameValue = ''.obs;

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  void _clearControllers() {
    try {
      emailController.clear();
      passwordController.clear();
      firstNameController.clear();
      lastNameController.clear();
    } catch (e) {
      // Controllers might already be disposed, ignore
    }
  }

  @override
  void onClose() {
    try {
      emailController.dispose();
      passwordController.dispose();
      firstNameController.dispose();
      lastNameController.dispose();
    } catch (e) {
      // Controllers already disposed, ignore
    }
    super.onClose();
  }

  final signUpUseCase = SignUpUseCase(Get.find<AuthRepository>());
  final signInUseCase = SignInUseCase(Get.find<AuthRepository>());
  final signOutUseCase = SignOutUseCase(Get.find<AuthRepository>());

  @override
  void onInit() {
    super.onInit();
    // Clear all validation errors when controller is initialized
    // This ensures clean state when navigating to login screen
    _clearValidationErrors();
  }

  void resetState() {
    // Clear all validation errors
    _clearValidationErrors();
    // Clear stored values
    emailValue.value = '';
    passwordValue.value = '';
    firstNameValue.value = '';
    lastNameValue.value = '';
    // Clear error message
    errorMessage.value = '';
    // Clear loading state
    isLoading.value = false;
    // Note: Don't clear text controllers here as user might want to keep their input
  }

  void _clearValidationErrors() {
    emailError.value = null;
    passwordError.value = null;
    firstNameError.value = null;
    lastNameError.value = null;
  }


  void validateEmail(String? value) {
    // Update stored value
    emailValue.value = value ?? '';
    // Validate
    emailError.value = AppValidators.validateEmail(value);
  }

  void validatePassword(String? value) {
    // Update stored value
    passwordValue.value = value ?? '';
    // Validate
    passwordError.value = AppValidators.validatePassword(value);
  }

  void validateFirstName(String? value) {
    // Update stored value
    firstNameValue.value = value ?? '';
    // Validate
    firstNameError.value = AppValidators.validateFirstName(value);
  }

  void validateLastName(String? value) {
    // Update stored value
    lastNameValue.value = value ?? '';
    // Validate
    lastNameError.value = AppValidators.validateLastName(value);
  }

  bool validateLoginForm() {
    validateEmail(emailController.text);
    validatePassword(passwordController.text);
    return emailError.value == null && passwordError.value == null;
  }

  bool validateSignUpForm() {
    validateFirstName(firstNameController.text);
    validateLastName(lastNameController.text);
    validateEmail(emailController.text);
    validatePassword(passwordController.text);
    return firstNameError.value == null &&
        lastNameError.value == null &&
        emailError.value == null &&
        passwordError.value == null;
  }

  Future<void> signUp() async {
    if (!validateSignUpForm()) return;

    isLoading.value = true;
    errorMessage.value = '';

    final result = await signUpUseCase(
      email: emailController.text.trim(),
      password: passwordController.text,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      role: AppConstants.roleCandidate,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (user) {
        isLoading.value = false;
        // Redirect based on role
        if (user.role == AppConstants.roleAdmin) {
          Get.offAllNamed(AppConstants.routeAdminDashboard);
        } else {
          Get.offAllNamed(AppConstants.routeCandidateProfile);
        }
      },
    );
  }

  Future<void> signIn() async {
    // Use stored values (updated in real-time via onChanged callbacks)
    // This is more reliable than reading from controllers which may have sync issues
    final email = emailValue.value.trim();
    final password = passwordValue.value;
    
    // Validate form with current values
    // This will set error messages if validation fails
    validateEmail(email);
    validatePassword(password);
    
    // Check if validation passed
    // If either field has an error, stop here and show the errors
    if (emailError.value != null || passwordError.value != null) {
      // Validation failed, don't proceed
      // The errors are already set by validateEmail/validatePassword above
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await signInUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (user) {
        isLoading.value = false;
        errorMessage.value = '';
        // Clear form fields after successful login
        _clearControllers();
        // Clear all validation errors
        emailError.value = null;
        passwordError.value = null;
        // Redirect based on role
        if (user.role == AppConstants.roleAdmin) {
          Get.offAllNamed(AppConstants.routeAdminDashboard);
        } else {
          Get.offAllNamed(AppConstants.routeCandidateDashboard);
        }
      },
    );
  }

  Future<void> signOut() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final result = await signOutUseCase();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (_) {
        isLoading.value = false;
        errorMessage.value = '';
        // Clear all validation errors
        emailError.value = null;
        passwordError.value = null;
        // Clear controllers before navigation
        _clearControllers();
        
        // Delete this controller to force fresh recreation on next login screen access
        // This ensures clean state similar to app restart
        try {
          Get.delete<AuthController>();
        } catch (e) {
          // Controller might already be deleted, ignore
        }
        
        // Use post-frame callback to ensure current widget build cycle completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppConstants.routeLogin);
        });
      },
    );
  }

}

