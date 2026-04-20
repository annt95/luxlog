class Env {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // Google OAuth — client ID for native mobile (google_sign_in package).
  // On Web, OAuth redirects are handled entirely by Supabase server-side.
  static const String googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');

  // Sentry DSN for Error Tracking
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static bool get hasSupabaseConfig {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}
