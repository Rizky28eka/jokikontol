import 'package:flutter/widgets.dart';

class ResponsiveBreakpoints {
  static const double compact = 480;
  static const double medium = 800;
  static const double expanded = 1200;
}

class Responsive {
  final BoxConstraints constraints;
  Responsive(this.constraints);

  double get width => constraints.maxWidth;
  bool get isCompact => width < ResponsiveBreakpoints.compact;
  bool get isMedium => width >= ResponsiveBreakpoints.compact && width < ResponsiveBreakpoints.medium;
  bool get isWide => width >= ResponsiveBreakpoints.medium && width < ResponsiveBreakpoints.expanded;
  bool get isExpanded => width >= ResponsiveBreakpoints.expanded;

  int gridColumnCount({int compact = 1, int medium = 2, int wide = 3, int expanded = 4}) {
    if (isExpanded) return expanded;
    if (isWide) return wide;
    if (isMedium) return medium;
    return compact;
  }
}
