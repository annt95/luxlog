import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxlog/main.dart';

void main() {
  group('App smoke tests', () {
    testWidgets('App renders MaterialApp when backend ready', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: LuxlogApp(isBackendReady: true)));
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Shows missing config screen when backend not ready', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: LuxlogApp(isBackendReady: false),
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('Supabase is not configured'), findsOneWidget);
    });

    testWidgets('Shows init error when provided', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(
        child: LuxlogApp(
          isBackendReady: false,
          initError: 'Test connection error',
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Test connection error'), findsOneWidget);
    });
  });
}
