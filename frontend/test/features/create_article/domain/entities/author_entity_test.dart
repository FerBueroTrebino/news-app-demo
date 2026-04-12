import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/entities/author_entity.dart';

void main() {
  final created = DateTime.utc(2026, 2, 1);

  AuthorEntity build({
    String uid = 'u1',
    int totalViews = 0,
    DateTime? lastActiveAt,
  }) {
    return AuthorEntity(
      uid: uid,
      nameToDisplay: 'Display',
      biografy: 'Bio',
      image: 'img',
      articles: const ['a1'],
      createdAt: created,
      username: 'user',
      email: 'e@x.com',
      totalViews: totalViews,
      lastActiveAt: lastActiveAt,
    );
  }

  test('equality uses props', () {
    expect(build(), equals(build()));
    expect(build(), isNot(equals(build(uid: 'u2'))));
    expect(build(), isNot(equals(build(totalViews: 1))));
  });

  test('distinct lastActiveAt changes equality', () {
    final t = DateTime.utc(2026, 3, 1);
    expect(
      build(lastActiveAt: t),
      isNot(equals(build(lastActiveAt: DateTime.utc(2026, 3, 2)))),
    );
  });
}
