import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:dartz/dartz.dart';

class SendDocumentRequestReminderEmailUseCase {
  final EmailRepository repository;

  SendDocumentRequestReminderEmailUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String candidateEmail,
    required String candidateName,
    required List<Map<String, String>> documents,
  }) {
    return repository.sendDocumentRequestReminderEmail(
      candidateEmail: candidateEmail,
      candidateName: candidateName,
      documents: documents,
    );
  }
}
