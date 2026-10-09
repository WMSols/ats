import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/constants/profile_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';

class AppCandidateTableFormatters {
  AppCandidateTableFormatters._();

  /// Formats the status string to display text
  static String formatStatus(String status) {
    switch (status) {
      case AppConstants.documentStatusApproved:
        return AppTexts.approved;
      case AppConstants.documentStatusDenied:
        return AppTexts.denied;
      case AppConstants.documentStatusPending:
      default:
        return AppTexts.pending;
    }
  }

  /// Gets the color for a status value
  static Color getStatusColor(String status) {
    switch (status) {
      case AppConstants.documentStatusApproved:
        return AppColors.success;
      case AppConstants.documentStatusDenied:
        return AppColors.error;
      case AppConstants.documentStatusPending:
      default:
        return AppColors.warning;
    }
  }

  /// Formats specialties using canonical labels (merges aliases / casing).
  static String formatSpecialties(String specialties) {
    return ProfileConstants.formatSpecialtiesCanonical(specialties);
  }

  /// Formats expiry status for a document
  /// Returns "No Expiry" if hasNoExpiry is true, otherwise "Expiry: MM/yyyy"
  static String? formatExpiryStatus(CandidateDocumentEntity document) {
    if (document.hasNoExpiry) {
      return 'No Expiry';
    }
    if (document.expiryDate != null) {
      final format = DateFormat('MM/yyyy');
      return 'Expiry: ${format.format(document.expiryDate!)}';
    }
    return null;
  }
}
