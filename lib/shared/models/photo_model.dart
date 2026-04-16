import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luxlog/shared/models/user_model.dart';

part 'photo_model.freezed.dart';
part 'photo_model.g.dart';

@freezed
class PhotoModel with _$PhotoModel {
  const factory PhotoModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    String? title,
    String? description,
    @JsonKey(name: 'image_url') required String imageUrl,
    int? width,
    int? height,
    
    // EXIF
    String? camera,
    String? lens,
    int? iso,
    String? aperture,
    @JsonKey(name: 'shutter_speed') String? shutterSpeed,
    @JsonKey(name: 'focal_length') String? focalLength,
    double? latitude,
    double? longitude,
    
    // Meta
    @JsonKey(name: 'views_count') @Default(0) int viewsCount,
    @JsonKey(name: 'likes_count') @Default(0) int likesCount,
    @JsonKey(name: 'comments_count') @Default(0) int commentsCount,
    @JsonKey(name: 'is_public') @Default(true) bool isPublic,
    @JsonKey(name: 'created_at') DateTime? createdAt,

    // Nested User (populated via join)
    UserModel? user,
  }) = _PhotoModel;

  factory PhotoModel.fromJson(Map<String, dynamic> json) => _$PhotoModelFromJson(json);
}
