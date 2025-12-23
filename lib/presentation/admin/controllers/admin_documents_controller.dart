import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/entities/document_type_entity.dart';

class AdminDocumentsController extends GetxController {
  final DocumentRepository documentRepository;

  AdminDocumentsController(this.documentRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final documentTypes = <DocumentTypeEntity>[].obs;

  // Stream subscription
  StreamSubscription<List<DocumentTypeEntity>>? _documentTypesSubscription;

  @override
  void onInit() {
    super.onInit();
    loadDocumentTypes();
  }

  @override
  void onClose() {
    // Cancel stream subscription to prevent permission errors after sign-out
    _documentTypesSubscription?.cancel();
    super.onClose();
  }

  void loadDocumentTypes() {
    _documentTypesSubscription?.cancel(); // Cancel previous subscription if exists
    _documentTypesSubscription = documentRepository.streamDocumentTypes().listen(
      (types) {
        documentTypes.value = types;
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );
  }

  Future<void> createDocumentType({
    required String name,
    required String description,
    required bool isRequired,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await documentRepository.createDocumentType(
      name: name,
      description: description,
      isRequired: isRequired,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (docType) {
        isLoading.value = false;
        Get.snackbar('Success', 'Document type created successfully');
        Get.back();
      },
    );
  }

  Future<void> updateDocumentType({
    required String docTypeId,
    String? name,
    String? description,
    bool? isRequired,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await documentRepository.updateDocumentType(
      docTypeId: docTypeId,
      name: name,
      description: description,
      isRequired: isRequired,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (docType) {
        isLoading.value = false;
        Get.snackbar('Success', 'Document type updated successfully');
        Get.back();
      },
    );
  }

  Future<void> deleteDocumentType(String docTypeId) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await documentRepository.deleteDocumentType(docTypeId);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (_) {
        isLoading.value = false;
        Get.snackbar('Success', 'Document type deleted successfully');
      },
    );
  }
}

