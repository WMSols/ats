import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/constants/profile_constants.dart';

class SpecialtySection extends StatefulWidget {
  final String? selectedProfession;
  final List<String> selectedSpecialties;
  final void Function(String?)? onProfessionChanged;
  final void Function(List<String> specialties)? onSpecialtiesChanged;
  final Rxn<String>? professionError;
  final Rxn<String>? specialtiesError;
  final bool hasError;

  const SpecialtySection({
    super.key,
    this.selectedProfession,
    required this.selectedSpecialties,
    this.onProfessionChanged,
    this.onSpecialtiesChanged,
    this.professionError,
    this.specialtiesError,
    this.hasError = false,
  });

  @override
  State<SpecialtySection> createState() => _SpecialtySectionState();
}

class _SpecialtySectionState extends State<SpecialtySection> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = _canonicalSet(widget.selectedSpecialties);
  }

  @override
  void didUpdateWidget(covariant SpecialtySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync when parent reloads profile data (not on every identical rebuild)
    final incoming = _canonicalSet(widget.selectedSpecialties);
    if (!_setEquals(incoming, _selected) &&
        !_listEqualsOrderIndependent(
          oldWidget.selectedSpecialties,
          widget.selectedSpecialties,
        )) {
      _selected = incoming;
    }
  }

  Set<String> _canonicalSet(List<String> raw) {
    return raw
        .map(ProfileConstants.canonicalizeSpecialty)
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  bool _listEqualsOrderIndependent(List<String> a, List<String> b) {
    return _setEquals(_canonicalSet(a), _canonicalSet(b));
  }

  void _toggleSpecialty(String specialty) {
    setState(() {
      if (_selected.contains(specialty)) {
        _selected.remove(specialty);
      } else {
        _selected.add(specialty);
      }
    });
    widget.onSpecialtiesChanged?.call(_selected.toList());
  }

  List<DropdownMenuItem<String>> _professionItems() {
    final professions = List<String>.from(ProfileConstants.professions);
    final current = widget.selectedProfession?.trim();
    if (current != null &&
        current.isNotEmpty &&
        !professions.any((p) => p.toLowerCase() == current.toLowerCase())) {
      professions.add(current);
    }
    return professions
        .map(
          (profession) => DropdownMenuItem<String>(
            value: profession,
            child: Text(profession),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppExpandableSection(
      title: AppTexts.specialty,
      hasError: widget.hasError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDropDownField<String>(
            value: widget.selectedProfession,
            labelText: '${AppTexts.profession}(*)',
            showLabelAbove: true,
            hintText: 'Select profession',
            items: _professionItems(),
            onChanged: widget.onProfessionChanged ?? (value) {},
          ),
          if (widget.professionError != null)
            Obx(
              () => widget.professionError!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: widget.professionError!.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          AppSpacing.vertical(context, 0.02),
          AppRequiredLabel(text: AppTexts.specialties),
          AppSpacing.vertical(context, 0.01),
          Text(
            'Select one or more specialties',
            style: AppTextStyles.hintText(context),
          ),
          AppSpacing.vertical(context, 0.01),
          Wrap(
            spacing: AppResponsive.screenWidth(context) * 0.01,
            runSpacing: AppResponsive.screenHeight(context) * 0.008,
            children: ProfileConstants.specialties.map((specialty) {
              final isSelected = _selected.contains(specialty);
              return FilterChip(
                key: ValueKey('specialty-chip-$specialty'),
                label: Text(
                  specialty,
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontSize:
                        (AppTextStyles.bodyText(context).fontSize ?? 14) * 0.9,
                    color: isSelected ? AppColors.white : AppColors.primary,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => _toggleSpecialty(specialty),
                selectedColor: AppColors.primary,
                checkmarkColor: AppColors.white,
                backgroundColor: AppColors.white,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              );
            }).toList(),
          ),
          if (widget.specialtiesError != null)
            Obx(
              () => widget.specialtiesError!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: widget.specialtiesError!.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
