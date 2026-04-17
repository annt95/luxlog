// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryModelImpl _$$CategoryModelImplFromJson(Map<String, dynamic> json) =>
    _$CategoryModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      coverImage: json['cover_image'] as String?,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'approved',
      suggestedBy: json['suggested_by'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$CategoryModelImplToJson(_$CategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'icon': instance.icon,
      'cover_image': instance.coverImage,
      'display_order': instance.displayOrder,
      'status': instance.status,
      'suggested_by': instance.suggestedBy,
      'created_at': instance.createdAt?.toIso8601String(),
    };
