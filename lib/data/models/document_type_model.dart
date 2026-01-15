import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentTypeModel extends DocumentTypeEntity {
  DocumentTypeModel({
    required super.docTypeId,
    required super.name,
    required super.description,
    required super.isRequired,
    super.isCandidateSpecific,
    super.requestedForCandidateId,
    super.requestedAt,
  });

  factory DocumentTypeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentTypeModel(
      docTypeId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      isRequired: data['isRequired'] ?? false,
      isCandidateSpecific: data['isCandidateSpecific'] ?? false,
      requestedForCandidateId: data['requestedForCandidateId'] as String?,
      requestedAt: (data['requestedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'isRequired': isRequired,
      'isCandidateSpecific': isCandidateSpecific,
      if (requestedForCandidateId != null)
        'requestedForCandidateId': requestedForCandidateId,
      if (requestedAt != null) 'requestedAt': Timestamp.fromDate(requestedAt!),
    };
  }

  DocumentTypeEntity toEntity() {
    return DocumentTypeEntity(
      docTypeId: docTypeId,
      name: name,
      description: description,
      isRequired: isRequired,
      isCandidateSpecific: isCandidateSpecific,
      requestedForCandidateId: requestedForCandidateId,
      requestedAt: requestedAt,
    );
  }
}
