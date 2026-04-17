import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

class SupabaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (!Env.hasSupabaseConfig) {
      _isInitialized = false;
      if (kReleaseMode) {
        throw StateError(
          'Supabase configuration is missing. '
          'Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
        );
      }
      debugPrint(
        'WARNING: Supabase configuration is missing. '
        'App is running in local debug without backend initialization.',
      );
      return;
    }
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    _isInitialized = true;
  }

  static SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
        'SupabaseService is not initialized. '
        'Call SupabaseService.initialize() before accessing client.',
      );
    }
    return Supabase.instance.client;
  }
}
