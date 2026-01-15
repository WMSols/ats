import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:dartz/dartz.dart';

class SendDocumentRequestEmailUseCase {
  final EmailRepository repository;

  SendDocumentRequestEmailUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    required String documentDescription,
  }) {
    return repository.sendDocumentRequestEmail(
      candidateEmail: candidateEmail,
      candidateName: candidateName,
      documentName: documentName,
      documentDescription: documentDescription,
    );
  }
}
