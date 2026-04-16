import 'package:freezed_annotation/freezed_annotation.dart';

part 'portfolio_model.freezed.dart';
part 'portfolio_model.g.dart';

@freezed
class PortfolioModel with _$PortfolioModel {
  const factory PortfolioModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    String? slug,
    @JsonKey(name: 'cover_image') String? coverImage,
    String? bio,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _PortfolioModel;

  factory PortfolioModel.fromJson(Map<String, dynamic> json) => _$PortfolioModelFromJson(json);
}

@freezed
class PortfolioProjectModel with _$PortfolioProjectModel {
  const factory PortfolioProjectModel({
    required String id,
    @JsonKey(name: 'portfolio_id') required String portfolioId,
    required String title,
    String? description,
    @JsonKey(name: 'cover_image') String? coverImage,
    @Default([]) List<Map<String, dynamic>> blocks,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'published_at') DateTime? publishedAt,
  }) = _PortfolioProjectModel;

  factory PortfolioProjectModel.fromJson(Map<String, dynamic> json) => _$PortfolioProjectModelFromJson(json);
}
