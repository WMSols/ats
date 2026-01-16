import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:dartz/dartz.dart';

class SendDocumentRequestRevocationEmailUseCase {
  final EmailRepository repository;

  SendDocumentRequestRevocationEmailUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
  }) {
    return repository.sendDocumentRequestRevocationEmail(
      candidateEmail: candidateEmail,
      candidateName: candidateName,
      documentName: documentName,
    );
  }
}
