// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConnectionSnapshot {

 ServerProfile? get profile; ConnectionStatus get status; AppError? get error; AgentSession? get session; SessionSurfaces? get surfaces; List<AgentSessionSummary> get sessions; AgentCapabilities get capabilities;/// Every decision raised in this session, answered or not, oldest first.
 List<Decision> get decisions;
/// Create a copy of ConnectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionSnapshotCopyWith<ConnectionSnapshot> get copyWith => _$ConnectionSnapshotCopyWithImpl<ConnectionSnapshot>(this as ConnectionSnapshot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConnectionSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionSnapshot&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.session, _this.session) || other.session == _this.session)&&(identical(other.surfaces, _this.surfaces) || other.surfaces == _this.surfaces)&&const DeepCollectionEquality().equals(other.sessions, _this.sessions)&&(identical(other.capabilities, _this.capabilities) || other.capabilities == _this.capabilities)&&const DeepCollectionEquality().equals(other.decisions, _this.decisions));
}


@override
int get hashCode {
  final _this = this as ConnectionSnapshot;
  return Object.hash(runtimeType,_this.profile,_this.status,_this.error,_this.session,_this.surfaces,const DeepCollectionEquality().hash(_this.sessions),_this.capabilities,const DeepCollectionEquality().hash(_this.decisions));
}

@override
String toString() {
  final _this = this as ConnectionSnapshot;
  return 'ConnectionSnapshot(profile: ${_this.profile}, status: ${_this.status}, error: ${_this.error}, session: ${_this.session}, surfaces: ${_this.surfaces}, sessions: ${_this.sessions}, capabilities: ${_this.capabilities}, decisions: ${_this.decisions})';
}


}

/// @nodoc
abstract mixin class $ConnectionSnapshotCopyWith<$Res>  {
  factory $ConnectionSnapshotCopyWith(ConnectionSnapshot value, $Res Function(ConnectionSnapshot) _then) = _$ConnectionSnapshotCopyWithImpl;
@useResult
$Res call({
 ServerProfile? profile, ConnectionStatus status, AppError? error, AgentSession? session, SessionSurfaces? surfaces, List<AgentSessionSummary> sessions, AgentCapabilities capabilities, List<Decision> decisions
});


$ServerProfileCopyWith<$Res>? get profile;$AgentSessionCopyWith<$Res>? get session;$SessionSurfacesCopyWith<$Res>? get surfaces;$AgentCapabilitiesCopyWith<$Res> get capabilities;

}
/// @nodoc
class _$ConnectionSnapshotCopyWithImpl<$Res>
    implements $ConnectionSnapshotCopyWith<$Res> {
  _$ConnectionSnapshotCopyWithImpl(this._self, this._then);

  final ConnectionSnapshot _self;
  final $Res Function(ConnectionSnapshot) _then;

/// Create a copy of ConnectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = freezed,Object? status = null,Object? error = freezed,Object? session = freezed,Object? surfaces = freezed,Object? sessions = null,Object? capabilities = null,Object? decisions = null,}) {
  return _then(ConnectionSnapshot(
profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ServerProfile?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError?,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as AgentSession?,surfaces: freezed == surfaces ? _self.surfaces : surfaces // ignore: cast_nullable_to_non_nullable
as SessionSurfaces?,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<AgentSessionSummary>,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as AgentCapabilities,decisions: null == decisions ? _self.decisions : decisions // ignore: cast_nullable_to_non_nullable
as List<Decision>,
  ));
}
/// Create a copy of ConnectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServerProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ServerProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of ConnectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgentSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $AgentSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}/// Create a copy of ConnectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionSurfacesCopyWith<$Res>? get surfaces {
    if (_self.surfaces == null) {
    return null;
  }

  return $SessionSurfacesCopyWith<$Res>(_self.surfaces!, (value) {
    return _then(_self.copyWith(surfaces: value));
  });
}/// Create a copy of ConnectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgentCapabilitiesCopyWith<$Res> get capabilities {
  
  return $AgentCapabilitiesCopyWith<$Res>(_self.capabilities, (value) {
    return _then(_self.copyWith(capabilities: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConnectionSnapshot].
extension ConnectionSnapshotPatterns on ConnectionSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ServerProfile? profile,  ConnectionStatus status,  AppError? error,  AgentSession? session,  SessionSurfaces? surfaces,  List<AgentSessionSummary> sessions,  AgentCapabilities capabilities,  List<Decision> decisions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionSnapshot() when $default != null:
return $default(_that.profile,_that.status,_that.error,_that.session,_that.surfaces,_that.sessions,_that.capabilities,_that.decisions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ServerProfile? profile,  ConnectionStatus status,  AppError? error,  AgentSession? session,  SessionSurfaces? surfaces,  List<AgentSessionSummary> sessions,  AgentCapabilities capabilities,  List<Decision> decisions)  $default,) {final _that = this;
switch (_that) {
case _ConnectionSnapshot():
return $default(_that.profile,_that.status,_that.error,_that.session,_that.surfaces,_that.sessions,_that.capabilities,_that.decisions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ServerProfile? profile,  ConnectionStatus status,  AppError? error,  AgentSession? session,  SessionSurfaces? surfaces,  List<AgentSessionSummary> sessions,  AgentCapabilities capabilities,  List<Decision> decisions)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionSnapshot() when $default != null:
return $default(_that.profile,_that.status,_that.error,_that.session,_that.surfaces,_that.sessions,_that.capabilities,_that.decisions);case _:
  return null;

}
}

}

/// @nodoc


class _ConnectionSnapshot extends ConnectionSnapshot {
  const _ConnectionSnapshot({this.profile, this.status = ConnectionStatus.idle, this.error, this.session, this.surfaces,  List<AgentSessionSummary> sessions = const <AgentSessionSummary>[], this.capabilities = const AgentCapabilities(),  List<Decision> decisions = const <Decision>[]}): _sessions = sessions,_decisions = decisions,super._();
  

@override final  ServerProfile? profile;
@override@JsonKey() final  ConnectionStatus status;
@override final  AppError? error;
@override final  AgentSession? session;
@override final  SessionSurfaces? surfaces;
 final  List<AgentSessionSummary> _sessions;
@override@JsonKey() List<AgentSessionSummary> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

@override@JsonKey() final  AgentCapabilities capabilities;
/// Every decision raised in this session, answered or not, oldest first.
 final  List<Decision> _decisions;
/// Every decision raised in this session, answered or not, oldest first.
@override@JsonKey() List<Decision> get decisions {
  if (_decisions is EqualUnmodifiableListView) return _decisions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_decisions);
}


/// Create a copy of ConnectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionSnapshotCopyWith<_ConnectionSnapshot> get copyWith => __$ConnectionSnapshotCopyWithImpl<_ConnectionSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionSnapshot&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error)&&(identical(other.session, session) || other.session == session)&&(identical(other.surfaces, surfaces) || other.surfaces == surfaces)&&const DeepCollectionEquality().equals(other.sessions, _sessions)&&(identical(other.capabilities, capabilities) || other.capabilities == capabilities)&&const DeepCollectionEquality().equals(other.decisions, _decisions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,profile,status,error,session,surfaces,const DeepCollectionEquality().hash(_sessions),capabilities,const DeepCollectionEquality().hash(_decisions));
}

