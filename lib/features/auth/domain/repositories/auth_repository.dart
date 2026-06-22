import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  });
  Future<void> logout();
}
