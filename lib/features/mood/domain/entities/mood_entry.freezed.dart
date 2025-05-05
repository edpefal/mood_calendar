// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mood_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MoodEntry _$MoodEntryFromJson(Map<String, dynamic> json) {
  return _MoodEntry.fromJson(json);
}

/// @nodoc
mixin _$MoodEntry {
  DateTime get date => throw _privateConstructorUsedError;
  String get mood => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  int get intensity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MoodEntryCopyWith<MoodEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MoodEntryCopyWith<$Res> {
  factory $MoodEntryCopyWith(MoodEntry value, $Res Function(MoodEntry) then) =
      _$MoodEntryCopyWithImpl<$Res, MoodEntry>;
  @useResult
  $Res call({DateTime date, String mood, String? note, int intensity});
}

/// @nodoc
class _$MoodEntryCopyWithImpl<$Res, $Val extends MoodEntry>
    implements $MoodEntryCopyWith<$Res> {
  _$MoodEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? mood = null,
    Object? note = freezed,
    Object? intensity = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      mood: null == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MoodEntryImplCopyWith<$Res>
    implements $MoodEntryCopyWith<$Res> {
  factory _$$MoodEntryImplCopyWith(
          _$MoodEntryImpl value, $Res Function(_$MoodEntryImpl) then) =
      __$$MoodEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, String mood, String? note, int intensity});
}

/// @nodoc
class __$$MoodEntryImplCopyWithImpl<$Res>
    extends _$MoodEntryCopyWithImpl<$Res, _$MoodEntryImpl>
    implements _$$MoodEntryImplCopyWith<$Res> {
  __$$MoodEntryImplCopyWithImpl(
      _$MoodEntryImpl _value, $Res Function(_$MoodEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? mood = null,
    Object? note = freezed,
    Object? intensity = null,
  }) {
    return _then(_$MoodEntryImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      mood: null == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MoodEntryImpl implements _MoodEntry {
  const _$MoodEntryImpl(
      {required this.date,
      required this.mood,
      this.note,
      required this.intensity});

  factory _$MoodEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MoodEntryImplFromJson(json);

  @override
  final DateTime date;
  @override
  final String mood;
  @override
  final String? note;
  @override
  final int intensity;

  @override
  String toString() {
    return 'MoodEntry(date: $date, mood: $mood, note: $note, intensity: $intensity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MoodEntryImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.intensity, intensity) ||
                other.intensity == intensity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, date, mood, note, intensity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MoodEntryImplCopyWith<_$MoodEntryImpl> get copyWith =>
      __$$MoodEntryImplCopyWithImpl<_$MoodEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MoodEntryImplToJson(
      this,
    );
  }
}

abstract class _MoodEntry implements MoodEntry {
  const factory _MoodEntry(
      {required final DateTime date,
      required final String mood,
      final String? note,
      required final int intensity}) = _$MoodEntryImpl;

  factory _MoodEntry.fromJson(Map<String, dynamic> json) =
      _$MoodEntryImpl.fromJson;

  @override
  DateTime get date;
  @override
  String get mood;
  @override
  String? get note;
  @override
  int get intensity;
  @override
  @JsonKey(ignore: true)
  _$$MoodEntryImplCopyWith<_$MoodEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
