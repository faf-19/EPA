import '../entities/update_profile_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for updating customer profile
class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<UpdateProfileResponseEntity> execute({
    required String id,
    required String fullName,
  }) async {
    final trimmedName = fullName.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Name cannot be empty');
    }

    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw Exception('Missing user id');
    }

    final entity = UpdateProfileEntity(
      id: trimmedId,
      fullName: trimmedName,
    );

    return await repository.updateProfile(entity);
  }
}
