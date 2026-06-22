import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> execute({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) {
    return repository.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
  }
}
