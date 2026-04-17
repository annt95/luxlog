// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PhotoModel _$PhotoModelFromJson(Map<String, dynamic> json) {
  return _PhotoModel.fromJson(json);
}

/// @nodoc
mixin _$PhotoModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError; // EXIF
  String? get camera => throw _privateConstructorUsedError;
  String? get lens => throw _privateConstructorUsedError;
  int? get iso => throw _privateConstructorUsedError;
  String? get aperture => throw _privateConstructorUsedError;
  @JsonKey(name: 'shutter_speed')
  String? get shutterSpeed => throw _privateConstructorUsedError;
  @JsonKey(name: 'focal_length')
  String? get focalLength => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude =>
      throw _privateConstructorUsedError; // Film Photography
  @JsonKey(name: 'is_film')
  bool get isFilm => throw _privateConstructorUsedError;
  @JsonKey(name: 'film_stock')
  String? get filmStock => throw _privateConstructorUsedError;
  @JsonKey(name: 'film_camera')
  String? get filmCamera => throw _privateConstructorUsedError; // Meta
  @JsonKey(name: 'views_count')
  int get viewsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'likes_count')
  int get likesCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'comments_count')
  int get commentsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_public')
  bool get isPublic => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_download')
  bool get allowDownload => throw _privateConstructorUsedError;
  String? get license => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError; // Nested User (populated via join)
  UserModel? get user => throw _privateConstructorUsedError;

  /// Serializes this PhotoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoModelCopyWith<PhotoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoModelCopyWith<$Res> {
  factory $PhotoModelCopyWith(
    PhotoModel value,
    $Res Function(PhotoModel) then,
  ) = _$PhotoModelCopyWithImpl<$Res, PhotoModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String? title,
    String? description,
    String? caption,
    @JsonKey(name: 'image_url') String imageUrl,
    int? width,
    int? height,
    String? camera,
    String? lens,
    int? iso,
    String? aperture,
    @JsonKey(name: 'shutter_speed') String? shutterSpeed,
    @JsonKey(name: 'focal_length') String? focalLength,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'is_film') bool isFilm,
    @JsonKey(name: 'film_stock') String? filmStock,
    @JsonKey(name: 'film_camera') String? filmCamera,
    @JsonKey(name: 'views_count') int viewsCount,
    @JsonKey(name: 'likes_count') int likesCount,
    @JsonKey(name: 'comments_count') int commentsCount,
    @JsonKey(name: 'is_public') bool isPublic,
    @JsonKey(name: 'allow_download') bool allowDownload,
    String? license,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    UserModel? user,
  });

  $UserModelCopyWith<$Res>? get user;
}

