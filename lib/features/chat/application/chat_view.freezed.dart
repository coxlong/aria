// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatView {

 String get sessionId; List<ChatTurn> get turns; bool get running; bool get stopping; AppError? get error;
/// Create a copy of ChatView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatViewCopyWith<ChatView> get copyWith => _$ChatViewCopyWithImpl<ChatView>(this as ChatView, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatView&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&const DeepCollectionEquality().equals(other.turns, _this.turns)&&(identical(other.running, _this.running) || other.running == _this.running)&&(identical(other.stopping, _this.stopping) || other.stopping == _this.stopping)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as ChatView;
  return Object.hash(runtimeType,_this.sessionId,const DeepCollectionEquality().hash(_this.turns),_this.running,_this.stopping,_this.error);
}

@override
String toString() {
  final _this = this as ChatView;
  return 'ChatView(sessionId: ${_this.sessionId}, turns: ${_this.turns}, running: ${_this.running}, stopping: ${_this.stopping}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ChatViewCopyWith<$Res>  {
  factory $ChatViewCopyWith(ChatView value, $Res Function(ChatView) _then) = _$ChatViewCopyWithImpl;
@useResult
$Res call({
 String sessionId, List<ChatTurn> turns, bool running, bool stopping, AppError? error
});




}
/// @nodoc
class _$ChatViewCopyWithImpl<$Res>
    implements $ChatViewCopyWith<$Res> {
  _$ChatViewCopyWithImpl(this._self, this._then);

  final ChatView _self;
  final $Res Function(ChatView) _then;

/// Create a copy of ChatView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? turns = null,Object? running = null,Object? stopping = null,Object? error = freezed,}) {
  return _then(ChatView(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,turns: null == turns ? _self.turns : turns // ignore: cast_nullable_to_non_nullable
as List<ChatTurn>,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,stopping: null == stopping ? _self.stopping : stopping // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatView].
extension ChatViewPatterns on ChatView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatView value)  $default,){
final _that = this;
switch (_that) {
case _ChatView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatView value)?  $default,){
final _that = this;
switch (_that) {
case _ChatView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  List<ChatTurn> turns,  bool running,  bool stopping,  AppError? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatView() when $default != null:
return $default(_that.sessionId,_that.turns,_that.running,_that.stopping,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  List<ChatTurn> turns,  bool running,  bool stopping,  AppError? error)  $default,) {final _that = this;
switch (_that) {
case _ChatView():
return $default(_that.sessionId,_that.turns,_that.running,_that.stopping,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  List<ChatTurn> turns,  bool running,  bool stopping,  AppError? error)?  $default,) {final _that = this;
switch (_that) {
case _ChatView() when $default != null:
return $default(_that.sessionId,_that.turns,_that.running,_that.stopping,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ChatView extends ChatView {
  const _ChatView({required this.sessionId,  List<ChatTurn> turns = const <ChatTurn>[], this.running = false, this.stopping = false, this.error}): _turns = turns,super._();
  

@override final  String sessionId;
 final  List<ChatTurn> _turns;
@override@JsonKey() List<ChatTurn> get turns {
  if (_turns is EqualUnmodifiableListView) return _turns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_turns);
}

@override@JsonKey() final  bool running;
@override@JsonKey() final  bool stopping;
@override final  AppError? error;

/// Create a copy of ChatView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatViewCopyWith<_ChatView> get copyWith => __$ChatViewCopyWithImpl<_ChatView>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatView&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&const DeepCollectionEquality().equals(other.turns, _turns)&&(identical(other.running, running) || other.running == running)&&(identical(other.stopping, stopping) || other.stopping == stopping)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,sessionId,const DeepCollectionEquality().hash(_turns),running,stopping,error);
}

@override
String toString() {
    return 'ChatView(sessionId: $sessionId, turns: $turns, running: $running, stopping: $stopping, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ChatViewCopyWith<$Res> implements $ChatViewCopyWith<$Res> {
  factory _$ChatViewCopyWith(_ChatView value, $Res Function(_ChatView) _then) = __$ChatViewCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, List<ChatTurn> turns, bool running, bool stopping, AppError? error
});




}
/// @nodoc
class __$ChatViewCopyWithImpl<$Res>
    implements _$ChatViewCopyWith<$Res> {
  __$ChatViewCopyWithImpl(this._self, this._then);

  final _ChatView _self;
  final $Res Function(_ChatView) _then;

/// Create a copy of ChatView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? turns = null,Object? running = null,Object? stopping = null,Object? error = freezed,}) {
  return _then(_ChatView(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,turns: null == turns ? _self._turns : turns // ignore: cast_nullable_to_non_nullable
as List<ChatTurn>,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,stopping: null == stopping ? _self.stopping : stopping // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}


}

// dart format on
