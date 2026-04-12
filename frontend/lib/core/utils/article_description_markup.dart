enum ArticleDescriptionSegmentKind { paragraph, subtitle, bullet }

final class ArticleDescriptionSegment {
  const ArticleDescriptionSegment({
    required this.kind,
    required this.text,
  });

  final ArticleDescriptionSegmentKind kind;
  final String text;
}

final class ArticleDescriptionMarkup {
  ArticleDescriptionMarkup._();

  static List<ArticleDescriptionSegment> parse(String raw) {
    final normalized = raw.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) return const [];

    final lines = normalized.split('\n');
    final out = <ArticleDescriptionSegment>[];

    for (final line in lines) {
      final trimmedRight = line.trimRight();
      final content = trimmedRight.trimLeft();
      if (content.isEmpty) {
        continue;
      }
      if (content.startsWith('##')) {
        final title = content.substring(2).trimLeft();
        if (title.isNotEmpty) {
          out.add(ArticleDescriptionSegment(
            kind: ArticleDescriptionSegmentKind.subtitle,
            text: title,
          ));
        }
        continue;
      }
      if (content.startsWith('- ') || content.startsWith('* ')) {
        final item = content.substring(2).trim();
        if (item.isNotEmpty) {
          out.add(ArticleDescriptionSegment(
            kind: ArticleDescriptionSegmentKind.bullet,
            text: item,
          ));
        }
        continue;
      }
      out.add(ArticleDescriptionSegment(
        kind: ArticleDescriptionSegmentKind.paragraph,
        text: content,
      ));
    }
    return out;
  }

  static String plainPreview(String raw) {
    final segments = parse(raw);
    if (segments.isEmpty) return '';

    final parts = <String>[];
    for (final s in segments) {
      switch (s.kind) {
        case ArticleDescriptionSegmentKind.subtitle:
          parts.add(s.text);
        case ArticleDescriptionSegmentKind.bullet:
          parts.add('• ${s.text}');
        case ArticleDescriptionSegmentKind.paragraph:
          parts.add(s.text);
      }
    }
    return parts.join(' ');
  }
}
