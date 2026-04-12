// ignore_for_file: subtype_of_sealed_class

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:news_app_clean_architecture/features/create_article/data/models/article_news_model.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  final created = DateTime.utc(2024, 3, 1, 12);
  final published = DateTime.utc(2024, 3, 2);
  final updated = DateTime.utc(2024, 3, 3);

  final entity = ArticleNewsEntity(
    articleUid: 'uid-1',
    title: 'Title',
    description: 'Desc',
    content: 'Body',
    category: 'technology',
    status: 'published',
    thumbnailUrl: 'https://thumb',
    authorUid: 'author-1',
    authorName: 'Author',
    createdAt: created,
    publishedAt: published,
    updatedAt: updated,
    viewsCount: 42,
  );

  group('ArticleNewsModel.fromMap', () {
    test('parses Timestamps and uses documentId when articleUid missing', () {
      final ts = Timestamp.fromDate(created);
      final map = <String, dynamic>{
        'title': 'T',
        'description': 'D',
        'content': 'C',
        'category': 'general',
        'status': 'draft',
        'thumbnailUrl': 'https://x',
        'authorUid': 'a',
        'authorName': 'N',
        'createdAt': ts,
        'publishedAt': null,
        'updatedAt': ts,
        'viewsCount': 7,
      };

      final m = ArticleNewsModel.fromMap(map, documentId: 'from-doc');

      expect(m.articleUid, 'from-doc');
      expect(m.title, 'T');
      expect(m.description, 'D');
      expect(m.content, 'C');
      expect(m.category, 'general');
      expect(m.status, 'draft');
      expect(m.thumbnailUrl, 'https://x');
      expect(m.authorUid, 'a');
      expect(m.authorName, 'N');
      expect(m.createdAt, ts.toDate());
      expect(m.publishedAt, isNull);
      expect(m.updatedAt, ts.toDate());
      expect(m.viewsCount, 7);
    });

    test('prefers non-empty thumbnailUrl over thumbnailPath', () {
      final m = ArticleNewsModel.fromMap(<String, dynamic>{
        'thumbnailUrl': 'https://a',
        'thumbnailPath': 'media/b',
      });
      expect(m.thumbnailUrl, 'https://a');
    });

    test('uses thumbnailPath when thumbnailUrl empty', () {
      final m = ArticleNewsModel.fromMap(<String, dynamic>{
        'thumbnailUrl': '',
        'thumbnailPath': 'media/articles/x/thumbnail.jpg',
      });
      expect(m.thumbnailUrl, 'media/articles/x/thumbnail.jpg');
    });

    test('uses map articleUid when present', () {
      final m = ArticleNewsModel.fromMap(<String, dynamic>{
        'articleUid': 'explicit',
      }, documentId: 'ignored');
      expect(m.articleUid, 'explicit');
    });
  });

  group('ArticleNewsModel.fromFirestore', () {
    test('delegates to fromMap with snapshot id', () {
      final snap = MockDocumentSnapshot();
      when(() => snap.id).thenReturn('snap-id');
      when(() => snap.data()).thenReturn(<String, dynamic>{
        'title': 't',
      });

      final m = ArticleNewsModel.fromFirestore(snap);

      expect(m.articleUid, 'snap-id');
      expect(m.title, 't');
    });

    test('throws when snapshot has no data', () {
      final snap = MockDocumentSnapshot();
      when(() => snap.id).thenReturn('missing');
      when(() => snap.data()).thenReturn(null);

      expect(
        () => ArticleNewsModel.fromFirestore(snap),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('missing'),
        )),
      );
    });
  });

  group('ArticleNewsModel.fromEntity', () {
    test('copies entity fields', () {
      final m = ArticleNewsModel.fromEntity(entity);
      expect(m.articleUid, entity.articleUid);
      expect(m.title, entity.title);
      expect(m.viewsCount, entity.viewsCount);
    });
  });

  group('ArticleNewsModel.toFirestoreCreateMap', () {
    test('uses FieldValue for server timestamps and Timestamp for publishedAt',
        () {
      final m = ArticleNewsModel.fromEntity(entity);
      final map = m.toFirestoreCreateMap();

      expect(map['articleUid'], entity.articleUid);
      expect(map['title'], entity.title);
      expect(map['createdAt'], isA<FieldValue>());
      expect(map['updatedAt'], isA<FieldValue>());
      expect(map['publishedAt'], isA<Timestamp>());
      expect(map['viewsCount'], 42);
    });

    test('sets publishedAt null when entity has no publishedAt', () {
      final e = ArticleNewsEntity(
        articleUid: 'u',
        title: 't',
        description: 'd',
        content: 'c',
        category: 'g',
        status: 'draft',
        thumbnailUrl: '',
        authorUid: 'a',
        authorName: 'n',
        createdAt: created,
        updatedAt: updated,
        publishedAt: null,
      );
      final map = ArticleNewsModel.fromEntity(e).toFirestoreCreateMap();
      expect(map['publishedAt'], isNull);
    });
  });

  group('ArticleNewsModel.toMap', () {
    test('serializes dates as Timestamp', () {
      final m = ArticleNewsModel(
        articleUid: 'u',
        title: 't',
        description: 'd',
        content: 'c',
        category: 'g',
        status: 's',
        thumbnailUrl: 'x',
        authorUid: 'a',
        authorName: 'n',
        createdAt: created,
        publishedAt: published,
        updatedAt: updated,
        viewsCount: 1,
      );
      final map = m.toMap();
      expect(map['createdAt'], Timestamp.fromDate(created));
      expect(map['publishedAt'], Timestamp.fromDate(published));
      expect(map['updatedAt'], Timestamp.fromDate(updated));
    });
  });

  group('ArticleNewsModel.withServerUpdatedAt', () {
    test('merges updatedAt FieldValue', () {
      final out = ArticleNewsModel.withServerUpdatedAt({'title': 'x'});
      expect(out['title'], 'x');
      expect(out['updatedAt'], isA<FieldValue>());
    });
  });

  group('ArticleNewsModel.toEntity', () {
    test('maps fields and uses epoch fallback for missing dates', () {
      final fallback = DateTime.fromMillisecondsSinceEpoch(0);
      final m = ArticleNewsModel(
        articleUid: 'u',
        title: 't',
        description: 'd',
        content: 'c',
        category: 'g',
        status: 's',
        thumbnailUrl: 'x',
        authorUid: 'a',
        authorName: 'n',
        createdAt: null,
        publishedAt: null,
        updatedAt: null,
        viewsCount: 0,
      );
      final e = m.toEntity();
      expect(e.createdAt, fallback);
      expect(e.updatedAt, fallback);
      expect(e.publishedAt, isNull);
    });

    test('preserves dates when present', () {
      final m = ArticleNewsModel.fromEntity(entity);
      final e = m.toEntity();
      expect(e.articleUid, entity.articleUid);
      expect(e.createdAt, entity.createdAt);
      expect(e.updatedAt, entity.updatedAt);
      expect(e.publishedAt, entity.publishedAt);
    });
  });
}
