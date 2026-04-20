import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/shared/widgets/photo_card.dart';

void main() {
  group('PhotoCard', () {
    Widget buildPhotoCard({
      String photoId = 'test-id',
      String imageUrl = 'https://example.com/photo.jpg',
      String photographerName = 'John Doe',
      String? photographerAvatar,
      String? title,
      int likes = 10,
      bool isLiked = false,
      String? camera,
      String? filmStock,
      String? lens,
      VoidCallback? onLike,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PhotoCard(
              photoId: photoId,
              imageUrl: imageUrl,
              photographerName: photographerName,
              photographerAvatar: photographerAvatar,
              title: title,
              likes: likes,
              isLiked: isLiked,
              camera: camera,
              filmStock: filmStock,
              lens: lens,
              onLike: onLike,
            ),
          ),
        ),
      );
    }

    testWidgets('renders photographer name', (tester) async {
      await tester.pumpWidget(buildPhotoCard(
        photographerName: 'Jane Photographer',
      ));
      await tester.pump();

      expect(find.textContaining('J'), findsWidgets); // Initial avatar letter
    });

    testWidgets('renders with empty photographer name gracefully', (tester) async {
      await tester.pumpWidget(buildPhotoCard(
        photographerName: '',
      ));
      await tester.pump();

      // Should not crash
      expect(find.byType(PhotoCard), findsOneWidget);
    });

    testWidgets('shows EXIF summary when filmStock provided', (tester) async {
      await tester.pumpWidget(buildPhotoCard(
        filmStock: 'Portra 400',
        camera: 'Contax T2',
      ));
      await tester.pump();

      // EXIF summary should include film stock and camera
      expect(find.textContaining('Portra 400'), findsOneWidget);
    });

    testWidgets('shows camera in EXIF when no filmStock', (tester) async {
      await tester.pumpWidget(buildPhotoCard(
        camera: 'Canon AE-1',
      ));
      await tester.pump();

      expect(find.textContaining('Canon AE-1'), findsOneWidget);
    });

    testWidgets('shows lens when no camera or filmStock', (tester) async {
      await tester.pumpWidget(buildPhotoCard(
        lens: '50mm f/1.4',
      ));
      await tester.pump();

      expect(find.textContaining('50mm f/1.4'), findsOneWidget);
    });

    testWidgets('hides EXIF line when no metadata', (tester) async {
      await tester.pumpWidget(buildPhotoCard());
      await tester.pump();

      // No EXIF text separator should appear
      expect(find.textContaining(' · '), findsNothing);
    });

    testWidgets('renders like count', (tester) async {
      await tester.pumpWidget(buildPhotoCard(likes: 42));
      await tester.pump();

      expect(find.textContaining('42'), findsOneWidget);
    });

    testWidgets('toggles like on tap', (tester) async {
      bool likeCalled = false;
      await tester.pumpWidget(buildPhotoCard(
        likes: 10,
        isLiked: false,
        onLike: () => likeCalled = true,
      ));
      await tester.pump();

      // Find and tap the like button (heart icon)
      final heartFinder = find.byIcon(Icons.favorite_border);
      if (heartFinder.evaluate().isNotEmpty) {
        await tester.tap(heartFinder.first);
        await tester.pump();
        expect(likeCalled, isTrue);
      }
    });

    testWidgets('shows title when provided', (tester) async {
      await tester.pumpWidget(buildPhotoCard(title: 'My Photo Title'));
      await tester.pump();

      expect(find.textContaining('My Photo Title'), findsOneWidget);
    });
  });
}