@override
String toString() {
    return 'ConnectionSnapshot(profile: $profile, status: $status, error: $error, session: $session, surfaces: $surfaces, sessions: $sessions, capabilities: $capabilities, decisions: $decisions)';
}


}

/// @nodoc
abstract mixin class _$ConnectionSnapshotCopyWith<$Res> implements $ConnectionSnapshotCopyWith<$Res> {
  factory _$ConnectionSnapshotCopyWith(_ConnectionSnapshot value, $Res Function(_ConnectionSnapshot) _then) = __$ConnectionSnapshotCopyWithImpl;
@override @useResult
$Res call({
 ServerProfile? profile, ConnectionStatus status, AppError? error, AgentSession? session, SessionSurfaces? surfaces, List<AgentSessionSummary> sessions, AgentCapabilities capabilities, List<Decision> decisions
});


@override $ServerProfileCopyWith<$Res>? get profile;@override $AgentSessionCopyWith<$Res>? get session;@override $SessionSurfacesCopyWith<$Res>? get surfaces;@override $AgentCapabilitiesCopyWith<$Res> get capabilities;

}
/// @nodoc
class __$ConnectionSnapshotCopyWithImpl<$Res>
    implements _$ConnectionSnapshotCopyWith<$Res> {
  __$ConnectionSnapshotCopyWithImpl(this._self, this._then);

  final _ConnectionSnapshot _self;
  final $Res Function(_ConnectionSnapshot) _then;

/// Create a copy of ConnectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = freezed,Object? status = null,Object? error = freezed,Object? session = freezed,Object? surfaces = freezed,Object? sessions = null,Object? capabilities = null,Object? decisions = null,}) {
  return _then(_ConnectionSnapshot(
profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ServerProfile?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError?,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as AgentSession?,surfaces: freezed == surfaces ? _self.surfaces : surfaces // ignore: cast_nullable_to_non_nullable
as SessionSurfaces?,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<AgentSessionSummary>,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as AgentCapabilities,decisions: null == decisions ? _self._decisions : decisions // ignore: cast_nullable_to_non_nullable
as List<Decision>,
  ));
}

/// Create a copy of ConnectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServerProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ServerProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of ConnectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgentSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $AgentSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}/// Create a copy of ConnectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionSurfacesCopyWith<$Res>? get surfaces {
    if (_self.surfaces == null) {
    return null;
  }

  return $SessionSurfacesCopyWith<$Res>(_self.surfaces!, (value) {
    return _then(_self.copyWith(surfaces: value));
  });
}/// Create a copy of ConnectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgentCapabilitiesCopyWith<$Res> get capabilities {
  
  return $AgentCapabilitiesCopyWith<$Res>(_self.capabilities, (value) {
    return _then(_self.copyWith(capabilities: value));
  });
}
}

// dart format on
