import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetCurrentUserUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockAuthRepository);
  });

  test('returns the current user from the repository', () async {
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => testAuthUser);

    final result = await useCase();

    expect(result, isA<AuthUser>());
    expect(result, equals(testAuthUser));
    verify(() => mockAuthRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('returns null when there is no signed-in user', () async {
    when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);

    final result = await useCase();

    expect(result, isNull);
    verify(() => mockAuthRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('rethrows exceptions from the repository', () async {
    when(() => mockAuthRepository.getCurrentUser())
        .thenThrow(StateError('boom'));

    expect(() => useCase(), throwsA(isA<StateError>()));
    verify(() => mockAuthRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}

