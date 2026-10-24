// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'decision.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DecisionOption {

 String get id; String get label; DecisionOptionKind get kind;
/// Create a copy of DecisionOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DecisionOptionCopyWith<DecisionOption> get copyWith => _$DecisionOptionCopyWithImpl<DecisionOption>(this as DecisionOption, _$identity);

  /// Serializes this DecisionOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DecisionOption;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DecisionOption&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.kind, _this.kind) || other.kind == _this.kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DecisionOption;
  return Object.hash(runtimeType,_this.id,_this.label,_this.kind);
}

@override
String toString() {
  final _this = this as DecisionOption;
  return 'DecisionOption(id: ${_this.id}, label: ${_this.label}, kind: ${_this.kind})';
}


}

/// @nodoc
abstract mixin class $DecisionOptionCopyWith<$Res>  {
  factory $DecisionOptionCopyWith(DecisionOption value, $Res Function(DecisionOption) _then) = _$DecisionOptionCopyWithImpl;
@useResult
$Res call({
 String id, String label, DecisionOptionKind kind
});




}
/// @nodoc
class _$DecisionOptionCopyWithImpl<$Res>
    implements $DecisionOptionCopyWith<$Res> {
  _$DecisionOptionCopyWithImpl(this._self, this._then);

  final DecisionOption _self;
  final $Res Function(DecisionOption) _then;

/// Create a copy of DecisionOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? kind = null,}) {
  return _then(DecisionOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DecisionOptionKind,
  ));
}

}


/// Adds pattern-matching-related methods to [DecisionOption].
extension DecisionOptionPatterns on DecisionOption {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DecisionOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DecisionOption() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DecisionOption value)  $default,){
final _that = this;
switch (_that) {
case _DecisionOption():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DecisionOption value)?  $default,){
final _that = this;
switch (_that) {
case _DecisionOption() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  DecisionOptionKind kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DecisionOption() when $default != null:
return $default(_that.id,_that.label,_that.kind);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  DecisionOptionKind kind)  $default,) {final _that = this;
switch (_that) {
case _DecisionOption():
return $default(_that.id,_that.label,_that.kind);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  DecisionOptionKind kind)?  $default,) {final _that = this;
switch (_that) {
case _DecisionOption() when $default != null:
return $default(_that.id,_that.label,_that.kind);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DecisionOption implements DecisionOption {
  const _DecisionOption({required this.id, required this.label, required this.kind});
  factory _DecisionOption.fromJson(Map<String, dynamic> json) => _$DecisionOptionFromJson(json);

@override final  String id;
@override final  String label;
@override final  DecisionOptionKind kind;

/// Create a copy of DecisionOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecisionOptionCopyWith<_DecisionOption> get copyWith => __$DecisionOptionCopyWithImpl<_DecisionOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DecisionOptionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DecisionOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,kind);
}

@override
String toString() {
    return 'DecisionOption(id: $id, label: $label, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$DecisionOptionCopyWith<$Res> implements $DecisionOptionCopyWith<$Res> {
  factory _$DecisionOptionCopyWith(_DecisionOption value, $Res Function(_DecisionOption) _then) = __$DecisionOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, DecisionOptionKind kind
});




}
/// @nodoc
class __$DecisionOptionCopyWithImpl<$Res>
    implements _$DecisionOptionCopyWith<$Res> {
  __$DecisionOptionCopyWithImpl(this._self, this._then);

  final _DecisionOption _self;
  final $Res Function(_DecisionOption) _then;

/// Create a copy of DecisionOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? kind = null,}) {
  return _then(_DecisionOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DecisionOptionKind,
  ));
}


}

/// @nodoc
mixin _$Decision {

 String get id; String get prompt; List<DecisionOption> get options; DateTime get createdAt; DecisionState get state; String? get detail; String? get chosenOptionId;/// True when the action is irreversible or reaches outside the workspace.
/// The approval sheet is then marked.
 bool get highImpact;
/// Create a copy of Decision
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DecisionCopyWith<Decision> get copyWith => _$DecisionCopyWithImpl<Decision>(this as Decision, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Decision;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Decision&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.prompt, _this.prompt) || other.prompt == _this.prompt)&&const DeepCollectionEquality().equals(other.options, _this.options)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.detail, _this.detail) || other.detail == _this.detail)&&(identical(other.chosenOptionId, _this.chosenOptionId) || other.chosenOptionId == _this.chosenOptionId)&&(identical(other.highImpact, _this.highImpact) || other.highImpact == _this.highImpact));
}


@override
int get hashCode {
  final _this = this as Decision;
  return Object.hash(runtimeType,_this.id,_this.prompt,const DeepCollectionEquality().hash(_this.options),_this.createdAt,_this.state,_this.detail,_this.chosenOptionId,_this.highImpact);
}

@override
String toString() {
  final _this = this as Decision;
  return 'Decision(id: ${_this.id}, prompt: ${_this.prompt}, options: ${_this.options}, createdAt: ${_this.createdAt}, state: ${_this.state}, detail: ${_this.detail}, chosenOptionId: ${_this.chosenOptionId}, highImpact: ${_this.highImpact})';
}


}

