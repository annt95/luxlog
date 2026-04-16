// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'portfolio_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PortfolioModel _$PortfolioModelFromJson(Map<String, dynamic> json) {
  return _PortfolioModel.fromJson(json);
}

/// @nodoc
mixin _$PortfolioModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get slug => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image')
  String? get coverImage => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_public')
  bool get isPublic => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PortfolioModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PortfolioModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PortfolioModelCopyWith<PortfolioModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PortfolioModelCopyWith<$Res> {
  factory $PortfolioModelCopyWith(
    PortfolioModel value,
    $Res Function(PortfolioModel) then,
  ) = _$PortfolioModelCopyWithImpl<$Res, PortfolioModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String title,
    String? slug,
    @JsonKey(name: 'cover_image') String? coverImage,
    String? bio,
    @JsonKey(name: 'is_public') bool isPublic,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$PortfolioModelCopyWithImpl<$Res, $Val extends PortfolioModel>
    implements $PortfolioModelCopyWith<$Res> {
  _$PortfolioModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PortfolioModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? slug = freezed,
    Object? coverImage = freezed,
    Object? bio = freezed,
    Object? isPublic = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: freezed == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverImage: freezed == coverImage
                ? _value.coverImage
                : coverImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPublic: null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PortfolioModelImplCopyWith<$Res>
    implements $PortfolioModelCopyWith<$Res> {
  factory _$$PortfolioModelImplCopyWith(
    _$PortfolioModelImpl value,
    $Res Function(_$PortfolioModelImpl) then,
  ) = __$$PortfolioModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String title,
    String? slug,
    @JsonKey(name: 'cover_image') String? coverImage,
    String? bio,
    @JsonKey(name: 'is_public') bool isPublic,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$PortfolioModelImplCopyWithImpl<$Res>
    extends _$PortfolioModelCopyWithImpl<$Res, _$PortfolioModelImpl>
    implements _$$PortfolioModelImplCopyWith<$Res> {
  __$$PortfolioModelImplCopyWithImpl(
    _$PortfolioModelImpl _value,
    $Res Function(_$PortfolioModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PortfolioModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? slug = freezed,
    Object? coverImage = freezed,
    Object? bio = freezed,
    Object? isPublic = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$PortfolioModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: freezed == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverImage: freezed == coverImage
            ? _value.coverImage
            : coverImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPublic: null == isPublic
            ? _value.isPublic
            : isPublic // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PortfolioModelImpl implements _PortfolioModel {
  const _$PortfolioModelImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    required this.title,
    this.slug,
    @JsonKey(name: 'cover_image') this.coverImage,
    this.bio,
    @JsonKey(name: 'is_public') this.isPublic = false,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$PortfolioModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PortfolioModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String title;
  @override
  final String? slug;
  @override
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  @override
  final String? bio;
  @override
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PortfolioModel(id: $id, userId: $userId, title: $title, slug: $slug, coverImage: $coverImage, bio: $bio, isPublic: $isPublic, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PortfolioModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    title,
    slug,
    coverImage,
    bio,
    isPublic,
    createdAt,
  );

  /// Create a copy of PortfolioModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PortfolioModelImplCopyWith<_$PortfolioModelImpl> get copyWith =>
      __$$PortfolioModelImplCopyWithImpl<_$PortfolioModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PortfolioModelImplToJson(this);
  }
}

abstract class _PortfolioModel implements PortfolioModel {
  const factory _PortfolioModel({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    required final String title,
    final String? slug,
    @JsonKey(name: 'cover_image') final String? coverImage,
    final String? bio,
    @JsonKey(name: 'is_public') final bool isPublic,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$PortfolioModelImpl;

  factory _PortfolioModel.fromJson(Map<String, dynamic> json) =
      _$PortfolioModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get title;
  @override
  String? get slug;
  @override
  @JsonKey(name: 'cover_image')
  String? get coverImage;
  @override
  String? get bio;
  @override
  @JsonKey(name: 'is_public')
  bool get isPublic;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of PortfolioModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PortfolioModelImplCopyWith<_$PortfolioModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PortfolioProjectModel _$PortfolioProjectModelFromJson(
  Map<String, dynamic> json,
) {
  return _PortfolioProjectModel.fromJson(json);
}

/// @nodoc
mixin _$PortfolioProjectModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'portfolio_id')
  String get portfolioId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image')
  String? get coverImage => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get blocks => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_order')
  int get displayOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'published_at')
  DateTime? get publishedAt => throw _privateConstructorUsedError;

  /// Serializes this PortfolioProjectModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PortfolioProjectModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PortfolioProjectModelCopyWith<PortfolioProjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PortfolioProjectModelCopyWith<$Res> {
  factory $PortfolioProjectModelCopyWith(
    PortfolioProjectModel value,
    $Res Function(PortfolioProjectModel) then,
  ) = _$PortfolioProjectModelCopyWithImpl<$Res, PortfolioProjectModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'portfolio_id') String portfolioId,
    String title,
    String? description,
    @JsonKey(name: 'cover_image') String? coverImage,
    List<Map<String, dynamic>> blocks,
    @JsonKey(name: 'display_order') int displayOrder,
    @JsonKey(name: 'published_at') DateTime? publishedAt,
  });
}

/// @nodoc
class _$PortfolioProjectModelCopyWithImpl<
  $Res,
  $Val extends PortfolioProjectModel
>
    implements $PortfolioProjectModelCopyWith<$Res> {
  _$PortfolioProjectModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PortfolioProjectModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? portfolioId = null,
    Object? title = null,
    Object? description = freezed,
    Object? coverImage = freezed,
    Object? blocks = null,
    Object? displayOrder = null,
    Object? publishedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            portfolioId: null == portfolioId
                ? _value.portfolioId
                : portfolioId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverImage: freezed == coverImage
                ? _value.coverImage
                : coverImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            blocks: null == blocks
                ? _value.blocks
                : blocks // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            publishedAt: freezed == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PortfolioProjectModelImplCopyWith<$Res>
    implements $PortfolioProjectModelCopyWith<$Res> {
  factory _$$PortfolioProjectModelImplCopyWith(
    _$PortfolioProjectModelImpl value,
    $Res Function(_$PortfolioProjectModelImpl) then,
  ) = __$$PortfolioProjectModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'portfolio_id') String portfolioId,
    String title,
    String? description,
    @JsonKey(name: 'cover_image') String? coverImage,
    List<Map<String, dynamic>> blocks,
    @JsonKey(name: 'display_order') int displayOrder,
    @JsonKey(name: 'published_at') DateTime? publishedAt,
  });
}