/// @nodoc
class _$PhotoModelCopyWithImpl<$Res, $Val extends PhotoModel>
    implements $PhotoModelCopyWith<$Res> {
  _$PhotoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? caption = freezed,
    Object? imageUrl = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? camera = freezed,
    Object? lens = freezed,
    Object? iso = freezed,
    Object? aperture = freezed,
    Object? shutterSpeed = freezed,
    Object? focalLength = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isFilm = null,
    Object? filmStock = freezed,
    Object? filmCamera = freezed,
    Object? viewsCount = null,
    Object? likesCount = null,
    Object? commentsCount = null,
    Object? isPublic = null,
    Object? allowDownload = null,
    Object? license = freezed,
    Object? createdAt = freezed,
    Object? user = freezed,
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
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            caption: freezed == caption
                ? _value.caption
                : caption // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            width: freezed == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int?,
            camera: freezed == camera
                ? _value.camera
                : camera // ignore: cast_nullable_to_non_nullable
                      as String?,
            lens: freezed == lens
                ? _value.lens
                : lens // ignore: cast_nullable_to_non_nullable
                      as String?,
            iso: freezed == iso
                ? _value.iso
                : iso // ignore: cast_nullable_to_non_nullable
                      as int?,
            aperture: freezed == aperture
                ? _value.aperture
                : aperture // ignore: cast_nullable_to_non_nullable
                      as String?,
            shutterSpeed: freezed == shutterSpeed
                ? _value.shutterSpeed
                : shutterSpeed // ignore: cast_nullable_to_non_nullable
                      as String?,
            focalLength: freezed == focalLength
                ? _value.focalLength
                : focalLength // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            isFilm: null == isFilm
                ? _value.isFilm
                : isFilm // ignore: cast_nullable_to_non_nullable
                      as bool,
            filmStock: freezed == filmStock
                ? _value.filmStock
                : filmStock // ignore: cast_nullable_to_non_nullable
                      as String?,
            filmCamera: freezed == filmCamera
                ? _value.filmCamera
                : filmCamera // ignore: cast_nullable_to_non_nullable
                      as String?,
            viewsCount: null == viewsCount
                ? _value.viewsCount
                : viewsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            likesCount: null == likesCount
                ? _value.likesCount
                : likesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            commentsCount: null == commentsCount
                ? _value.commentsCount
                : commentsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isPublic: null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                      as bool,
            allowDownload: null == allowDownload
                ? _value.allowDownload
                : allowDownload // ignore: cast_nullable_to_non_nullable
                      as bool,
            license: freezed == license
                ? _value.license
                : license // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PhotoModelImplCopyWith<$Res>
    implements $PhotoModelCopyWith<$Res> {
  factory _$$PhotoModelImplCopyWith(
    _$PhotoModelImpl value,
    $Res Function(_$PhotoModelImpl) then,
  ) = __$$PhotoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String? title,
    String? description,
    String? caption,
    @JsonKey(name: 'image_url') String imageUrl,
    int? width,
    int? height,
    String? camera,
    String? lens,
    int? iso,
    String? aperture,
    @JsonKey(name: 'shutter_speed') String? shutterSpeed,
    @JsonKey(name: 'focal_length') String? focalLength,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'is_film') bool isFilm,
    @JsonKey(name: 'film_stock') String? filmStock,
    @JsonKey(name: 'film_camera') String? filmCamera,
    @JsonKey(name: 'views_count') int viewsCount,
    @JsonKey(name: 'likes_count') int likesCount,
    @JsonKey(name: 'comments_count') int commentsCount,
    @JsonKey(name: 'is_public') bool isPublic,
    @JsonKey(name: 'allow_download') bool allowDownload,
    String? license,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    UserModel? user,
  });

  @override
  $UserModelCopyWith<$Res>? get user;
}

