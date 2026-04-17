import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxlog/features/profile/presentation/profile_edit_screen.dart';

void main() {
  testWidgets('ProfileEditScreen renders bio and fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileEditScreen(),
        ),
      ),
    );

    // Wait for the post frame callback and initial build
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.text('Save'), findsOneWidget);
  });
}
