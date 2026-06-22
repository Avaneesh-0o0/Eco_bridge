import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity?> getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<UserEntity> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) {
    return remoteDataSource.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }
}
