import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    required String slug,
    String? icon,
    @JsonKey(name: 'cover_image') String? coverImage,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @Default('approved') String status, // 'approved', 'pending', 'rejected'
    @JsonKey(name: 'suggested_by') String? suggestedBy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => _$CategoryModelFromJson(json);
}
