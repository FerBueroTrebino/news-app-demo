import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:news_app_clean_architecture/core/utils/date_formatter.dart';

void main() {
  group('AppDateFormatter', () {
    setUpAll(() async {
      await initializeDateFormatting('es');
    });

    test('formats News API UTC publishedAt in Europe/Madrid', () {
      expect(
        AppDateFormatter.formatFromIsoString(
          '2024-06-15T12:00:00.000Z',
        ),
        '15/06/2024 14:00',
      );
    });

    test('uses CET offset in winter for UTC instant', () {
      expect(
        AppDateFormatter.formatFromIsoString(
          '2024-01-15T12:00:00.000Z',
        ),
        '15/01/2024 13:00',
      );
    });
  });
}
