import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:luxlog/app/router.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/core/services/error_reporter.dart';
import 'package:luxlog/core/services/supabase_service.dart';
import 'package:luxlog/core/widgets/error_boundary.dart';
import 'package:luxlog/features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  ErrorReporter().initialize();
  Object? initError;
  try {
    await SupabaseService.initialize();

    // On Web: handle OAuth PKCE code exchange after redirect.
    // Google OAuth redirects back to luxlog.vercel.app/?code=xxx#/...
    // The hash router doesn't let Supabase SDK auto-detect the code,
    // so we exchange it manually here.
    if (kIsWeb && SupabaseService.isInitialized) {
      await _handleOAuthCodeExchange();
    }
  } catch (error) {
    initError = error;
  }

  // Immersive dark UI — extend content behind status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0E0E0E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    ProviderScope(
      child: LuxlogApp(
        isBackendReady: SupabaseService.isInitialized,
        initError: initError,
      ),
    ),
  );
}

/// Checks if the current URL contains a `?code=` param from OAuth redirect
/// and exchanges it for a Supabase session.
Future<void> _handleOAuthCodeExchange() async {
  try {
    final uri = Uri.base;
    final code = uri.queryParameters['code'];
    if (code != null && code.isNotEmpty) {
      await SupabaseService.client.auth.exchangeCodeForSession(code);
      // Clean up the URL by removing the ?code= param
      _cleanUrlCode();
    }
  } catch (e) {
    // Code may have already been exchanged or expired — silently ignore.
    debugPrint('OAuth code exchange failed (may be stale): $e');
  }
}

/// The GoRouter redirect automatically navigates away from ?code= URLs
/// to /feed after successful exchange, so the URL bar gets cleaned up
/// naturally via path-based routing.
void _cleanUrlCode() {
  // With usePathUrlStrategy + GoRouter redirect (hasOAuthCode → /feed),
  // the browser URL is replaced by router navigation. No manual cleanup needed.
}

class LuxlogApp extends ConsumerWidget {
  final bool isBackendReady;
  final Object? initError;

  const LuxlogApp({
    super.key,
    required this.isBackendReady,
    this.initError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activate the auth profile sync listener globally.
    // This ensures Google OAuth return is handled even after app restart.
    if (isBackendReady) ref.watch(authProfileSyncProvider);

    if (!isBackendReady) {
      return MaterialApp(
        title: 'Luxlog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: _MissingConfigScreen(error: initError),
      );
    }

    return ErrorBoundary(
      child: MaterialApp.router(
        title: 'Luxlog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: router,
      ),
    );
  }
}

class _MissingConfigScreen extends StatelessWidget {
  final Object? error;
  const _MissingConfigScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0E0E0E),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Supabase is not configured.\n'
                'Set SUPABASE_URL and SUPABASE_ANON_KEY to continue.',
                textAlign: TextAlign.center,
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
