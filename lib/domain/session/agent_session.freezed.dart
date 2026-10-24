// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AgentCapabilities {

 bool get canLoadSession; bool get canListSessions; bool get canDeleteSession;
/// Create a copy of AgentCapabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentCapabilitiesCopyWith<AgentCapabilities> get copyWith => _$AgentCapabilitiesCopyWithImpl<AgentCapabilities>(this as AgentCapabilities, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AgentCapabilities;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentCapabilities&&(identical(other.canLoadSession, _this.canLoadSession) || other.canLoadSession == _this.canLoadSession)&&(identical(other.canListSessions, _this.canListSessions) || other.canListSessions == _this.canListSessions)&&(identical(other.canDeleteSession, _this.canDeleteSession) || other.canDeleteSession == _this.canDeleteSession));
}


@override
int get hashCode {
  final _this = this as AgentCapabilities;
  return Object.hash(runtimeType,_this.canLoadSession,_this.canListSessions,_this.canDeleteSession);
}

@override
String toString() {
  final _this = this as AgentCapabilities;
  return 'AgentCapabilities(canLoadSession: ${_this.canLoadSession}, canListSessions: ${_this.canListSessions}, canDeleteSession: ${_this.canDeleteSession})';
}


}

/// @nodoc
abstract mixin class $AgentCapabilitiesCopyWith<$Res>  {
  factory $AgentCapabilitiesCopyWith(AgentCapabilities value, $Res Function(AgentCapabilities) _then) = _$AgentCapabilitiesCopyWithImpl;
@useResult
$Res call({
 bool canLoadSession, bool canListSessions, bool canDeleteSession
});




}
/// @nodoc
class _$AgentCapabilitiesCopyWithImpl<$Res>
    implements $AgentCapabilitiesCopyWith<$Res> {
  _$AgentCapabilitiesCopyWithImpl(this._self, this._then);

  final AgentCapabilities _self;
  final $Res Function(AgentCapabilities) _then;

/// Create a copy of AgentCapabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? canLoadSession = null,Object? canListSessions = null,Object? canDeleteSession = null,}) {
  return _then(AgentCapabilities(
canLoadSession: null == canLoadSession ? _self.canLoadSession : canLoadSession // ignore: cast_nullable_to_non_nullable
as bool,canListSessions: null == canListSessions ? _self.canListSessions : canListSessions // ignore: cast_nullable_to_non_nullable
as bool,canDeleteSession: null == canDeleteSession ? _self.canDeleteSession : canDeleteSession // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AgentCapabilities].
extension AgentCapabilitiesPatterns on AgentCapabilities {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentCapabilities value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentCapabilities() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentCapabilities value)  $default,){
final _that = this;
switch (_that) {
case _AgentCapabilities():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentCapabilities value)?  $default,){
final _that = this;
switch (_that) {
case _AgentCapabilities() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool canLoadSession,  bool canListSessions,  bool canDeleteSession)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentCapabilities() when $default != null:
return $default(_that.canLoadSession,_that.canListSessions,_that.canDeleteSession);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool canLoadSession,  bool canListSessions,  bool canDeleteSession)  $default,) {final _that = this;
switch (_that) {
case _AgentCapabilities():
return $default(_that.canLoadSession,_that.canListSessions,_that.canDeleteSession);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool canLoadSession,  bool canListSessions,  bool canDeleteSession)?  $default,) {final _that = this;
switch (_that) {
case _AgentCapabilities() when $default != null:
return $default(_that.canLoadSession,_that.canListSessions,_that.canDeleteSession);case _:
  return null;

}
}

}

/// @nodoc


class _AgentCapabilities implements AgentCapabilities {
  const _AgentCapabilities({this.canLoadSession = false, this.canListSessions = false, this.canDeleteSession = false});
  

@override@JsonKey() final  bool canLoadSession;
@override@JsonKey() final  bool canListSessions;
@override@JsonKey() final  bool canDeleteSession;

/// Create a copy of AgentCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentCapabilitiesCopyWith<_AgentCapabilities> get copyWith => __$AgentCapabilitiesCopyWithImpl<_AgentCapabilities>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentCapabilities&&(identical(other.canLoadSession, canLoadSession) || other.canLoadSession == canLoadSession)&&(identical(other.canListSessions, canListSessions) || other.canListSessions == canListSessions)&&(identical(other.canDeleteSession, canDeleteSession) || other.canDeleteSession == canDeleteSession));
}