/// @nodoc
class __$$PhotoModelImplCopyWithImpl<$Res>
    extends _$PhotoModelCopyWithImpl<$Res, _$PhotoModelImpl>
    implements _$$PhotoModelImplCopyWith<$Res> {
  __$$PhotoModelImplCopyWithImpl(
    _$PhotoModelImpl _value,
    $Res Function(_$PhotoModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? caption = freezed,
    Object? imageUrl = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? camera = freezed,
    Object? lens = freezed,
    Object? iso = freezed,
    Object? aperture = freezed,
    Object? shutterSpeed = freezed,
    Object? focalLength = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isFilm = null,
    Object? filmStock = freezed,
    Object? filmCamera = freezed,
    Object? viewsCount = null,
    Object? likesCount = null,
    Object? commentsCount = null,
    Object? isPublic = null,
    Object? allowDownload = null,
    Object? license = freezed,
    Object? createdAt = freezed,
    Object? user = freezed,
  }) {
    return _then(
      _$PhotoModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        caption: freezed == caption
            ? _value.caption
            : caption // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        width: freezed == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int?,
        camera: freezed == camera
            ? _value.camera
            : camera // ignore: cast_nullable_to_non_nullable
                  as String?,
        lens: freezed == lens
            ? _value.lens
            : lens // ignore: cast_nullable_to_non_nullable
                  as String?,
        iso: freezed == iso
            ? _value.iso
            : iso // ignore: cast_nullable_to_non_nullable
                  as int?,
        aperture: freezed == aperture
            ? _value.aperture
            : aperture // ignore: cast_nullable_to_non_nullable
                  as String?,
        shutterSpeed: freezed == shutterSpeed
            ? _value.shutterSpeed
            : shutterSpeed // ignore: cast_nullable_to_non_nullable
                  as String?,
        focalLength: freezed == focalLength
            ? _value.focalLength
            : focalLength // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        isFilm: null == isFilm
            ? _value.isFilm
            : isFilm // ignore: cast_nullable_to_non_nullable
                  as bool,
        filmStock: freezed == filmStock
            ? _value.filmStock
            : filmStock // ignore: cast_nullable_to_non_nullable
                  as String?,
        filmCamera: freezed == filmCamera
            ? _value.filmCamera
            : filmCamera // ignore: cast_nullable_to_non_nullable
                  as String?,
        viewsCount: null == viewsCount
            ? _value.viewsCount
            : viewsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        likesCount: null == likesCount
            ? _value.likesCount
            : likesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        commentsCount: null == commentsCount
            ? _value.commentsCount
            : commentsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isPublic: null == isPublic
            ? _value.isPublic
            : isPublic // ignore: cast_nullable_to_non_nullable
                  as bool,
        allowDownload: null == allowDownload
            ? _value.allowDownload
            : allowDownload // ignore: cast_nullable_to_non_nullable
                  as bool,
        license: freezed == license
            ? _value.license
            : license // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoModelImpl implements _PhotoModel {
  const _$PhotoModelImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    this.title,
    this.description,
    this.caption,
    @JsonKey(name: 'image_url') required this.imageUrl,
    this.width,
    this.height,
    this.camera,
    this.lens,
    this.iso,
    this.aperture,
    @JsonKey(name: 'shutter_speed') this.shutterSpeed,
    @JsonKey(name: 'focal_length') this.focalLength,
    this.latitude,
    this.longitude,
    @JsonKey(name: 'is_film') this.isFilm = false,
    @JsonKey(name: 'film_stock') this.filmStock,
    @JsonKey(name: 'film_camera') this.filmCamera,
    @JsonKey(name: 'views_count') this.viewsCount = 0,
    @JsonKey(name: 'likes_count') this.likesCount = 0,
    @JsonKey(name: 'comments_count') this.commentsCount = 0,
    @JsonKey(name: 'is_public') this.isPublic = true,
    @JsonKey(name: 'allow_download') this.allowDownload = true,
    this.license = 'CC BY 4.0',
    @JsonKey(name: 'created_at') this.createdAt,
    this.user,
  });

  factory _$PhotoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? caption;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  final int? width;
  @override
  final int? height;
  // EXIF
  @override
  final String? camera;
  @override
  final String? lens;
  @override
  final int? iso;
  @override
  final String? aperture;
  @override
  @JsonKey(name: 'shutter_speed')
  final String? shutterSpeed;
  @override
  @JsonKey(name: 'focal_length')
  final String? focalLength;
  @override
  final double? latitude;
  @override
  final double? longitude;
  // Film Photography
  @override
  @JsonKey(name: 'is_film')
  final bool isFilm;
  @override
  @JsonKey(name: 'film_stock')
  final String? filmStock;
  @override
  @JsonKey(name: 'film_camera')
  final String? filmCamera;
  // Meta
  @override
  @JsonKey(name: 'views_count')
  final int viewsCount;
  @override
  @JsonKey(name: 'likes_count')
  final int likesCount;
  @override
  @JsonKey(name: 'comments_count')
  final int commentsCount;
  @override
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @override
  @JsonKey(name: 'allow_download')
  final bool allowDownload;
  @override
  @JsonKey()
  final String? license;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  // Nested User (populated via join)
  @override
  final UserModel? user;

  @override
  String toString() {
    return 'PhotoModel(id: $id, userId: $userId, title: $title, description: $description, caption: $caption, imageUrl: $imageUrl, width: $width, height: $height, camera: $camera, lens: $lens, iso: $iso, aperture: $aperture, shutterSpeed: $shutterSpeed, focalLength: $focalLength, latitude: $latitude, longitude: $longitude, isFilm: $isFilm, filmStock: $filmStock, filmCamera: $filmCamera, viewsCount: $viewsCount, likesCount: $likesCount, commentsCount: $commentsCount, isPublic: $isPublic, allowDownload: $allowDownload, license: $license, createdAt: $createdAt, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.camera, camera) || other.camera == camera) &&
            (identical(other.lens, lens) || other.lens == lens) &&
            (identical(other.iso, iso) || other.iso == iso) &&
            (identical(other.aperture, aperture) ||
                other.aperture == aperture) &&
            (identical(other.shutterSpeed, shutterSpeed) ||
                other.shutterSpeed == shutterSpeed) &&
            (identical(other.focalLength, focalLength) ||
                other.focalLength == focalLength) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.isFilm, isFilm) || other.isFilm == isFilm) &&
            (identical(other.filmStock, filmStock) ||
                other.filmStock == filmStock) &&
            (identical(other.filmCamera, filmCamera) ||
                other.filmCamera == filmCamera) &&
            (identical(other.viewsCount, viewsCount) ||
                other.viewsCount == viewsCount) &&
            (identical(other.likesCount, likesCount) ||
                other.likesCount == likesCount) &&
            (identical(other.commentsCount, commentsCount) ||
                other.commentsCount == commentsCount) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.allowDownload, allowDownload) ||
                other.allowDownload == allowDownload) &&
            (identical(other.license, license) || other.license == license) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    userId,
    title,
    description,
    caption,
    imageUrl,
    width,
    height,
    camera,
    lens,
    iso,
    aperture,
    shutterSpeed,
    focalLength,
    latitude,
    longitude,
    isFilm,
    filmStock,
    filmCamera,
    viewsCount,
    likesCount,
    commentsCount,
    isPublic,
    allowDownload,
    license,
    createdAt,
    user,
  ]);

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoModelImplCopyWith<_$PhotoModelImpl> get copyWith =>
      __$$PhotoModelImplCopyWithImpl<_$PhotoModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoModelImplToJson(this);
  }
}

