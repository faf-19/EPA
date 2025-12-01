import '../entities/login_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login
/// This encapsulates the business logic for login
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Execute login with phone number and password
  /// Returns LoginResponseEntity on success
  /// Throws exception on failure
  Future<LoginResponseEntity> execute({
    required String phoneNumber,
    required String password,
  }) async {
    // Validate input
    if (phoneNumber.trim().isEmpty) {
      throw Exception('Phone number cannot be empty');
    }

    if (password.trim().isEmpty) {
      throw Exception('Password cannot be empty');
    }

    // Validate Ethiopian phone number format
    final isValidPhone = RegExp(r'^09\d{8}$').hasMatch(phoneNumber.trim());
    if (!isValidPhone) {
      throw Exception('Please enter a valid Ethiopian phone number (e.g. 0912345678)');
    }

    // Create login entity
    final loginEntity = LoginEntity(
      phoneNumber: phoneNumber.trim(),
      password: password.trim(),
    );

    // Call repository
    return await repository.login(loginEntity);
  }
}

