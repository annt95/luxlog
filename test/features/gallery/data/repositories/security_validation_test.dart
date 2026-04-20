import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;
import 'package:luxlog/features/gallery/data/repositories/photo_repository.dart';
import 'package:luxlog/core/errors/app_exception.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late PhotoRepository repo;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user-123');
    repo = PhotoRepository(mockClient);
  });

  group('uploadPhoto file type validation', () {
    final dummyBytes = Uint8List.fromList([0, 1, 2]);

    test('rejects .exe files', () {
      expect(
        () => repo.uploadPhoto(
          fileBytes: dummyBytes,
          fileName: 'malware.exe',
          title: 'test',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects .pdf files', () {
      expect(
        () => repo.uploadPhoto(
          fileBytes: dummyBytes,
          fileName: 'doc.pdf',
          title: 'test',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects .svg files', () {
      expect(
        () => repo.uploadPhoto(
          fileBytes: dummyBytes,
          fileName: 'icon.svg',
          title: 'test',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects files with no extension', () {
      expect(
        () => repo.uploadPhoto(
          fileBytes: dummyBytes,
          fileName: 'noext',
          title: 'test',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    for (final ext in ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic']) {
      test('accepts .$ext files (proceeds to storage call)', () {
        // Will throw because storage is not mocked, but it should NOT
        // throw ValidationException — it should get past the whitelist check
        expect(
          () => repo.uploadPhoto(
            fileBytes: dummyBytes,
            fileName: 'photo.$ext',
            title: 'test',
          ),
          throwsA(isNot(isA<ValidationException>())),
        );
      });
    }
  });

  group('addComment validation', () {
    test('rejects empty comment', () {
      expect(
        () => repo.addComment('photo-1', ''),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects whitespace-only comment', () {
      expect(
        () => repo.addComment('photo-1', '   '),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects comment over 1000 chars', () {
      final longText = 'a' * 1001;
      expect(
        () => repo.addComment('photo-1', longText),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
