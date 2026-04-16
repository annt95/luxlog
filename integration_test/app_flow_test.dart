import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:luxlog/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Flow Test', () {
    testWidgets('Verify Feed Tabs, Comment Bottom Sheet, and Follow state', (WidgetTester tester) async {
      app.main();
      
      // Wait for the app to finish rendering components
      await tester.pumpAndSettle();

      // 1. Verify we are on the Feed Screen and see "For You" and "Following"
      expect(find.text('For You'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);

      // 2. Switch to 'Following' Tab
      await tester.tap(find.text('Following'));
      await tester.pumpAndSettle();

      // 3. Open comments bottom sheet on the first post
      final commentButton = find.byIcon(Icons.chat_bubble_outline).first;
      expect(commentButton, findsOneWidget);
      
      await tester.tap(commentButton);
      await tester.pumpAndSettle();

      // Verify the bottom sheet opened
      expect(find.text('Comments'), findsOneWidget);
      expect(find.text('Add a comment...'), findsOneWidget);

      // Close the bottom sheet by swiping down or tapping back
      await tester.tapAt(const Offset(10, 10)); // Tap outside
      await tester.pumpAndSettle();

      // 4. Navigate to Profile by tapping the second item in Bottom Navigation Bar
      final profileTab = find.byIcon(Icons.person_outline).last;
      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      // In the mock data, clicking standard profile tab goes to our own profile or mock profile
      // If we see "Follow" button, let's tap it
      final followButton = find.text('Follow');
      if (followButton.evaluate().isNotEmpty) {
        await tester.tap(followButton);
        await tester.pumpAndSettle();
        // It should change to "Following"
        expect(find.text('Following'), findsOneWidget);
      }
    });
  });
}
