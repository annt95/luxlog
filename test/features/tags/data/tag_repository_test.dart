import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/features/tags/data/repositories/tag_repository.dart';

void main() {
  test('parseHashtags extracts hashtags from caption text', () {
    final hashtags = TagRepository.parseHashtags(
      'Golden hour #street #film #35mm',
    );

    expect(hashtags, ['street', 'film', '35mm']);
  });
}
