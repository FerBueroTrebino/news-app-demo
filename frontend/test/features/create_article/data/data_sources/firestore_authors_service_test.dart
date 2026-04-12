// ignore_for_file: subtype_of_sealed_class

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/create_article/data/data_sources/firestore_authors_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late FirestoreAuthorsService service;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();
    service = FirestoreAuthorsService(mockFirestore);

    when(() => mockFirestore.collection('authors')).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocRef);
  });

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(<String, dynamic>{});
  });

  group('syncAuthorOnLogin', () {
    test('creates author doc with displayName when document is missing',
        () async {
      when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      const user = AuthUser(
        uid: 'new-1',
        email: 'writer@site.com',
        displayName: 'Visible Name',
        imageUrl: 'https://img',
      );

      await service.syncAuthorOnLogin(user);

      final captured = verify(() => mockDocRef.set(captureAny()))
          .captured
          .single as Map<String, dynamic>;

      expect(captured['uid'], 'new-1');
      expect(captured['email'], 'writer@site.com');
      expect(captured['nameToDisplay'], 'Visible Name');
      expect(captured['image'], 'https://img');
      expect(captured['username'], 'Visible Name');
      expect(captured['biografy'], '');
      expect(captured['articles'], <String>[]);
      expect(captured['totalViews'], 0);
      expect(captured['lastActiveAt'], isA<FieldValue>());
      expect(captured['createdAt'], isA<FieldValue>());
    });

    test('uses email local part for nameToDisplay when displayName is null',
        () async {
      when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      const user = AuthUser(
        uid: 'new-2',
        email: 'localpart@domain.org',
      );

      await service.syncAuthorOnLogin(user);

      final captured = verify(() => mockDocRef.set(captureAny()))
          .captured
          .single as Map<String, dynamic>;

      expect(captured['nameToDisplay'], 'localpart');
    });

    test("uses 'Author' for nameToDisplay when no displayName and no email",
        () async {
      when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      const user = AuthUser(uid: 'anon-style');

      await service.syncAuthorOnLogin(user);

      final captured = verify(() => mockDocRef.set(captureAny()))
          .captured
          .single as Map<String, dynamic>;

      expect(captured['nameToDisplay'], 'Author');
      expect(captured['email'], isNull);
    });

    test('updates lastActiveAt only when document already exists', () async {
      when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockDocRef.update(any())).thenAnswer((_) async {});

      const user = AuthUser(uid: 'existing');

      await service.syncAuthorOnLogin(user);

      verifyNever(() => mockDocRef.set(any()));
      final captured = verify(() => mockDocRef.update(captureAny()))
          .captured
          .single as Map<String, dynamic>;
      expect(captured.keys, ['lastActiveAt']);
      expect(captured['lastActiveAt'], isA<FieldValue>());
    });
  });
}
