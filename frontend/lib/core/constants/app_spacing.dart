import 'package:flutter/widgets.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 14;
  static const double xxl = 16;
  static const double xxxl = 18;
  static const double huge = 20;
  static const double giant = 24;
  static const double radiusSm = 8;
  static const double radiusLg = 20;
}

class AppPadding {
  const AppPadding._();

  static const EdgeInsets allXxl = EdgeInsets.all(AppSpacing.xxl);
  static const EdgeInsets allGiant = EdgeInsets.all(AppSpacing.giant);
  static const EdgeInsets allLg = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets bottomXxl =
      EdgeInsets.only(bottom: AppSpacing.xxl);
  static const EdgeInsets horizontalXxl =
      EdgeInsets.symmetric(horizontal: AppSpacing.xxl);
  static const EdgeInsets horizontalXxlVerticalXxxl =
      EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxxl);
  static const EdgeInsets horizontalXxlVerticalSm =
      EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.sm);
  static const EdgeInsets verticalXxl =
      EdgeInsets.symmetric(vertical: AppSpacing.xxl);
  static const EdgeInsets horizontalMdVerticalXxs =
      EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs);
  static const EdgeInsets topXs = EdgeInsets.only(top: AppSpacing.xs);
  static const EdgeInsets zero = EdgeInsets.zero;
}
