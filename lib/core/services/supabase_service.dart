import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

class SupabaseService {
  static Future<void> initialize() async {
    if (!Env.hasSupabaseConfig) {
      debugPrint('WARNING: Supabase configuration is missing. Running in mock mode or error will occur.');
      return;
    }
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
