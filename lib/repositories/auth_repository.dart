import '../core/network/api_exceptions.dart';
import '../core/utils/result.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';

/// Contract defining data operations for user authentication
abstract class AuthRepository {
  Future<Result<UserModel>> login({
    required String username,
    required String password,
  });

  Future<Result<UserModel>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });
}

/// Concrete implementation of [AuthRepository]
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;

  AuthRepositoryImpl({AuthApiService? apiService})
      : _apiService = apiService ?? AuthApiServiceImpl();

  @override
  Future<Result<UserModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      final json = await _apiService.login(
        username: username,
        password: password,
      );
      final user = UserModel.fromJson(json);
      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnexpectedApiException(e.toString()));
    }
  }

  @override
  Future<Result<UserModel>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final json = await _apiService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      final user = UserModel.fromJson(json);
      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnexpectedApiException(e.toString()));
    }
  }
}
