import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/utils/article_description_markup.dart';

void main() {
  group('ArticleDescriptionMarkup', () {
    test('parse recognizes subtitles and bullets', () {
      const raw = '''
Intro line
## Key points
- First item
- Second item
Closing thought''';

      final segments = ArticleDescriptionMarkup.parse(raw);

      expect(segments.length, 5);
      expect(segments[0].kind, ArticleDescriptionSegmentKind.paragraph);
      expect(segments[0].text, 'Intro line');
      expect(segments[1].kind, ArticleDescriptionSegmentKind.subtitle);
      expect(segments[1].text, 'Key points');
      expect(segments[2].kind, ArticleDescriptionSegmentKind.bullet);
      expect(segments[2].text, 'First item');
      expect(segments[3].kind, ArticleDescriptionSegmentKind.bullet);
      expect(segments[3].text, 'Second item');
      expect(segments[4].kind, ArticleDescriptionSegmentKind.paragraph);
      expect(segments[4].text, 'Closing thought');
    });

    test('parse accepts * as bullet marker', () {
      final segments = ArticleDescriptionMarkup.parse('* Star bullet');
      expect(segments.length, 1);
      expect(segments.single.kind, ArticleDescriptionSegmentKind.bullet);
      expect(segments.single.text, 'Star bullet');
    });

    test('plainPreview flattens structure for tiles', () {
      const raw = '## Title\n- One\n- Two';
      expect(
        ArticleDescriptionMarkup.plainPreview(raw),
        'Title • One • Two',
      );
    });

    test('plainPreview returns empty for blank input', () {
      expect(ArticleDescriptionMarkup.plainPreview('   '), '');
    });
  });
}
