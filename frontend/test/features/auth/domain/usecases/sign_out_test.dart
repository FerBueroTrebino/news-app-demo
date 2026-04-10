import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late SignOutUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignOutUseCase(mockAuthRepository);
  });

  test('calls signOut on the repository', () async {
    when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

    await useCase();

    verify(() => mockAuthRepository.signOut()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('rethrows exceptions from the repository', () async {
    when(() => mockAuthRepository.signOut()).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsA(isA<Exception>()));
    verify(() => mockAuthRepository.signOut()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}

