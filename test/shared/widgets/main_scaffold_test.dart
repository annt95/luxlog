import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luxlog/shared/widgets/main_scaffold.dart';

void main() {
  Widget createWidgetUnderTest() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const Text('Home Page'),
            ),
            GoRoute(
              path: '/feed',
              builder: (context, state) => const Text('Social Feed'),
            ),
            GoRoute(
              path: '/upload',
              builder: (context, state) => const Text('Upload'),
            ),
            GoRoute(
              path: '/portfolio',
              builder: (context, state) => const Text('Portfolio'),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const Text('Profile'),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('MainScaffold Widget Tests', () {
    testWidgets('renders bottom navigation items correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check if icons exist (using the ones present in MainScaffold)
      expect(find.byIcon(Icons.layers_outlined), findsOneWidget); // Discover
      expect(find.byIcon(Icons.dashboard_customize_outlined), findsOneWidget); // Social
      expect(find.byIcon(Icons.grid_view), findsOneWidget); // Portfolio
      expect(find.byIcon(Icons.person_outline), findsOneWidget); // Profile
      
      // Floating Action Button
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('navigation tab switching works via GoRouter', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initially on home
      expect(find.text('Home Page'), findsOneWidget);

      // Tap on Social Feed tab (second item)
      await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Social Feed'), findsOneWidget);
    });
  });
}
