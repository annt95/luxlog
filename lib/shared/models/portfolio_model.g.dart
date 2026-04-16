// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PortfolioModelImpl _$$PortfolioModelImplFromJson(Map<String, dynamic> json) =>
    _$PortfolioModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String?,
      coverImage: json['cover_image'] as String?,
      bio: json['bio'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$PortfolioModelImplToJson(
  _$PortfolioModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'slug': instance.slug,
  'cover_image': instance.coverImage,
  'bio': instance.bio,
  'is_public': instance.isPublic,
  'created_at': instance.createdAt?.toIso8601String(),
};

_$PortfolioProjectModelImpl _$$PortfolioProjectModelImplFromJson(
  Map<String, dynamic> json,
) => _$PortfolioProjectModelImpl(
  id: json['id'] as String,
  portfolioId: json['portfolio_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  coverImage: json['cover_image'] as String?,
  blocks:
      (json['blocks'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
);

Map<String, dynamic> _$$PortfolioProjectModelImplToJson(
  _$PortfolioProjectModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'portfolio_id': instance.portfolioId,
  'title': instance.title,
  'description': instance.description,
  'cover_image': instance.coverImage,
  'blocks': instance.blocks,
  'display_order': instance.displayOrder,
  'published_at': instance.publishedAt?.toIso8601String(),
};
