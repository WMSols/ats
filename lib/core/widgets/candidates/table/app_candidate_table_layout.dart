/// Fixed column widths so all columns remain visible with horizontal scroll.
class AppCandidateTableLayout {
  AppCandidateTableLayout._();

  static const double name = 150;
  static const double email = 240;
  static const double company = 160;
  static const double position = 160;
  static const double profession = 180;
  static const double specialties = 220;
  static const double status = 140;
  static const double agent = 200;
  static const double actions = 120;

  static const double columnSpacing = 20;
  static const double horizontalPadding = 32;

  /// Total table width for horizontal scrolling (includes Actions when shown).
  static double tableWidth({required bool includeActions}) {
    var width = name +
        email +
        company +
        position +
        profession +
        specialties +
        status +
        agent +
        horizontalPadding;
    if (includeActions) {
      width += actions;
    }
    const columnCountWithActions = 9;
    final columnCount = includeActions ? columnCountWithActions : 8;
    width += (columnCount - 1) * columnSpacing;
    return width;
  }
}
