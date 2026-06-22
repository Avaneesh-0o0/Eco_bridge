import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  });
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
        
    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed');
    }

    final profileResponse = await client
        .from('profiles')
        .select()
        .eq('id', response.user!.id)
        .single();

    return UserModel.fromJson(profileResponse);
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final authResponse = await client.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user == null) {
      throw Exception('Registration failed');
    }

    final profileData = {
      'id': authResponse.user!.id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'is_verified': false,
      'is_active': true,
    };

    final profileResponse = await client
        .from('profiles')
        .insert(profileData)
        .select()
        .single();

    return UserModel.fromJson(profileResponse);
  }

  @override
  Future<void> logout() async {
    await client.auth.signOut();
  }
}
