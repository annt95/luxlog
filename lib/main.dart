import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxlog/app/router.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/core/services/supabase_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? initError;
  try {
    await SupabaseService.initialize();
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

class LuxlogApp extends StatelessWidget {
  final bool isBackendReady;
  final Object? initError;

  const LuxlogApp({
    super.key,
    required this.isBackendReady,
    this.initError,
  });

  @override
  Widget build(BuildContext context) {
    if (!isBackendReady) {
      return MaterialApp(
        title: 'Luxlog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: _MissingConfigScreen(error: initError),
      );
    }

    return MaterialApp.router(
      title: 'Luxlog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
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
