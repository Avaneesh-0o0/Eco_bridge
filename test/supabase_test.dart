import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foodbridge_ai/core/config/environment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

void main() {
  test('Supabase Login Test', () async {
    await dotenv.load(fileName: ".env");
    
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      publishableKey: Environment.supabaseAnonKey,
    );

    final client = Supabase.instance.client;

    try {
      final response = await client.auth.signInWithPassword(
        email: 'donor@example.com',
        password: 'password123',
      );
      
      debugPrint('Login Success: ${response.user?.id}');
      
      final profileResponse = await client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();
          
      debugPrint('Profile Fetch Success: ${profileResponse['full_name']}');
      
    } catch (e) {
      debugPrint('Error occurred: $e');
      fail('Supabase connection or auth failed');
    }
  });
}
