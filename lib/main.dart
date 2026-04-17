import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxlog/app/router.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/core/services/supabase_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SupabaseService.initialize();

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
      ),
    ),
  );
}

class LuxlogApp extends StatelessWidget {
  final bool isBackendReady;

  const LuxlogApp({
    super.key,
    required this.isBackendReady,
  });

  @override
  Widget build(BuildContext context) {
    if (!isBackendReady) {
      return MaterialApp(
        title: 'Luxlog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _MissingConfigScreen(),
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
  const _MissingConfigScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0E0E0E),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Supabase is not configured.\n'
            'Set SUPABASE_URL and SUPABASE_ANON_KEY to continue.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