/// @nodoc
abstract mixin class $DecisionCopyWith<$Res>  {
  factory $DecisionCopyWith(Decision value, $Res Function(Decision) _then) = _$DecisionCopyWithImpl;
@useResult
$Res call({
 String id, String prompt, List<DecisionOption> options, DateTime createdAt, DecisionState state, String? detail, String? chosenOptionId, bool highImpact
});




}
/// @nodoc
class _$DecisionCopyWithImpl<$Res>
    implements $DecisionCopyWith<$Res> {
  _$DecisionCopyWithImpl(this._self, this._then);

  final Decision _self;
  final $Res Function(Decision) _then;

/// Create a copy of Decision
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? prompt = null,Object? options = null,Object? createdAt = null,Object? state = null,Object? detail = freezed,Object? chosenOptionId = freezed,Object? highImpact = null,}) {
  return _then(Decision(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<DecisionOption>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DecisionState,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,chosenOptionId: freezed == chosenOptionId ? _self.chosenOptionId : chosenOptionId // ignore: cast_nullable_to_non_nullable
as String?,highImpact: null == highImpact ? _self.highImpact : highImpact // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Decision].
extension DecisionPatterns on Decision {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Decision value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Decision() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Decision value)  $default,){
final _that = this;
switch (_that) {
case _Decision():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Decision value)?  $default,){
final _that = this;
switch (_that) {
case _Decision() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String prompt,  List<DecisionOption> options,  DateTime createdAt,  DecisionState state,  String? detail,  String? chosenOptionId,  bool highImpact)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Decision() when $default != null:
return $default(_that.id,_that.prompt,_that.options,_that.createdAt,_that.state,_that.detail,_that.chosenOptionId,_that.highImpact);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String prompt,  List<DecisionOption> options,  DateTime createdAt,  DecisionState state,  String? detail,  String? chosenOptionId,  bool highImpact)  $default,) {final _that = this;
switch (_that) {
case _Decision():
return $default(_that.id,_that.prompt,_that.options,_that.createdAt,_that.state,_that.detail,_that.chosenOptionId,_that.highImpact);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String prompt,  List<DecisionOption> options,  DateTime createdAt,  DecisionState state,  String? detail,  String? chosenOptionId,  bool highImpact)?  $default,) {final _that = this;
switch (_that) {
case _Decision() when $default != null:
return $default(_that.id,_that.prompt,_that.options,_that.createdAt,_that.state,_that.detail,_that.chosenOptionId,_that.highImpact);case _:
  return null;

}
}

}

/// @nodoc


class _Decision extends Decision {
  const _Decision({required this.id, required this.prompt, required  List<DecisionOption> options, required this.createdAt, this.state = DecisionState.pending, this.detail, this.chosenOptionId, this.highImpact = false}): _options = options,super._();
  

@override final  String id;
@override final  String prompt;
 final  List<DecisionOption> _options;
@override List<DecisionOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@override final  DateTime createdAt;
@override@JsonKey() final  DecisionState state;
@override final  String? detail;
@override final  String? chosenOptionId;
/// True when the action is irreversible or reaches outside the workspace.
/// The approval sheet is then marked.
@override@JsonKey() final  bool highImpact;

/// Create a copy of Decision
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecisionCopyWith<_Decision> get copyWith => __$DecisionCopyWithImpl<_Decision>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Decision&&(identical(other.id, id) || other.id == id)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&const DeepCollectionEquality().equals(other.options, _options)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.state, state) || other.state == state)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.chosenOptionId, chosenOptionId) || other.chosenOptionId == chosenOptionId)&&(identical(other.highImpact, highImpact) || other.highImpact == highImpact));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,prompt,const DeepCollectionEquality().hash(_options),createdAt,state,detail,chosenOptionId,highImpact);
}

@override
String toString() {
    return 'Decision(id: $id, prompt: $prompt, options: $options, createdAt: $createdAt, state: $state, detail: $detail, chosenOptionId: $chosenOptionId, highImpact: $highImpact)';
}


}

/// @nodoc
abstract mixin class _$DecisionCopyWith<$Res> implements $DecisionCopyWith<$Res> {
  factory _$DecisionCopyWith(_Decision value, $Res Function(_Decision) _then) = __$DecisionCopyWithImpl;
@override @useResult
$Res call({
 String id, String prompt, List<DecisionOption> options, DateTime createdAt, DecisionState state, String? detail, String? chosenOptionId, bool highImpact
});




}
/// @nodoc
class __$DecisionCopyWithImpl<$Res>
    implements _$DecisionCopyWith<$Res> {
  __$DecisionCopyWithImpl(this._self, this._then);

  final _Decision _self;
  final $Res Function(_Decision) _then;

/// Create a copy of Decision
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? prompt = null,Object? options = null,Object? createdAt = null,Object? state = null,Object? detail = freezed,Object? chosenOptionId = freezed,Object? highImpact = null,}) {
  return _then(_Decision(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<DecisionOption>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DecisionState,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,chosenOptionId: freezed == chosenOptionId ? _self.chosenOptionId : chosenOptionId // ignore: cast_nullable_to_non_nullable
as String?,highImpact: null == highImpact ? _self.highImpact : highImpact // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