@override
int get hashCode {
    return Object.hash(runtimeType,canLoadSession,canListSessions,canDeleteSession);
}

@override
String toString() {
    return 'AgentCapabilities(canLoadSession: $canLoadSession, canListSessions: $canListSessions, canDeleteSession: $canDeleteSession)';
}


}

/// @nodoc
abstract mixin class _$AgentCapabilitiesCopyWith<$Res> implements $AgentCapabilitiesCopyWith<$Res> {
  factory _$AgentCapabilitiesCopyWith(_AgentCapabilities value, $Res Function(_AgentCapabilities) _then) = __$AgentCapabilitiesCopyWithImpl;
@override @useResult
$Res call({
 bool canLoadSession, bool canListSessions, bool canDeleteSession
});




}
/// @nodoc
class __$AgentCapabilitiesCopyWithImpl<$Res>
    implements _$AgentCapabilitiesCopyWith<$Res> {
  __$AgentCapabilitiesCopyWithImpl(this._self, this._then);

  final _AgentCapabilities _self;
  final $Res Function(_AgentCapabilities) _then;

/// Create a copy of AgentCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? canLoadSession = null,Object? canListSessions = null,Object? canDeleteSession = null,}) {
  return _then(_AgentCapabilities(
canLoadSession: null == canLoadSession ? _self.canLoadSession : canLoadSession // ignore: cast_nullable_to_non_nullable
as bool,canListSessions: null == canListSessions ? _self.canListSessions : canListSessions // ignore: cast_nullable_to_non_nullable
as bool,canDeleteSession: null == canDeleteSession ? _self.canDeleteSession : canDeleteSession // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$AgentSessionSummary {

 String get id; String get cwd; String get title; DateTime? get updatedAt;
/// Create a copy of AgentSessionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentSessionSummaryCopyWith<AgentSessionSummary> get copyWith => _$AgentSessionSummaryCopyWithImpl<AgentSessionSummary>(this as AgentSessionSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AgentSessionSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentSessionSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.cwd, _this.cwd) || other.cwd == _this.cwd)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as AgentSessionSummary;
  return Object.hash(runtimeType,_this.id,_this.cwd,_this.title,_this.updatedAt);
}

@override
String toString() {
  final _this = this as AgentSessionSummary;
  return 'AgentSessionSummary(id: ${_this.id}, cwd: ${_this.cwd}, title: ${_this.title}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $AgentSessionSummaryCopyWith<$Res>  {
  factory $AgentSessionSummaryCopyWith(AgentSessionSummary value, $Res Function(AgentSessionSummary) _then) = _$AgentSessionSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String cwd, String title, DateTime? updatedAt
});




}
/// @nodoc
class _$AgentSessionSummaryCopyWithImpl<$Res>
    implements $AgentSessionSummaryCopyWith<$Res> {
  _$AgentSessionSummaryCopyWithImpl(this._self, this._then);

  final AgentSessionSummary _self;
  final $Res Function(AgentSessionSummary) _then;

/// Create a copy of AgentSessionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cwd = null,Object? title = null,Object? updatedAt = freezed,}) {
  return _then(AgentSessionSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AgentSessionSummary].
extension AgentSessionSummaryPatterns on AgentSessionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentSessionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentSessionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentSessionSummary value)  $default,){
final _that = this;
switch (_that) {
case _AgentSessionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentSessionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AgentSessionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String cwd,  String title,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentSessionSummary() when $default != null:
return $default(_that.id,_that.cwd,_that.title,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String cwd,  String title,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AgentSessionSummary():
return $default(_that.id,_that.cwd,_that.title,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String cwd,  String title,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AgentSessionSummary() when $default != null:
return $default(_that.id,_that.cwd,_that.title,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AgentSessionSummary extends AgentSessionSummary {
  const _AgentSessionSummary({required this.id, this.cwd = '', this.title = '', this.updatedAt}): super._();
  

@override final  String id;
@override@JsonKey() final  String cwd;
@override@JsonKey() final  String title;
@override final  DateTime? updatedAt;

/// Create a copy of AgentSessionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentSessionSummaryCopyWith<_AgentSessionSummary> get copyWith => __$AgentSessionSummaryCopyWithImpl<_AgentSessionSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentSessionSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.title, title) || other.title == title)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,cwd,title,updatedAt);
}

@override
String toString() {
    return 'AgentSessionSummary(id: $id, cwd: $cwd, title: $title, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AgentSessionSummaryCopyWith<$Res> implements $AgentSessionSummaryCopyWith<$Res> {
  factory _$AgentSessionSummaryCopyWith(_AgentSessionSummary value, $Res Function(_AgentSessionSummary) _then) = __$AgentSessionSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String cwd, String title, DateTime? updatedAt
});




}
/// @nodoc
class __$AgentSessionSummaryCopyWithImpl<$Res>
    implements _$AgentSessionSummaryCopyWith<$Res> {
  __$AgentSessionSummaryCopyWithImpl(this._self, this._then);

  final _AgentSessionSummary _self;
  final $Res Function(_AgentSessionSummary) _then;

/// Create a copy of AgentSessionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cwd = null,Object? title = null,Object? updatedAt = freezed,}) {
  return _then(_AgentSessionSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$AgentSession {

 String get id; String get cwd;
/// Create a copy of AgentSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentSessionCopyWith<AgentSession> get copyWith => _$AgentSessionCopyWithImpl<AgentSession>(this as AgentSession, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AgentSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.cwd, _this.cwd) || other.cwd == _this.cwd));
}


@override
int get hashCode {
  final _this = this as AgentSession;
  return Object.hash(runtimeType,_this.id,_this.cwd);
}

@override
String toString() {
  final _this = this as AgentSession;
  return 'AgentSession(id: ${_this.id}, cwd: ${_this.cwd})';
}


}

/// @nodoc
abstract mixin class $AgentSessionCopyWith<$Res>  {
  factory $AgentSessionCopyWith(AgentSession value, $Res Function(AgentSession) _then) = _$AgentSessionCopyWithImpl;
@useResult
$Res call({
 String id, String cwd
});




}
/// @nodoc
class _$AgentSessionCopyWithImpl<$Res>
    implements $AgentSessionCopyWith<$Res> {
  _$AgentSessionCopyWithImpl(this._self, this._then);

  final AgentSession _self;
  final $Res Function(AgentSession) _then;

/// Create a copy of AgentSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cwd = null,}) {
  return _then(AgentSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AgentSession].
extension AgentSessionPatterns on AgentSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentSession value)  $default,){
final _that = this;
switch (_that) {
case _AgentSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentSession value)?  $default,){
final _that = this;
switch (_that) {
case _AgentSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String cwd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentSession() when $default != null:
return $default(_that.id,_that.cwd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String cwd)  $default,) {final _that = this;
switch (_that) {
case _AgentSession():
return $default(_that.id,_that.cwd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String cwd)?  $default,) {final _that = this;
switch (_that) {
case _AgentSession() when $default != null:
return $default(_that.id,_that.cwd);case _:
  return null;

}
}

}

/// @nodoc


class _AgentSession implements AgentSession {
  const _AgentSession({required this.id, required this.cwd});
  

@override final  String id;
@override final  String cwd;

/// Create a copy of AgentSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentSessionCopyWith<_AgentSession> get copyWith => __$AgentSessionCopyWithImpl<_AgentSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentSession&&(identical(other.id, id) || other.id == id)&&(identical(other.cwd, cwd) || other.cwd == cwd));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,cwd);
}

@override
String toString() {
    return 'AgentSession(id: $id, cwd: $cwd)';
}


}

/// @nodoc
abstract mixin class _$AgentSessionCopyWith<$Res> implements $AgentSessionCopyWith<$Res> {
  factory _$AgentSessionCopyWith(_AgentSession value, $Res Function(_AgentSession) _then) = __$AgentSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String cwd
});




}
/// @nodoc
class __$AgentSessionCopyWithImpl<$Res>
    implements _$AgentSessionCopyWith<$Res> {
  __$AgentSessionCopyWithImpl(this._self, this._then);

  final _AgentSession _self;
  final $Res Function(_AgentSession) _then;

/// Create a copy of AgentSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cwd = null,}) {
  return _then(_AgentSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SessionOption {

 String get id; String get label;
/// Create a copy of SessionOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionOptionCopyWith<SessionOption> get copyWith => _$SessionOptionCopyWithImpl<SessionOption>(this as SessionOption, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SessionOption;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionOption&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label));
}


@override
int get hashCode {
  final _this = this as SessionOption;
  return Object.hash(runtimeType,_this.id,_this.label);
}

@override
String toString() {
  final _this = this as SessionOption;
  return 'SessionOption(id: ${_this.id}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $SessionOptionCopyWith<$Res>  {
  factory $SessionOptionCopyWith(SessionOption value, $Res Function(SessionOption) _then) = _$SessionOptionCopyWithImpl;
@useResult
$Res call({
 String id, String label
});




}
/// @nodoc
class _$SessionOptionCopyWithImpl<$Res>
    implements $SessionOptionCopyWith<$Res> {
  _$SessionOptionCopyWithImpl(this._self, this._then);

  final SessionOption _self;
  final $Res Function(SessionOption) _then;

/// Create a copy of SessionOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,}) {
  return _then(SessionOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionOption].
extension SessionOptionPatterns on SessionOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionOption value)  $default,){
final _that = this;
switch (_that) {
case _SessionOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionOption value)?  $default,){
final _that = this;
switch (_that) {
case _SessionOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionOption() when $default != null:
return $default(_that.id,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label)  $default,) {final _that = this;
switch (_that) {
case _SessionOption():
return $default(_that.id,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label)?  $default,) {final _that = this;
switch (_that) {
case _SessionOption() when $default != null:
return $default(_that.id,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _SessionOption implements SessionOption {
  const _SessionOption({required this.id, required this.label});
  

@override final  String id;
@override final  String label;

/// Create a copy of SessionOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionOptionCopyWith<_SessionOption> get copyWith => __$SessionOptionCopyWithImpl<_SessionOption>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,label);
}

@override
String toString() {
    return 'SessionOption(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class _$SessionOptionCopyWith<$Res> implements $SessionOptionCopyWith<$Res> {
  factory _$SessionOptionCopyWith(_SessionOption value, $Res Function(_SessionOption) _then) = __$SessionOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String label
});




}
/// @nodoc
class __$SessionOptionCopyWithImpl<$Res>
    implements _$SessionOptionCopyWith<$Res> {
  __$SessionOptionCopyWithImpl(this._self, this._then);

  final _SessionOption _self;
  final $Res Function(_SessionOption) _then;

/// Create a copy of SessionOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,}) {
  return _then(_SessionOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SessionSurfaces {

 List<SessionOption> get models; String? get currentModelId; List<SessionOption> get modes; String? get currentModeId; List<SessionOption> get efforts; String? get currentEffortValue;/// The config id effort levels are written back to, when the agent uses the
/// `configOptions` shape.
 String? get effortConfigId;
/// Create a copy of SessionSurfaces
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionSurfacesCopyWith<SessionSurfaces> get copyWith => _$SessionSurfacesCopyWithImpl<SessionSurfaces>(this as SessionSurfaces, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SessionSurfaces;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionSurfaces&&const DeepCollectionEquality().equals(other.models, _this.models)&&(identical(other.currentModelId, _this.currentModelId) || other.currentModelId == _this.currentModelId)&&const DeepCollectionEquality().equals(other.modes, _this.modes)&&(identical(other.currentModeId, _this.currentModeId) || other.currentModeId == _this.currentModeId)&&const DeepCollectionEquality().equals(other.efforts, _this.efforts)&&(identical(other.currentEffortValue, _this.currentEffortValue) || other.currentEffortValue == _this.currentEffortValue)&&(identical(other.effortConfigId, _this.effortConfigId) || other.effortConfigId == _this.effortConfigId));
}


@override
int get hashCode {
  final _this = this as SessionSurfaces;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.models),_this.currentModelId,const DeepCollectionEquality().hash(_this.modes),_this.currentModeId,const DeepCollectionEquality().hash(_this.efforts),_this.currentEffortValue,_this.effortConfigId);
}

@override
String toString() {
  final _this = this as SessionSurfaces;
  return 'SessionSurfaces(models: ${_this.models}, currentModelId: ${_this.currentModelId}, modes: ${_this.modes}, currentModeId: ${_this.currentModeId}, efforts: ${_this.efforts}, currentEffortValue: ${_this.currentEffortValue}, effortConfigId: ${_this.effortConfigId})';
}


}

/// @nodoc
abstract mixin class $SessionSurfacesCopyWith<$Res>  {
  factory $SessionSurfacesCopyWith(SessionSurfaces value, $Res Function(SessionSurfaces) _then) = _$SessionSurfacesCopyWithImpl;
@useResult
$Res call({
 List<SessionOption> models, String? currentModelId, List<SessionOption> modes, String? currentModeId, List<SessionOption> efforts, String? currentEffortValue, String? effortConfigId
});




}
/// @nodoc
class _$SessionSurfacesCopyWithImpl<$Res>
    implements $SessionSurfacesCopyWith<$Res> {
  _$SessionSurfacesCopyWithImpl(this._self, this._then);

  final SessionSurfaces _self;
  final $Res Function(SessionSurfaces) _then;

/// Create a copy of SessionSurfaces
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? models = null,Object? currentModelId = freezed,Object? modes = null,Object? currentModeId = freezed,Object? efforts = null,Object? currentEffortValue = freezed,Object? effortConfigId = freezed,}) {
  return _then(SessionSurfaces(
models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as List<SessionOption>,currentModelId: freezed == currentModelId ? _self.currentModelId : currentModelId // ignore: cast_nullable_to_non_nullable
as String?,modes: null == modes ? _self.modes : modes // ignore: cast_nullable_to_non_nullable
as List<SessionOption>,currentModeId: freezed == currentModeId ? _self.currentModeId : currentModeId // ignore: cast_nullable_to_non_nullable
as String?,efforts: null == efforts ? _self.efforts : efforts // ignore: cast_nullable_to_non_nullable
as List<SessionOption>,currentEffortValue: freezed == currentEffortValue ? _self.currentEffortValue : currentEffortValue // ignore: cast_nullable_to_non_nullable
as String?,effortConfigId: freezed == effortConfigId ? _self.effortConfigId : effortConfigId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionSurfaces].
extension SessionSurfacesPatterns on SessionSurfaces {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionSurfaces value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionSurfaces() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionSurfaces value)  $default,){
final _that = this;
switch (_that) {
case _SessionSurfaces():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionSurfaces value)?  $default,){
final _that = this;
switch (_that) {
case _SessionSurfaces() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SessionOption> models,  String? currentModelId,  List<SessionOption> modes,  String? currentModeId,  List<SessionOption> efforts,  String? currentEffortValue,  String? effortConfigId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionSurfaces() when $default != null:
return $default(_that.models,_that.currentModelId,_that.modes,_that.currentModeId,_that.efforts,_that.currentEffortValue,_that.effortConfigId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SessionOption> models,  String? currentModelId,  List<SessionOption> modes,  String? currentModeId,  List<SessionOption> efforts,  String? currentEffortValue,  String? effortConfigId)  $default,) {final _that = this;
switch (_that) {
case _SessionSurfaces():
return $default(_that.models,_that.currentModelId,_that.modes,_that.currentModeId,_that.efforts,_that.currentEffortValue,_that.effortConfigId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SessionOption> models,  String? currentModelId,  List<SessionOption> modes,  String? currentModeId,  List<SessionOption> efforts,  String? currentEffortValue,  String? effortConfigId)?  $default,) {final _that = this;
switch (_that) {
case _SessionSurfaces() when $default != null:
return $default(_that.models,_that.currentModelId,_that.modes,_that.currentModeId,_that.efforts,_that.currentEffortValue,_that.effortConfigId);case _:
  return null;

}
}

}

/// @nodoc


class _SessionSurfaces extends SessionSurfaces {
  const _SessionSurfaces({ List<SessionOption> models = const <SessionOption>[], this.currentModelId,  List<SessionOption> modes = const <SessionOption>[], this.currentModeId,  List<SessionOption> efforts = const <SessionOption>[], this.currentEffortValue, this.effortConfigId}): _models = models,_modes = modes,_efforts = efforts,super._();
  

 final  List<SessionOption> _models;
@override@JsonKey() List<SessionOption> get models {
  if (_models is EqualUnmodifiableListView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_models);
}

@override final  String? currentModelId;
 final  List<SessionOption> _modes;
@override@JsonKey() List<SessionOption> get modes {
  if (_modes is EqualUnmodifiableListView) return _modes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modes);
}

@override final  String? currentModeId;
 final  List<SessionOption> _efforts;
@override@JsonKey() List<SessionOption> get efforts {
  if (_efforts is EqualUnmodifiableListView) return _efforts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_efforts);
}

@override final  String? currentEffortValue;
/// The config id effort levels are written back to, when the agent uses the
/// `configOptions` shape.
@override final  String? effortConfigId;

/// Create a copy of SessionSurfaces
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionSurfacesCopyWith<_SessionSurfaces> get copyWith => __$SessionSurfacesCopyWithImpl<_SessionSurfaces>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionSurfaces&&const DeepCollectionEquality().equals(other.models, _models)&&(identical(other.currentModelId, currentModelId) || other.currentModelId == currentModelId)&&const DeepCollectionEquality().equals(other.modes, _modes)&&(identical(other.currentModeId, currentModeId) || other.currentModeId == currentModeId)&&const DeepCollectionEquality().equals(other.efforts, _efforts)&&(identical(other.currentEffortValue, currentEffortValue) || other.currentEffortValue == currentEffortValue)&&(identical(other.effortConfigId, effortConfigId) || other.effortConfigId == effortConfigId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_models),currentModelId,const DeepCollectionEquality().hash(_modes),currentModeId,const DeepCollectionEquality().hash(_efforts),currentEffortValue,effortConfigId);
}

@override
String toString() {
    return 'SessionSurfaces(models: $models, currentModelId: $currentModelId, modes: $modes, currentModeId: $currentModeId, efforts: $efforts, currentEffortValue: $currentEffortValue, effortConfigId: $effortConfigId)';
}


}

/// @nodoc
abstract mixin class _$SessionSurfacesCopyWith<$Res> implements $SessionSurfacesCopyWith<$Res> {
  factory _$SessionSurfacesCopyWith(_SessionSurfaces value, $Res Function(_SessionSurfaces) _then) = __$SessionSurfacesCopyWithImpl;
@override @useResult
$Res call({
 List<SessionOption> models, String? currentModelId, List<SessionOption> modes, String? currentModeId, List<SessionOption> efforts, String? currentEffortValue, String? effortConfigId
});




}
/// @nodoc
class __$SessionSurfacesCopyWithImpl<$Res>
    implements _$SessionSurfacesCopyWith<$Res> {
  __$SessionSurfacesCopyWithImpl(this._self, this._then);

  final _SessionSurfaces _self;
  final $Res Function(_SessionSurfaces) _then;

/// Create a copy of SessionSurfaces
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? models = null,Object? currentModelId = freezed,Object? modes = null,Object? currentModeId = freezed,Object? efforts = null,Object? currentEffortValue = freezed,Object? effortConfigId = freezed,}) {
  return _then(_SessionSurfaces(
models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as List<SessionOption>,currentModelId: freezed == currentModelId ? _self.currentModelId : currentModelId // ignore: cast_nullable_to_non_nullable
as String?,modes: null == modes ? _self._modes : modes // ignore: cast_nullable_to_non_nullable
as List<SessionOption>,currentModeId: freezed == currentModeId ? _self.currentModeId : currentModeId // ignore: cast_nullable_to_non_nullable
as String?,efforts: null == efforts ? _self._efforts : efforts // ignore: cast_nullable_to_non_nullable
as List<SessionOption>,currentEffortValue: freezed == currentEffortValue ? _self.currentEffortValue : currentEffortValue // ignore: cast_nullable_to_non_nullable
as String?,effortConfigId: freezed == effortConfigId ? _self.effortConfigId : effortConfigId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
