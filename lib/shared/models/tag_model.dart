import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_model.freezed.dart';
part 'tag_model.g.dart';

@freezed
class TagModel with _$TagModel {
  const factory TagModel({
    required String id,
    required String name,
    @JsonKey(name: 'usage_count') @Default(0) int usageCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _TagModel;

  factory TagModel.fromJson(Map<String, dynamic> json) => _$TagModelFromJson(json);
}
