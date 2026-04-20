import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/shared/models/photo_model.dart';

void main() {
  group('PhotoModel', () {
    test('fromJson creates model from valid JSON', () {
      final json = {
        'id': 'photo-1',
        'user_id': 'user-1',
        'title': 'Sunset',
        'description': 'A beautiful sunset',
        'image_url': 'https://storage.example.com/photo.jpg',
        'camera': 'Canon AE-1',
        'lens': '50mm f/1.4',
        'iso': 400,
        'aperture': 'f/2.8',
        'shutter_speed': '1/125',
        'focal_length': '50',
        'is_film': true,
        'film_stock': 'Kodak Portra 400',
        'film_camera': 'Canon AE-1',
        'views_count': 42,
        'likes_count': 10,
        'comments_count': 3,
        'is_public': true,
        'allow_download': true,
        'created_at': '2026-04-20T10:00:00.000Z',
      };

      final model = PhotoModel.fromJson(json);

      expect(model.id, 'photo-1');
      expect(model.userId, 'user-1');
      expect(model.title, 'Sunset');
      expect(model.imageUrl, 'https://storage.example.com/photo.jpg');
      expect(model.camera, 'Canon AE-1');
      expect(model.iso, 400);
      expect(model.isFilm, true);
      expect(model.filmStock, 'Kodak Portra 400');
      expect(model.viewsCount, 42);
      expect(model.likesCount, 10);
      expect(model.createdAt, isNotNull);
    });

    test('fromJson handles minimal required fields', () {
      final json = {
        'id': 'photo-2',
        'user_id': 'user-2',
        'image_url': 'https://storage.example.com/minimal.jpg',
      };

      final model = PhotoModel.fromJson(json);

      expect(model.id, 'photo-2');
      expect(model.userId, 'user-2');
      expect(model.imageUrl, 'https://storage.example.com/minimal.jpg');
      expect(model.title, isNull);
      expect(model.camera, isNull);
      expect(model.isFilm, false);
      expect(model.viewsCount, 0);
      expect(model.likesCount, 0);
      expect(model.isPublic, true);
      expect(model.allowDownload, true);
    });

    test('toJson produces correct key names', () {
      const model = PhotoModel(
        id: 'photo-3',
        userId: 'user-3',
        imageUrl: 'https://example.com/img.jpg',
        isFilm: true,
        filmStock: 'Fuji Pro 400H',
        shutterSpeed: '1/60',
        focalLength: '35',
      );

      final json = model.toJson();

      expect(json['user_id'], 'user-3');
      expect(json['image_url'], 'https://example.com/img.jpg');
      expect(json['is_film'], true);
      expect(json['film_stock'], 'Fuji Pro 400H');
      expect(json['shutter_speed'], '1/60');
      expect(json['focal_length'], '35');
    });

    test('fromJson → toJson round-trip preserves data', () {
      final original = {
        'id': 'photo-rt',
        'user_id': 'user-rt',
        'title': 'Round Trip',
        'image_url': 'https://example.com/rt.jpg',
        'camera': 'Nikon F3',
        'lens': '85mm f/1.8',
        'iso': 200,
        'aperture': 'f/4',
        'shutter_speed': '1/250',
        'focal_length': '85',
        'is_film': true,
        'film_stock': 'Ilford HP5',
        'film_camera': 'Nikon F3',
        'views_count': 100,
        'likes_count': 25,
        'comments_count': 7,
        'is_public': true,
        'allow_download': false,
        'created_at': '2026-01-15T08:30:00.000Z',
      };

      final model = PhotoModel.fromJson(original);
      final json = model.toJson();

      expect(json['id'], original['id']);
      expect(json['user_id'], original['user_id']);
      expect(json['title'], original['title']);
      expect(json['image_url'], original['image_url']);
      expect(json['camera'], original['camera']);
      expect(json['is_film'], original['is_film']);
      expect(json['film_stock'], original['film_stock']);
      expect(json['allow_download'], original['allow_download']);
    });

    test('nullable fields default correctly', () {
      final json = {
        'id': 'p-null',
        'user_id': 'u-null',
        'image_url': 'https://example.com/null.jpg',
      };

      final model = PhotoModel.fromJson(json);

      expect(model.description, isNull);
      expect(model.caption, isNull);
      expect(model.camera, isNull);
      expect(model.lens, isNull);
      expect(model.iso, isNull);
      expect(model.latitude, isNull);
      expect(model.longitude, isNull);
      expect(model.filmStock, isNull);
      expect(model.filmCamera, isNull);
      expect(model.license, 'CC BY 4.0');
      expect(model.user, isNull);
    });

    test('equality works for identical models', () {
      const model1 = PhotoModel(
        id: 'same',
        userId: 'user',
        imageUrl: 'https://img.jpg',
      );
      const model2 = PhotoModel(
        id: 'same',
        userId: 'user',
        imageUrl: 'https://img.jpg',
      );

      expect(model1, equals(model2));
    });

    test('copyWith creates modified copy', () {
      const original = PhotoModel(
        id: 'p1',
        userId: 'u1',
        imageUrl: 'https://img.jpg',
        title: 'Original',
        viewsCount: 10,
      );

      final modified = original.copyWith(title: 'Modified', viewsCount: 20);

      expect(modified.id, 'p1');
      expect(modified.title, 'Modified');
      expect(modified.viewsCount, 20);
      expect(original.title, 'Original'); // Original unchanged
    });
  });
}
