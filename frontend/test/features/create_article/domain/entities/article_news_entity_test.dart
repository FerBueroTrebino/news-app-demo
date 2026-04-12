import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';

void main() {
  final created = DateTime.utc(2026, 1, 1);
  final updated = DateTime.utc(2026, 1, 2);

  ArticleNewsEntity build({
    String thumbnailUrl = 'https://thumb',
    String articleUid = 'a1',
  }) {
    return ArticleNewsEntity(
      articleUid: articleUid,
      title: 'T',
      description: 'D',
      content: 'C',
      category: 'general',
      status: 'draft',
      thumbnailUrl: thumbnailUrl,
      authorUid: 'auth',
      authorName: 'Name',
      createdAt: created,
      updatedAt: updated,
      publishedAt: null,
      viewsCount: 3,
    );
  }

  test('copyWith overrides thumbnailUrl only', () {
    final original = build(thumbnailUrl: 'old');
    final next = original.copyWith(thumbnailUrl: 'new');

    expect(next.thumbnailUrl, 'new');
    expect(next.articleUid, original.articleUid);
    expect(next.title, original.title);
    expect(next.viewsCount, original.viewsCount);
  });

  test('copyWith keeps thumbnailUrl when omitted', () {
    final original = build(thumbnailUrl: 'same');
    expect(original.copyWith().thumbnailUrl, 'same');
  });

  test('equality uses props', () {
    expect(build(), equals(build()));
    expect(build(), isNot(equals(build(articleUid: 'other'))));
  });
}
