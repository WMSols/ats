class DocumentTypeEntity {
  final String docTypeId;
  final String name;
  final String description;
  final bool isRequired;
  final bool isCandidateSpecific;
  final String? requestedForCandidateId;
  final DateTime? requestedAt;

  DocumentTypeEntity({
    required this.docTypeId,
    required this.name,
    required this.description,
    required this.isRequired,
    this.isCandidateSpecific = false,
    this.requestedForCandidateId,
    this.requestedAt,
  });
}
