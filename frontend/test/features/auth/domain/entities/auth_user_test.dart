import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

void main() {
  group('AuthUser', () {
    test('supports value equality with identical fields', () {
      const a = AuthUser(
        uid: 'uid-1',
        email: 'a@example.com',
        displayName: 'A',
        imageUrl: 'https://example.com/a.png',
      );
      const b = AuthUser(
        uid: 'uid-1',
        email: 'a@example.com',
        displayName: 'A',
        imageUrl: 'https://example.com/a.png',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('does not equal when any field differs', () {
      const base = AuthUser(
        uid: 'uid-1',
        email: 'a@example.com',
        displayName: 'A',
        imageUrl: 'https://example.com/a.png',
      );

      const differentUid = AuthUser(
        uid: 'uid-2',
        email: 'a@example.com',
        displayName: 'A',
        imageUrl: 'https://example.com/a.png',
      );
      const differentEmail = AuthUser(
        uid: 'uid-1',
        email: 'b@example.com',
        displayName: 'A',
        imageUrl: 'https://example.com/a.png',
      );
      const differentDisplayName = AuthUser(
        uid: 'uid-1',
        email: 'a@example.com',
        displayName: 'B',
        imageUrl: 'https://example.com/a.png',
      );
      const differentImageUrl = AuthUser(
        uid: 'uid-1',
        email: 'a@example.com',
        displayName: 'A',
        imageUrl: 'https://example.com/b.png',
      );

      expect(base, isNot(equals(differentUid)));
      expect(base, isNot(equals(differentEmail)));
      expect(base, isNot(equals(differentDisplayName)));
      expect(base, isNot(equals(differentImageUrl)));
    });

    test('treats null optional fields as part of equality', () {
      const a =
          AuthUser(uid: 'uid-1', email: null, displayName: null, imageUrl: null);
      const b =
          AuthUser(uid: 'uid-1', email: null, displayName: null, imageUrl: null);
      const c = AuthUser(
        uid: 'uid-1',
        email: 'a@example.com',
        displayName: null,
        imageUrl: null,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}

