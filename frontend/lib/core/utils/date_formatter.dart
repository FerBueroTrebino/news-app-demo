import 'package:intl/intl.dart';

class AppDateFormatter {
  const AppDateFormatter();

  static String formatFromIsoString(
    String? value, {
    String pattern = 'dd/MM/yyyy',
    String locale = 'es',
    String fallback = '',
  }) {
    if (value == null || value.isEmpty) {
      return fallback;
    }

    try {
      final dateTime = DateTime.parse(value);
      return DateFormat(pattern, locale).format(dateTime);
    } catch (_) {
      // Normalize raw ISO-like strings to avoid leaking "T" and trailing "Z".
      return _normalizeRawDateTime(value);
    }
  }

  static String _normalizeRawDateTime(String value) {
    final trimmed = value.trim();
    final withoutZulu =
        trimmed.endsWith('Z') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
    final withSpace = withoutZulu.replaceFirst('T', ' ');
    final parts = withSpace.split(' ');

    if (parts.length < 2) {
      return _normalizeDatePart(withSpace);
    }

    final datePart = _normalizeDatePart(parts.first);
    final timePart = parts[1];
    final timeSegments = timePart.split(':');

    if (timeSegments.length >= 2) {
      final hours = timeSegments[0];
      final minutes = timeSegments[1];
      return '$datePart $hours:$minutes';
    }

    return withSpace;
  }

  static String _normalizeDatePart(String value) {
    final dateSegments = value.split('-');
    if (dateSegments.length == 3) {
      final year = dateSegments[0];
      final month = dateSegments[1];
      final day = dateSegments[2];
      return '$day/$month/$year';
    }
    return value;
  }
}