abstract class _PhotoModel implements PhotoModel {
  const factory _PhotoModel({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    final String? title,
    final String? description,
    final String? caption,
    @JsonKey(name: 'image_url') required final String imageUrl,
    final int? width,
    final int? height,
    final String? camera,
    final String? lens,
    final int? iso,
    final String? aperture,
    @JsonKey(name: 'shutter_speed') final String? shutterSpeed,
    @JsonKey(name: 'focal_length') final String? focalLength,
    final double? latitude,
    final double? longitude,
    @JsonKey(name: 'is_film') final bool isFilm,
    @JsonKey(name: 'film_stock') final String? filmStock,
    @JsonKey(name: 'film_camera') final String? filmCamera,
    @JsonKey(name: 'views_count') final int viewsCount,
    @JsonKey(name: 'likes_count') final int likesCount,
    @JsonKey(name: 'comments_count') final int commentsCount,
    @JsonKey(name: 'is_public') final bool isPublic,
    @JsonKey(name: 'allow_download') final bool allowDownload,
    final String? license,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    final UserModel? user,
  }) = _$PhotoModelImpl;

  factory _PhotoModel.fromJson(Map<String, dynamic> json) =
      _$PhotoModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String? get title;
  @override
  String? get description;
  @override
  String? get caption;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  int? get width;
  @override
  int? get height; // EXIF
  @override
  String? get camera;
  @override
  String? get lens;
  @override
  int? get iso;
  @override
  String? get aperture;
  @override
  @JsonKey(name: 'shutter_speed')
  String? get shutterSpeed;
  @override
  @JsonKey(name: 'focal_length')
  String? get focalLength;
  @override
  double? get latitude;
  @override
  double? get longitude; // Film Photography
  @override
  @JsonKey(name: 'is_film')
  bool get isFilm;
  @override
  @JsonKey(name: 'film_stock')
  String? get filmStock;
  @override
  @JsonKey(name: 'film_camera')
  String? get filmCamera; // Meta
  @override
  @JsonKey(name: 'views_count')
  int get viewsCount;
  @override
  @JsonKey(name: 'likes_count')
  int get likesCount;
  @override
  @JsonKey(name: 'comments_count')
  int get commentsCount;
  @override
  @JsonKey(name: 'is_public')
  bool get isPublic;
  @override
  @JsonKey(name: 'allow_download')
  bool get allowDownload;
  @override
  String? get license;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt; // Nested User (populated via join)
  @override
  UserModel? get user;

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoModelImplCopyWith<_$PhotoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
