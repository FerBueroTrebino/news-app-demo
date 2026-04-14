// ignore_for_file: subtype_of_sealed_class

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:news_app_clean_architecture/features/create_article/data/data_sources/firestore_articles_service.dart';

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

void main() {
  late FirestoreArticlesService service;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQuery mockQuery;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockQuery = MockQuery();
    service = FirestoreArticlesService(mockFirestore);

    when(() => mockFirestore.collection('articles')).thenReturn(mockCollection);
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('paths', () {
    test('newArticleDocument returns collection doc()', () {
      when(() => mockCollection.doc()).thenReturn(mockDocRef);

      final ref = service.newArticleDocument();

      expect(ref, mockDocRef);
      verify(() => mockCollection.doc()).called(1);
    });

    test('articleDocument returns doc with given id', () {
      when(() => mockCollection.doc('abc')).thenReturn(mockDocRef);

      final ref = service.articleDocument('abc');

      expect(ref, mockDocRef);
      verify(() => mockCollection.doc('abc')).called(1);
    });
  });

  group('setArticle', () {
    test('delegates to reference set', () async {
      final data = <String, dynamic>{'title': 'x'};
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      await service.setArticle(mockDocRef, data);

      verify(() => mockDocRef.set(data)).called(1);
    });
  });

  group('updateArticle', () {
    test('delegates to reference update', () async {
      final data = <String, dynamic>{'title': 'updated'};
      when(() => mockDocRef.update(any())).thenAnswer((_) async {});

      await service.updateArticle(mockDocRef, data);

      verify(() => mockDocRef.update(data)).called(1);
    });
  });

  group('deleteArticle', () {
    test('delegates to reference delete', () async {
      when(() => mockDocRef.delete()).thenAnswer((_) async {});

      await service.deleteArticle(mockDocRef);

      verify(() => mockDocRef.delete()).called(1);
    });
  });

  group('getAllArticles', () {
    test('returns docs from collection get', () async {
      final mockDoc = MockQueryDocumentSnapshot();
      when(() => mockCollection.get())
          .thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockDoc]);

      final docs = await service.getAllArticles();

      expect(docs, [mockDoc]);
      verify(() => mockCollection.get()).called(1);
    });
  });

  group('watchAllArticles', () {
    test('maps snapshots to docs', () async {
      final mockDoc = MockQueryDocumentSnapshot();
      when(() => mockCollection.snapshots())
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(() => mockQuerySnapshot.docs).thenReturn([mockDoc]);

      final first = await service.watchAllArticles().first;

      expect(first, [mockDoc]);
    });
  });

  group('watchArticlesByStatus', () {
    test('queries status and maps snapshots to docs', () async {
      final mockDoc = MockQueryDocumentSnapshot();
      when(
        () => mockCollection.where(
          'status',
          isEqualTo: 'published',
        ),
      ).thenReturn(mockQuery);
      when(() => mockQuery.snapshots())
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(() => mockQuerySnapshot.docs).thenReturn([mockDoc]);

      final first = await service.watchArticlesByStatus('published').first;

      expect(first, [mockDoc]);
      verify(
        () => mockCollection.where('status', isEqualTo: 'published'),
      ).called(1);
    });
  });

  group('watchArticlesByAuthorUid', () {
    test('queries authorUid and maps snapshots to docs', () async {
      final mockDoc = MockQueryDocumentSnapshot();
      when(
        () => mockCollection.where(
          'authorUid',
          isEqualTo: 'user-1',
        ),
      ).thenReturn(mockQuery);
      when(() => mockQuery.snapshots())
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(() => mockQuerySnapshot.docs).thenReturn([mockDoc]);

      final first = await service.watchArticlesByAuthorUid('user-1').first;

      expect(first, [mockDoc]);
      verify(
        () => mockCollection.where('authorUid', isEqualTo: 'user-1'),
      ).called(1);
    });
  });
}
