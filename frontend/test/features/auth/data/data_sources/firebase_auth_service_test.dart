import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

void main() {
  late FirebaseAuthService service;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late MockGoogleSignInAccount mockGoogleAccount;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    mockGoogleAccount = MockGoogleSignInAccount();
    service = FirebaseAuthService(mockFirebaseAuth, mockGoogleSignIn);
  });

  setUpAll(() {
    registerFallbackValue(
      GoogleAuthProvider.credential(idToken: 'fallback-id-token'),
    );
  });

  group('getCurrentUser', () {
    test('returns null when Firebase has no current user', () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      final result = await service.getCurrentUser();

      expect(result, isNull);
      verify(() => mockFirebaseAuth.currentUser).called(1);
    });

    test('maps Firebase User fields to AuthUser', () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('firebase-uid');
      when(() => mockUser.email).thenReturn('user@example.com');
      when(() => mockUser.displayName).thenReturn('Jane Doe');
      when(() => mockUser.photoURL).thenReturn('https://example.com/p.jpg');

      final result = await service.getCurrentUser();

      expect(
        result,
        const AuthUser(
          uid: 'firebase-uid',
          email: 'user@example.com',
          displayName: 'Jane Doe',
          imageUrl: 'https://example.com/p.jpg',
        ),
      );
    });
  });

  group('signInWithGoogle', () {
    test('returns null when Firebase user is null after credential sign-in',
        () async {
      when(
        () => mockGoogleSignIn.authenticate(scopeHint: ['email']),
      ).thenAnswer((_) async => mockGoogleAccount);
      when(() => mockGoogleAccount.authentication).thenReturn(
        const GoogleSignInAuthentication(idToken: 'google-id-token'),
      );
      when(
        () => mockFirebaseAuth.signInWithCredential(any()),
      ).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(null);

      final result = await service.signInWithGoogle();

      expect(result, isNull);
      verify(
        () => mockGoogleSignIn.authenticate(scopeHint: ['email']),
      ).called(1);
      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
    });

    test('returns AuthUser when Google and Firebase sign-in succeed', () async {
      when(
        () => mockGoogleSignIn.authenticate(scopeHint: ['email']),
      ).thenAnswer((_) async => mockGoogleAccount);
      when(() => mockGoogleAccount.authentication).thenReturn(
        const GoogleSignInAuthentication(idToken: 'google-id-token'),
      );
      when(
        () => mockFirebaseAuth.signInWithCredential(any()),
      ).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('signed-in-uid');
      when(() => mockUser.email).thenReturn('g@mail.com');
      when(() => mockUser.displayName).thenReturn('Google Name');
      when(() => mockUser.photoURL).thenReturn('https://google/photo');

      final result = await service.signInWithGoogle();

      expect(
        result,
        const AuthUser(
          uid: 'signed-in-uid',
          email: 'g@mail.com',
          displayName: 'Google Name',
          imageUrl: 'https://google/photo',
        ),
      );
    });
  });

  group('signOut', () {
    test('signs out from Google then Firebase', () async {
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {});
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await service.signOut();

      verifyInOrder([
        () => mockGoogleSignIn.signOut(),
        () => mockFirebaseAuth.signOut(),
      ]);
    });
  });
}
