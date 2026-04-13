import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/utils/date_formatter.dart';

void main() {
  group('AppDateFormatter', () {
    setUpAll(() async {
      await initializeDateFormatting(articleDisplayLocale);
    });

    test('formats News API UTC publishedAt in US Eastern', () {
      expect(
        AppDateFormatter.formatFromIsoString(
          '2024-06-15T12:00:00.000Z',
        ),
        '06/15/2024 08:00 AM',
      );
    });

    test('uses EST offset in winter for UTC instant', () {
      expect(
        AppDateFormatter.formatFromIsoString(
          '2024-01-15T12:00:00.000Z',
        ),
        '01/15/2024 07:00 AM',
      );
    });
  });
}
