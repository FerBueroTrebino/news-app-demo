import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class AppDateFormatter {
  const AppDateFormatter();

  static bool _timeZonesInitialized = false;
  static tz.Location? _madrid;

  static void _ensureSpainTimeZone() {
    if (_timeZonesInitialized) return;
    tzdata.initializeTimeZones();
    _madrid = tz.getLocation('Europe/Madrid');
    _timeZonesInitialized = true;
  }

  static String formatFromIsoString(
    String? value, {
    String pattern = 'dd/MM/yyyy HH:mm',
    String locale = 'es',
    String fallback = '',
  }) {
    if (value == null || value.isEmpty) {
      return fallback;
    }

    try {
      _ensureSpainTimeZone();
      final instant = DateTime.parse(value);
      final inMadrid = tz.TZDateTime.from(instant, _madrid!);
      // Plain DateTime so intl reads calendar fields directly (Madrid wall time).
      final madridWall = DateTime(
        inMadrid.year,
        inMadrid.month,
        inMadrid.day,
        inMadrid.hour,
        inMadrid.minute,
        inMadrid.second,
        inMadrid.millisecond,
        inMadrid.microsecond,
      );
      return DateFormat(pattern, locale).format(madridWall);
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
    if (timeSegments.isNotEmpty) {
      return '$datePart ${timeSegments[0]}:00';
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
