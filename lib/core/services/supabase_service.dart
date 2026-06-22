import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/environment.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      publishableKey: Environment.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
