import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:dartz/dartz.dart';

class SendCandidateDocumentUploadEmailUseCase {
  final EmailRepository repository;

  SendCandidateDocumentUploadEmailUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String documentName,
    String? documentTypeName,
  }) {
    return repository.sendCandidateDocumentUploadEmail(
      documentName: documentName,
      documentTypeName: documentTypeName,
    );
  }
}
