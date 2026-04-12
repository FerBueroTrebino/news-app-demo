import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/create_article/data/models/author_model.dart';

void main() {
  group('AuthorModel.fromAuthUser', () {
    test('maps displayName, email, imageUrl', () {
      const user = AuthUser(
        uid: 'u1',
        email: 'x@y.com',
        displayName: 'Name',
        imageUrl: 'https://pic',
      );

      final m = AuthorModel.fromAuthUser(user);

      expect(m.uid, 'u1');
      expect(m.email, 'x@y.com');
      expect(m.nameToDisplay, 'Name');
      expect(m.image, 'https://pic');
      expect(m.articles, isEmpty);
      expect(m.totalViews, 0);
    });

    test('uses email local part when displayName is null', () {
      const user = AuthUser(uid: 'u2', email: 'local@domain.org');

      final m = AuthorModel.fromAuthUser(user);

      expect(m.nameToDisplay, 'local');
    });

    test("uses 'Author' when no displayName and no email", () {
      const user = AuthUser(uid: 'u3');

      final m = AuthorModel.fromAuthUser(user);

      expect(m.nameToDisplay, 'Author');
    });
  });

  group('AuthorModel.fromMap', () {
    test('parses Timestamps and lists', () {
      final created = Timestamp.fromDate(DateTime.utc(2024, 1, 2));
      final expectedDate = created.toDate();
      final map = <String, dynamic>{
        'uid': 'a1',
        'username': 'un',
        'nameToDisplay': 'N',
        'email': 'e@e.com',
        'biografy': 'bio',
        'image': 'img',
        'articles': ['x', 'y'],
        'createdAt': created,
        'totalViews': 3,
        'lastActiveAt': created,
      };

      final m = AuthorModel.fromMap(map);

      expect(m.uid, 'a1');
      expect(m.username, 'un');
      expect(m.nameToDisplay, 'N');
      expect(m.email, 'e@e.com');
      expect(m.biografy, 'bio');
      expect(m.image, 'img');
      expect(m.articles, ['x', 'y']);
      expect(m.createdAt, expectedDate);
      expect(m.totalViews, 3);
      expect(m.lastActiveAt, expectedDate);
    });

    test('uses documentId when uid missing in map', () {
      final m = AuthorModel.fromMap(<String, dynamic>{}, documentId: 'doc-id');

      expect(m.uid, 'doc-id');
    });
  });

  group('AuthorModel.toFirestoreCreateMap', () {
    test('includes FieldValue for timestamp fields', () {
      final m = AuthorModel.fromAuthUser(
        const AuthUser(uid: 'u', email: 'a@b.com', displayName: 'D'),
      );

      final map = m.toFirestoreCreateMap();

      expect(map['uid'], 'u');
      expect(map['lastActiveAt'], isA<FieldValue>());
      expect(map['createdAt'], isA<FieldValue>());
    });
  });

  group('AuthorModel.toEntity', () {
    test('maps to domain Author', () {
      final m = AuthorModel(
        uid: 'u',
        nameToDisplay: 'N',
        biografy: 'b',
        image: 'i',
        articles: const ['a'],
        createdAt: DateTime.utc(2024),
        totalViews: 1,
        lastActiveAt: DateTime.utc(2025),
      );

      final e = m.toEntity();

      expect(e.uid, 'u');
      expect(e.nameToDisplay, 'N');
      expect(e.biografy, 'b');
      expect(e.image, 'i');
      expect(e.articles, ['a']);
      expect(e.createdAt, DateTime.utc(2024));
      expect(e.totalViews, 1);
      expect(e.lastActiveAt, DateTime.utc(2025));
    });
  });
}