/// @nodoc
class __$$PortfolioProjectModelImplCopyWithImpl<$Res>
    extends
        _$PortfolioProjectModelCopyWithImpl<$Res, _$PortfolioProjectModelImpl>
    implements _$$PortfolioProjectModelImplCopyWith<$Res> {
  __$$PortfolioProjectModelImplCopyWithImpl(
    _$PortfolioProjectModelImpl _value,
    $Res Function(_$PortfolioProjectModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PortfolioProjectModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? portfolioId = null,
    Object? title = null,
    Object? description = freezed,
    Object? coverImage = freezed,
    Object? blocks = null,
    Object? displayOrder = null,
    Object? publishedAt = freezed,
  }) {
    return _then(
      _$PortfolioProjectModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        portfolioId: null == portfolioId
            ? _value.portfolioId
            : portfolioId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverImage: freezed == coverImage
            ? _value.coverImage
            : coverImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        blocks: null == blocks
            ? _value._blocks
            : blocks // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        publishedAt: freezed == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PortfolioProjectModelImpl implements _PortfolioProjectModel {
  const _$PortfolioProjectModelImpl({
    required this.id,
    @JsonKey(name: 'portfolio_id') required this.portfolioId,
    required this.title,
    this.description,
    @JsonKey(name: 'cover_image') this.coverImage,
    final List<Map<String, dynamic>> blocks = const [],
    @JsonKey(name: 'display_order') this.displayOrder = 0,
    @JsonKey(name: 'published_at') this.publishedAt,
  }) : _blocks = blocks;

  factory _$PortfolioProjectModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PortfolioProjectModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'portfolio_id')
  final String portfolioId;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  final List<Map<String, dynamic>> _blocks;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get blocks {
    if (_blocks is EqualUnmodifiableListView) return _blocks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blocks);
  }

  @override
  @JsonKey(name: 'display_order')
  final int displayOrder;
  @override
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;

  @override
  String toString() {
    return 'PortfolioProjectModel(id: $id, portfolioId: $portfolioId, title: $title, description: $description, coverImage: $coverImage, blocks: $blocks, displayOrder: $displayOrder, publishedAt: $publishedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PortfolioProjectModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.portfolioId, portfolioId) ||
                other.portfolioId == portfolioId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            const DeepCollectionEquality().equals(other._blocks, _blocks) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    portfolioId,
    title,
    description,
    coverImage,
    const DeepCollectionEquality().hash(_blocks),
    displayOrder,
    publishedAt,
  );

  /// Create a copy of PortfolioProjectModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PortfolioProjectModelImplCopyWith<_$PortfolioProjectModelImpl>
  get copyWith =>
      __$$PortfolioProjectModelImplCopyWithImpl<_$PortfolioProjectModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PortfolioProjectModelImplToJson(this);
  }
}

abstract class _PortfolioProjectModel implements PortfolioProjectModel {
  const factory _PortfolioProjectModel({
    required final String id,
    @JsonKey(name: 'portfolio_id') required final String portfolioId,
    required final String title,
    final String? description,
    @JsonKey(name: 'cover_image') final String? coverImage,
    final List<Map<String, dynamic>> blocks,
    @JsonKey(name: 'display_order') final int displayOrder,
    @JsonKey(name: 'published_at') final DateTime? publishedAt,
  }) = _$PortfolioProjectModelImpl;

  factory _PortfolioProjectModel.fromJson(Map<String, dynamic> json) =
      _$PortfolioProjectModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'portfolio_id')
  String get portfolioId;
  @override
  String get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'cover_image')
  String? get coverImage;
  @override
  List<Map<String, dynamic>> get blocks;
  @override
  @JsonKey(name: 'display_order')
  int get displayOrder;
  @override
  @JsonKey(name: 'published_at')
  DateTime? get publishedAt;

  /// Create a copy of PortfolioProjectModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PortfolioProjectModelImplCopyWith<_$PortfolioProjectModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
