import 'package:ats/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class EmailRepository {
  /// Sends a document denial email to a candidate
  Future<Either<Failure, void>> sendDocumentDenialEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    String? denialReason,
  });

  /// Sends a document request email to a candidate
  Future<Either<Failure, void>> sendDocumentRequestEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    required String documentDescription,
  });

  /// Sends a document request revocation email to a candidate
  Future<Either<Failure, void>> sendDocumentRequestRevocationEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
  });
}
