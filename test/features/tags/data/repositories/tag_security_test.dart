import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/features/tags/data/repositories/tag_repository.dart';
import 'package:luxlog/core/errors/app_exception.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient mockClient;
  late TagRepository repo;

  setUp(() {
    mockClient = MockSupabaseClient();
    repo = TagRepository(mockClient);
  });

  group('TagRepository constants', () {
    test('maxTagsPerPhoto is 30', () {
      expect(TagRepository.maxTagsPerPhoto, 30);
    });

    test('maxTagLength is 50', () {
      expect(TagRepository.maxTagLength, 50);
    });
  });

  group('attachTagsToPhoto validation', () {
    test('rejects more than 30 tags', () {
      final tooManyTags = List.generate(31, (i) => 'tag$i');
      expect(
        () => repo.attachTagsToPhoto('photo-1', tooManyTags),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('parseHashtags', () {
    test('extracts hashtags from text', () {
      final tags = TagRepository.parseHashtags('Beautiful sunset #goldenhour #landscape');
      expect(tags, ['goldenhour', 'landscape']);
    });

    test('returns empty for text without hashtags', () {
      final tags = TagRepository.parseHashtags('No tags here');
      expect(tags, isEmpty);
    });

    test('handles multiple hashtags', () {
      final tags = TagRepository.parseHashtags('#a #b #c');
      expect(tags, ['a', 'b', 'c']);
    });
  });
}
