import 'package:flutter_test/flutter_test.dart';
import 'package:incampus/models/user_model.dart';

// 1. Define an interface for the API client
abstract class ApiClient {
  Future<Map<String, dynamic>> get(String endpoint);
}

// 2. Create a fake API client for testing
class FakeApiClient implements ApiClient {
  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    // Return predictable fake data
    return {
      'uid': '123',
      'email': 'test@example.com',
      'displayName': 'Test User',
      'photoUrl': null,
      'createdAt': DateTime(2024, 1, 1).toIso8601String(),
      'isEmailVerified': true,
    };
  }
}

// 3. UserRepository that uses dependency injection
class UserRepository {
  final ApiClient apiClient;
  UserRepository(this.apiClient);

  Future<UserModel> fetchUser() async {
    final json = await apiClient.get('/user');
    return UserModel.fromMap(json);
  }
}

void main() {
  test('UserRepository parses user from API', () async {
    final repo = UserRepository(FakeApiClient());
    final user = await repo.fetchUser();
    expect(user.uid, '123');
    expect(user.email, 'test@example.com');
    expect(user.displayName, 'Test User');
    expect(user.isEmailVerified, true);
    expect(user.createdAt, DateTime(2024, 1, 1));
  });
}
