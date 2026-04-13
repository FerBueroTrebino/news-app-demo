import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../constants/constants.dart';

class AppDateFormatter {
  const AppDateFormatter();

  static bool _timeZonesInitialized = false;
  static tz.Location? _usDisplayLocation;

  static void _ensureUsDisplayTimeZone() {
    if (_timeZonesInitialized) return;
    tzdata.initializeTimeZones();
    _usDisplayLocation = tz.getLocation(articleDisplayTimeZone);
    _timeZonesInitialized = true;
  }

  static String formatFromIsoString(
    String? value, {
    String pattern = articleDisplayDatePattern,
    String locale = articleDisplayLocale,
    String fallback = '',
  }) {
    if (value == null || value.isEmpty) {
      return fallback;
    }

    try {
      _ensureUsDisplayTimeZone();
      final instant = DateTime.parse(value);
      final inUs = tz.TZDateTime.from(instant, _usDisplayLocation!);
      final usWall = DateTime(
        inUs.year,
        inUs.month,
        inUs.day,
        inUs.hour,
        inUs.minute,
        inUs.second,
        inUs.millisecond,
        inUs.microsecond,
      );
      return DateFormat(pattern, locale).format(usWall);
    } catch (_) {
      return _normalizeRawDateTime(value);
    }
  }

  static String _normalizeRawDateTime(String value) {
    final trimmed = value.trim();
    final withoutZulu = trimmed.endsWith('Z')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final withSpace = withoutZulu.replaceFirst('T', ' ');
    final parts = withSpace.split(' ');

    if (parts.length < 2) {
      return _normalizeDatePartUs(parts.first);
    }

    final datePart = _normalizeDatePartUs(parts.first);
    final timePart = parts[1];
    final timeSegments = timePart.split(':');

    if (timeSegments.length >= 2) {
      final hours = timeSegments[0];
      final minutes = timeSegments[1].split('.').first;
      return '$datePart $hours:$minutes';
    }
    if (timeSegments.isNotEmpty) {
      return '$datePart ${timeSegments[0]}:00';
    }

    return withSpace;
  }

  static String _normalizeDatePartUs(String value) {
    final dateSegments = value.split('-');
    if (dateSegments.length == 3) {
      final year = dateSegments[0];
      final month = int.tryParse(dateSegments[1]) ?? 1;
      final day = int.tryParse(dateSegments[2]) ?? 1;
      final mm = month.toString().padLeft(2, '0');
      final dd = day.toString().padLeft(2, '0');
      return '$mm/$dd/$year';
    }
    return value;
  }
}
