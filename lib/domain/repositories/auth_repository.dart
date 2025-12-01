import '../entities/login_entity.dart';

/// Repository interface for authentication operations
/// This is part of the domain layer and defines the contract
abstract class AuthRepository {
  /// Login with phone number and password
  /// Returns LoginResponseEntity on success
  /// Throws exception on failure
  Future<LoginResponseEntity> login(LoginEntity loginEntity);
  
  /// Logout current user
  Future<void> logout();
  
  /// Check if user is logged in
  Future<bool> isLoggedIn();
  
  /// Get current user token
  Future<String?> getToken();
}

