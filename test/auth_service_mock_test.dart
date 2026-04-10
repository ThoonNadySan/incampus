import 'package:flutter_test/flutter_test.dart';
// No mockito needed for simple fake
import 'package:incampus/services/auth_service.dart';
import 'package:incampus/models/user_model.dart';
import 'package:mockito/annotations.dart';


// Pure fake class for testing (does NOT extend AuthService or touch Firebase)
class FakeAuthService {
  Future<UserModel?> signInWithEmail({required String email, required String password}) async {
    if (email == 'test@example.com' && password == 'password123') {
      return UserModel(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: null,
        createdAt: DateTime(2024, 1, 1),
        isEmailVerified: true,
      );
    }
    return null;
  }
}

void main() {
  group('AuthService (Fake)', () {
    test('should return user on successful login', () async {
      final fakeAuthService = FakeAuthService();
      final user = await fakeAuthService.signInWithEmail(email: 'test@example.com', password: 'password123');
      expect(user, isNotNull);
      expect(user!.email, 'test@example.com');
      expect(user.displayName, 'Test User');
    });

    test('should return null on failed login', () async {
      final fakeAuthService = FakeAuthService();
      final user = await fakeAuthService.signInWithEmail(email: 'wrong@example.com', password: 'wrongpass');
      expect(user, isNull);
    });
  });
}
