import 'package:flutter/material.dart';

enum AppSnackBarType { error, success, message }

SnackBar buildSnackBar(
  String message, {
  AppSnackBarType type = AppSnackBarType.message,
}) {
  final backgroundColor = switch (type) {
    AppSnackBarType.error => Colors.red,
    AppSnackBarType.success => Colors.green,
    AppSnackBarType.message => Colors.blueGrey,
  };

  return SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.white, fontSize: 18),
    ),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    backgroundColor: backgroundColor,
  );
}
