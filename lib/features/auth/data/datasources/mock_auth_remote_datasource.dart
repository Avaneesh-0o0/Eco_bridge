import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  UserModel? _currentUser;
  
  // Dummy user database
  final List<UserModel> _users = [
    UserModel(
      id: 'mock_donor_1',
      fullName: 'Ravi Sharma',
      email: 'donor@test.com',
      role: 'donor',
      isVerified: true,
      isActive: true,
    ),
    UserModel(
      id: 'mock_ngo_1',
      fullName: 'Asha Foundation',
      email: 'ngo@test.com',
      role: 'ngo',
      isVerified: true,
      isActive: true,
    ),
    UserModel(
      id: 'mock_volunteer_1',
      fullName: 'Priya Patel',
      email: 'volunteer@test.com',
      role: 'volunteer',
      isVerified: true,
      isActive: true,
    ),
  ];

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final user = _users.firstWhere((u) => u.email == email);
      _currentUser = user;
      return user;
    } catch (e) {
      // If not found, just log them in as a donor
      _currentUser = _users.first;
      return _currentUser!;
    }
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final newUser = UserModel(
      id: const Uuid().v4(),
      fullName: fullName,
      email: email,
      role: role,
      isVerified: false,
      isActive: true,
    );
    
    _users.add(newUser);
    _currentUser = newUser;
    return newUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }
}
