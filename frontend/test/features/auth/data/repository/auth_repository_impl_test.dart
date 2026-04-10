import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockFirebaseAuthService mockFirebaseAuthService;

  setUp(() {
    mockFirebaseAuthService = MockFirebaseAuthService();
    repository = AuthRepositoryImpl(mockFirebaseAuthService);
  });

  group('getCurrentUser', () {
    test('delegates to FirebaseAuthService', () async {
      when(() => mockFirebaseAuthService.getCurrentUser())
          .thenAnswer((_) async => testAuthUser);

      final result = await repository.getCurrentUser();

      expect(result, testAuthUser);
      verify(() => mockFirebaseAuthService.getCurrentUser()).called(1);
    });
  });

  group('signInWithGoogle', () {
    test('delegates to FirebaseAuthService', () async {
      when(() => mockFirebaseAuthService.signInWithGoogle())
          .thenAnswer((_) async => testAuthUser);

      final result = await repository.signInWithGoogle();

      expect(result, testAuthUser);
      verify(() => mockFirebaseAuthService.signInWithGoogle()).called(1);
    });

    test('returns null when sign-in yields no user', () async {
      when(() => mockFirebaseAuthService.signInWithGoogle())
          .thenAnswer((_) async => null);

      final result = await repository.signInWithGoogle();

      expect(result, isNull);
      verify(() => mockFirebaseAuthService.signInWithGoogle()).called(1);
    });
  });

  group('signOut', () {
    test('delegates to FirebaseAuthService', () async {
      when(() => mockFirebaseAuthService.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => mockFirebaseAuthService.signOut()).called(1);
    });
  });
}
