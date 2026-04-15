import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

enum AppSnackBarType { error, success, alert, message }

SnackBar buildSnackBar(
  BuildContext context,
  String message, {
  AppSnackBarType type = AppSnackBarType.message,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final backgroundColor = switch (type) {
    AppSnackBarType.error => colorScheme.error,
    AppSnackBarType.success => colorScheme.primary,
    AppSnackBarType.alert => colorScheme.tertiary,
    AppSnackBarType.message => colorScheme.secondaryContainer,
  };

  return SnackBar(
    content: Text(
      message,
    ),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(
      AppSpacing.xxl,
      0,
      AppSpacing.xxl,
      AppSpacing.xxl,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.lg),
    ),
    backgroundColor: backgroundColor,
  );
}
