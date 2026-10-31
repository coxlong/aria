// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServerProfile {

 String get id; String get name; String get url; String get cwd;/// One line saying what this agent handles, shown in the agent list.
 String get description;
/// Create a copy of ServerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerProfileCopyWith<ServerProfile> get copyWith => _$ServerProfileCopyWithImpl<ServerProfile>(this as ServerProfile, _$identity);

  /// Serializes this ServerProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ServerProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.cwd, _this.cwd) || other.cwd == _this.cwd)&&(identical(other.description, _this.description) || other.description == _this.description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ServerProfile;
  return Object.hash(runtimeType,_this.id,_this.name,_this.url,_this.cwd,_this.description);
}

@override
String toString() {
  final _this = this as ServerProfile;
  return 'ServerProfile(id: ${_this.id}, name: ${_this.name}, url: ${_this.url}, cwd: ${_this.cwd}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $ServerProfileCopyWith<$Res>  {
  factory $ServerProfileCopyWith(ServerProfile value, $Res Function(ServerProfile) _then) = _$ServerProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String url, String cwd, String description
});




}
/// @nodoc
class _$ServerProfileCopyWithImpl<$Res>
    implements $ServerProfileCopyWith<$Res> {
  _$ServerProfileCopyWithImpl(this._self, this._then);

  final ServerProfile _self;
  final $Res Function(ServerProfile) _then;

/// Create a copy of ServerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? url = null,Object? cwd = null,Object? description = null,}) {
  return _then(ServerProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerProfile].
extension ServerProfilePatterns on ServerProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerProfile value)  $default,){
final _that = this;
switch (_that) {
case _ServerProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ServerProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String url,  String cwd,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerProfile() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.cwd,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String url,  String cwd,  String description)  $default,) {final _that = this;
switch (_that) {
case _ServerProfile():
return $default(_that.id,_that.name,_that.url,_that.cwd,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String url,  String cwd,  String description)?  $default,) {final _that = this;
switch (_that) {
case _ServerProfile() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.cwd,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServerProfile implements ServerProfile {
  const _ServerProfile({required this.id, required this.name, required this.url, this.cwd = '', this.description = ''});
  factory _ServerProfile.fromJson(Map<String, dynamic> json) => _$ServerProfileFromJson(json);

@override final  String id;
@override final  String name;
@override final  String url;
@override@JsonKey() final  String cwd;
/// One line saying what this agent handles, shown in the agent list.
@override@JsonKey() final  String description;

/// Create a copy of ServerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerProfileCopyWith<_ServerProfile> get copyWith => __$ServerProfileCopyWithImpl<_ServerProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServerProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,url,cwd,description);
}

@override
String toString() {
    return 'ServerProfile(id: $id, name: $name, url: $url, cwd: $cwd, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ServerProfileCopyWith<$Res> implements $ServerProfileCopyWith<$Res> {
  factory _$ServerProfileCopyWith(_ServerProfile value, $Res Function(_ServerProfile) _then) = __$ServerProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String url, String cwd, String description
});




}
/// @nodoc
class __$ServerProfileCopyWithImpl<$Res>
    implements _$ServerProfileCopyWith<$Res> {
  __$ServerProfileCopyWithImpl(this._self, this._then);

  final _ServerProfile _self;
  final $Res Function(_ServerProfile) _then;

/// Create a copy of ServerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? url = null,Object? cwd = null,Object? description = null,}) {
  return _then(_ServerProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ConnectedProfile {

 ServerProfile get profile; String get token;
/// Create a copy of ConnectedProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectedProfileCopyWith<ConnectedProfile> get copyWith => _$ConnectedProfileCopyWithImpl<ConnectedProfile>(this as ConnectedProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConnectedProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectedProfile&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.token, _this.token) || other.token == _this.token));
}


@override
int get hashCode {
  final _this = this as ConnectedProfile;
  return Object.hash(runtimeType,_this.profile,_this.token);
}

@override
String toString() {
  final _this = this as ConnectedProfile;
  return 'ConnectedProfile(profile: ${_this.profile}, token: ${_this.token})';
}


}

/// @nodoc
abstract mixin class $ConnectedProfileCopyWith<$Res>  {
  factory $ConnectedProfileCopyWith(ConnectedProfile value, $Res Function(ConnectedProfile) _then) = _$ConnectedProfileCopyWithImpl;
@useResult
$Res call({
 ServerProfile profile, String token
});


$ServerProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$ConnectedProfileCopyWithImpl<$Res>
    implements $ConnectedProfileCopyWith<$Res> {
  _$ConnectedProfileCopyWithImpl(this._self, this._then);

  final ConnectedProfile _self;
  final $Res Function(ConnectedProfile) _then;

/// Create a copy of ConnectedProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = null,Object? token = null,}) {
  return _then(ConnectedProfile(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ServerProfile,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ConnectedProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServerProfileCopyWith<$Res> get profile {
  
  return $ServerProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConnectedProfile].
extension ConnectedProfilePatterns on ConnectedProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectedProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectedProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectedProfile value)  $default,){
final _that = this;
switch (_that) {
case _ConnectedProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectedProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectedProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ServerProfile profile,  String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectedProfile() when $default != null:
return $default(_that.profile,_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ServerProfile profile,  String token)  $default,) {final _that = this;
switch (_that) {
case _ConnectedProfile():
return $default(_that.profile,_that.token);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ServerProfile profile,  String token)?  $default,) {final _that = this;
switch (_that) {
case _ConnectedProfile() when $default != null:
return $default(_that.profile,_that.token);case _:
  return null;

}
}

}

/// @nodoc


class _ConnectedProfile implements ConnectedProfile {
  const _ConnectedProfile({required this.profile, required this.token});
  

@override final  ServerProfile profile;
@override final  String token;

/// Create a copy of ConnectedProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectedProfileCopyWith<_ConnectedProfile> get copyWith => __$ConnectedProfileCopyWithImpl<_ConnectedProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectedProfile&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode {
    return Object.hash(runtimeType,profile,token);
}

@override
String toString() {
    return 'ConnectedProfile(profile: $profile, token: $token)';
}


}

/// @nodoc
abstract mixin class _$ConnectedProfileCopyWith<$Res> implements $ConnectedProfileCopyWith<$Res> {
  factory _$ConnectedProfileCopyWith(_ConnectedProfile value, $Res Function(_ConnectedProfile) _then) = __$ConnectedProfileCopyWithImpl;
@override @useResult
$Res call({
 ServerProfile profile, String token
});


@override $ServerProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$ConnectedProfileCopyWithImpl<$Res>
    implements _$ConnectedProfileCopyWith<$Res> {
  __$ConnectedProfileCopyWithImpl(this._self, this._then);

  final _ConnectedProfile _self;
  final $Res Function(_ConnectedProfile) _then;

/// Create a copy of ConnectedProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = null,Object? token = null,}) {
  return _then(_ConnectedProfile(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ServerProfile,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ConnectedProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServerProfileCopyWith<$Res> get profile {
  
  return $ServerProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on
