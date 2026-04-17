import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('repository code uses profiles and comments.text contract', () async {
    final libDir = Directory('lib');
    final dartFiles = await libDir
        .list(recursive: true)
        .where((entity) => entity is File && entity.path.endsWith('.dart'))
        .cast<File>()
        .toList();

    for (final file in dartFiles) {
      final content = await file.readAsString();
      expect(
        content.contains("from('users')"),
        isFalse,
        reason: 'Found legacy users table reference in ${file.path}',
      );
      expect(
        content.contains("'body':"),
        isFalse,
        reason: 'Found legacy comments.body payload in ${file.path}',
      );
    }
  });
}
