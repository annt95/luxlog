import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/core/errors/app_exception.dart';
import 'package:luxlog/features/gallery/data/repositories/photo_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuthClient;
  late PhotoRepository repository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockAuthClient = MockGoTrueClient();
    when(() => mockSupabaseClient.auth).thenReturn(mockAuthClient);
    repository = PhotoRepository(mockSupabaseClient);
  });

  test('uploadPhoto throws auth exception when user is missing', () async {
    when(() => mockAuthClient.currentUser).thenReturn(null);

    expect(
      () => repository.uploadPhoto(
        fileBytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'test.jpg',
        title: 'My photo',
      ),
      throwsA(isA<AuthException>()),
    );
  });
}
