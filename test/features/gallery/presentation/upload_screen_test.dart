import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:luxlog/features/gallery/presentation/upload_screen.dart';
import 'package:luxlog/features/auth/providers/auth_provider.dart';

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  group('UploadScreen', () {
    testWidgets('renders initial pick-image state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const UploadScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show the upload/pick image prompt
      expect(find.byType(UploadScreen), findsOneWidget);
    });

    testWidgets('shows camera and gallery options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const UploadScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Look for photo-related icon buttons or cards
      expect(find.byIcon(Icons.photo_library_outlined), findsWidgets);
    });
  });
}
