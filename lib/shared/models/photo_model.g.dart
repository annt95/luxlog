// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoModelImpl _$$PhotoModelImplFromJson(Map<String, dynamic> json) =>
    _$PhotoModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      caption: json['caption'] as String?,
      imageUrl: json['image_url'] as String,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      camera: json['camera'] as String?,
      lens: json['lens'] as String?,
      iso: (json['iso'] as num?)?.toInt(),
      aperture: json['aperture'] as String?,
      shutterSpeed: json['shutter_speed'] as String?,
      focalLength: json['focal_length'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isFilm: json['is_film'] as bool? ?? false,
      filmStock: json['film_stock'] as String?,
      filmCamera: json['film_camera'] as String?,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      isPublic: json['is_public'] as bool? ?? true,
      allowDownload: json['allow_download'] as bool? ?? true,
      license: json['license'] as String? ?? 'CC BY 4.0',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PhotoModelImplToJson(_$PhotoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'caption': instance.caption,
      'image_url': instance.imageUrl,
      'width': instance.width,
      'height': instance.height,
      'camera': instance.camera,
      'lens': instance.lens,
      'iso': instance.iso,
      'aperture': instance.aperture,
      'shutter_speed': instance.shutterSpeed,
      'focal_length': instance.focalLength,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'is_film': instance.isFilm,
      'film_stock': instance.filmStock,
      'film_camera': instance.filmCamera,
      'views_count': instance.viewsCount,
      'likes_count': instance.likesCount,
      'comments_count': instance.commentsCount,
      'is_public': instance.isPublic,
      'allow_download': instance.allowDownload,
      'license': instance.license,
      'created_at': instance.createdAt?.toIso8601String(),
      'user': instance.user,
    };
