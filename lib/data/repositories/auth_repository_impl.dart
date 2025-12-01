import '../../domain/entities/login_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../models/login_model.dart';

/// Implementation of AuthRepository
/// This connects the domain layer with the data layer
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<LoginResponseEntity> login(LoginEntity loginEntity) async {
    try {
      // Convert entity to model
      final loginModel = LoginModel(
        phoneNumber: loginEntity.phoneNumber,
        password: loginEntity.password,
        username: loginEntity.username,
      );

      // Call remote data source
      final response = await remoteDataSource.login(loginModel);

      // Save to local storage if login is successful
      if (response.success && response.token != null) {
        await localDataSource.saveToken(response.token!);
        if (response.userId != null) {
          await localDataSource.saveUserId(response.userId!);
        }
        if (response.username != null) {
          await localDataSource.saveUsername(response.username!);
        }
        if (response.phoneNumber != null) {
          await localDataSource.savePhoneNumber(response.phoneNumber!);
        }
      }

      // Convert model to entity and return
      return response.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Clear local storage
      await localDataSource.clearAll();
    } catch (e) {
      // Even if clearing fails, we should continue
      rethrow;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }

  @override
  Future<String?> getToken() async {
    return await localDataSource.getToken();
  }
}

