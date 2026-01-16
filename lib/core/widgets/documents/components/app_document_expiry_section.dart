import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

/// Reusable widget for document expiry section with "No Expiry" checkbox
/// Works in real-time similar to AdminJobEditScreen document selection
class AppDocumentExpirySection extends StatefulWidget {
  final TextEditingController expiryController;
  final bool hasNoExpiry;
  final void Function(bool) onNoExpiryChanged;
  final void Function()? onExpiryChanged;
  final Rxn<String>? expiryError;

  const AppDocumentExpirySection({
    super.key,
    required this.expiryController,
    required this.hasNoExpiry,
    required this.onNoExpiryChanged,
    this.onExpiryChanged,
    this.expiryError,
  });

  @override
  State<AppDocumentExpirySection> createState() =>
      _AppDocumentExpirySectionState();
}

class _AppDocumentExpirySectionState extends State<AppDocumentExpirySection> {
  // Maintain local state for immediate UI updates, similar to AdminJobEditScreen pattern
  // This ensures the checkbox updates in real-time before parent rebuilds
  bool _localHasNoExpiry = false;
  bool _isInitialized = false;

  @override
  void didUpdateWidget(AppDocumentExpirySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync local state with widget prop when parent updates it
    if (oldWidget.hasNoExpiry != widget.hasNoExpiry) {
      _localHasNoExpiry = widget.hasNoExpiry;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize local state on first build
    if (!_isInitialized) {
      _localHasNoExpiry = widget.hasNoExpiry;
      _isInitialized = true;
    }

    // Use ValueKey with local state to force rebuild when it changes
    // Similar to AdminJobEditScreen pattern with version counter
    return StatefulBuilder(
      key: ValueKey('expiry_section_$_localHasNoExpiry'),
      builder: (context, setStateBuilder) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // No Expiry Checkbox
            Row(
              children: [
                Checkbox(
                  // Use ValueKey with local state to force rebuild when it changes
                  // Same pattern as AppDocumentSelector
                  key: ValueKey('no_expiry_checkbox_$_localHasNoExpiry'),
                  value: _localHasNoExpiry,
                  onChanged: (value) {
                    final newValue = value ?? false;
                    // Update local state immediately for real-time UI update
                    _localHasNoExpiry = newValue;
                    // Trigger StatefulBuilder rebuild
                    setStateBuilder(() {});
                    // Call the callback to update parent state
                    // Parent will call setState which will sync back via didUpdateWidget
                    widget.onNoExpiryChanged(newValue);
                    // Clear expiry controller if "No Expiry" is checked
                    if (newValue) {
                      widget.expiryController.clear();
                    }
                    // Trigger expiry validation
                    widget.onExpiryChanged?.call();
                    // Also trigger parent widget rebuild if mounted
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
                Text('No Expiry'),
              ],
            ),
            // Expiry Date Picker (only shown if "No Expiry" is not checked)
            if (!_localHasNoExpiry) ...[
              AppSpacing.vertical(context, 0.01),
              AppDatePicker(
                controller: widget.expiryController,
                labelText: AppTexts.expiry,
                showLabelAbove: true,
                hintText: 'MM/YYYY',
                monthYearOnly: true,
                onChanged: (value) {
                  // Trigger expiry validation when date is selected
                  widget.onExpiryChanged?.call();
                },
              ),
            ],
            // Expiry Error Message
            if (widget.expiryError != null)
              Obx(
                () => widget.expiryError!.value != null
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: AppSpacing.vertical(context, 0.01).height!,
                        ),
                        child: AppErrorMessage(
                          message: widget.expiryError!.value!,
                          icon: Iconsax.info_circle,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        );
      },
    );
  }
}
