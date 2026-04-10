import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_google.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late SignInWithGoogleUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignInWithGoogleUseCase(mockAuthRepository);
  });

  test('returns a user from the repository when sign-in succeeds', () async {
    when(() => mockAuthRepository.signInWithGoogle())
        .thenAnswer((_) async => testAuthUser);

    final result = await useCase();

    expect(result, isA<AuthUser>());
    expect(result, equals(testAuthUser));
    verify(() => mockAuthRepository.signInWithGoogle()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('returns null when user cancels sign-in', () async {
    when(() => mockAuthRepository.signInWithGoogle())
        .thenAnswer((_) async => null);

    final result = await useCase();

    expect(result, isNull);
    verify(() => mockAuthRepository.signInWithGoogle()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('rethrows exceptions from the repository', () async {
    when(() => mockAuthRepository.signInWithGoogle())
        .thenThrow(UnsupportedError('boom'));

    expect(() => useCase(), throwsA(isA<UnsupportedError>()));
    verify(() => mockAuthRepository.signInWithGoogle()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}

