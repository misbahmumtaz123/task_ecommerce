import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/controllers/auth_controller.dart';
import 'package:ecommerce_app/core/network/api_exceptions.dart';
import 'package:ecommerce_app/core/utils/result.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<UserModel>> login({
    required String username,
    required String password,
  }) async {
    if (username == 'emilys' && (password == 'emilyspass' || password == 'emilyspassword')) {
      return Result.success(
        const UserModel(
          id: 1,
          username: 'emilys',
          email: 'emily.johnson@x.dummyjson.com',
          firstName: 'Emily',
          lastName: 'Johnson',
          token: 'fake_jwt_token',
        ),
      );
    }
    return Result.failure(const BadRequestException('Invalid credentials', 400));
  }

  @override
  Future<Result<UserModel>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    return Result.success(
      UserModel(
        id: 101,
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        token: 'new_token',
      ),
    );
  }
}

void main() {
  group('AuthController Unit Tests', () {
    late AuthController authController;

    setUp(() {
      authController = AuthController(authRepository: FakeAuthRepository());
    });

    test('Initial auth state should be unauthenticated', () {
      expect(authController.currentUser, isNull);
      expect(authController.isAuthenticated, isFalse);
      expect(authController.errorMessage, isEmpty);
    });

    test('Successful login updates currentUser and sets isAuthenticated to true', () async {
      final success = await authController.login('emilys', 'emilyspassword');

      expect(success, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentUser?.username, 'emilys');
      expect(authController.currentUser?.fullName, 'Emily Johnson');
      expect(authController.errorMessage, isEmpty);
    });

    test('Failed login sets error message and leaves currentUser null', () async {
      final success = await authController.login('wrong', 'password');

      expect(success, isFalse);
      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentUser, isNull);
      expect(authController.errorMessage, 'Invalid credentials');
    });

    test('Logout clears currentUser', () async {
      await authController.login('emilys', 'emilyspassword');
      expect(authController.isAuthenticated, isTrue);

      authController.logout();
      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentUser, isNull);
    });
  });
}
