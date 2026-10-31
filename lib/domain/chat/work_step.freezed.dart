// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkStep {

 String get id; String get title; StepStatus get status; StepKind get kind; ToolAction get action; String? get detail; String? get input; String? get output; DateTime? get startedAt; DateTime? get endedAt;
/// Create a copy of WorkStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkStepCopyWith<WorkStep> get copyWith => _$WorkStepCopyWithImpl<WorkStep>(this as WorkStep, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkStep;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkStep&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.detail, _this.detail) || other.detail == _this.detail)&&(identical(other.input, _this.input) || other.input == _this.input)&&(identical(other.output, _this.output) || other.output == _this.output)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt));
}


@override
int get hashCode {
  final _this = this as WorkStep;
  return Object.hash(runtimeType,_this.id,_this.title,_this.status,_this.kind,_this.action,_this.detail,_this.input,_this.output,_this.startedAt,_this.endedAt);
}

@override
String toString() {
  final _this = this as WorkStep;
  return 'WorkStep(id: ${_this.id}, title: ${_this.title}, status: ${_this.status}, kind: ${_this.kind}, action: ${_this.action}, detail: ${_this.detail}, input: ${_this.input}, output: ${_this.output}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt})';
}


}

/// @nodoc
abstract mixin class $WorkStepCopyWith<$Res>  {
  factory $WorkStepCopyWith(WorkStep value, $Res Function(WorkStep) _then) = _$WorkStepCopyWithImpl;
@useResult
$Res call({
 String id, String title, StepStatus status, StepKind kind, ToolAction action, String? detail, String? input, String? output, DateTime? startedAt, DateTime? endedAt
});




}
/// @nodoc
class _$WorkStepCopyWithImpl<$Res>
    implements $WorkStepCopyWith<$Res> {
  _$WorkStepCopyWithImpl(this._self, this._then);

  final WorkStep _self;
  final $Res Function(WorkStep) _then;

/// Create a copy of WorkStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? status = null,Object? kind = null,Object? action = null,Object? detail = freezed,Object? input = freezed,Object? output = freezed,Object? startedAt = freezed,Object? endedAt = freezed,}) {
  return _then(WorkStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StepStatus,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as StepKind,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ToolAction,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,input: freezed == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as String?,output: freezed == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkStep].
extension WorkStepPatterns on WorkStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkStep value)  $default,){
final _that = this;
switch (_that) {
case _WorkStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkStep value)?  $default,){
final _that = this;
switch (_that) {
case _WorkStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  StepStatus status,  StepKind kind,  ToolAction action,  String? detail,  String? input,  String? output,  DateTime? startedAt,  DateTime? endedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkStep() when $default != null:
return $default(_that.id,_that.title,_that.status,_that.kind,_that.action,_that.detail,_that.input,_that.output,_that.startedAt,_that.endedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  StepStatus status,  StepKind kind,  ToolAction action,  String? detail,  String? input,  String? output,  DateTime? startedAt,  DateTime? endedAt)  $default,) {final _that = this;
switch (_that) {
case _WorkStep():
return $default(_that.id,_that.title,_that.status,_that.kind,_that.action,_that.detail,_that.input,_that.output,_that.startedAt,_that.endedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  StepStatus status,  StepKind kind,  ToolAction action,  String? detail,  String? input,  String? output,  DateTime? startedAt,  DateTime? endedAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkStep() when $default != null:
return $default(_that.id,_that.title,_that.status,_that.kind,_that.action,_that.detail,_that.input,_that.output,_that.startedAt,_that.endedAt);case _:
  return null;

}
}

}

/// @nodoc


class _WorkStep extends WorkStep {
  const _WorkStep({required this.id, required this.title, required this.status, this.kind = StepKind.tool, this.action = ToolAction.other, this.detail, this.input, this.output, this.startedAt, this.endedAt}): super._();
  

@override final  String id;
@override final  String title;
@override final  StepStatus status;
@override@JsonKey() final  StepKind kind;
@override@JsonKey() final  ToolAction action;
@override final  String? detail;
@override final  String? input;
@override final  String? output;
@override final  DateTime? startedAt;
@override final  DateTime? endedAt;

/// Create a copy of WorkStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkStepCopyWith<_WorkStep> get copyWith => __$WorkStepCopyWithImpl<_WorkStep>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkStep&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.action, action) || other.action == action)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.input, input) || other.input == input)&&(identical(other.output, output) || other.output == output)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,status,kind,action,detail,input,output,startedAt,endedAt);
}

@override
String toString() {
    return 'WorkStep(id: $id, title: $title, status: $status, kind: $kind, action: $action, detail: $detail, input: $input, output: $output, startedAt: $startedAt, endedAt: $endedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkStepCopyWith<$Res> implements $WorkStepCopyWith<$Res> {
  factory _$WorkStepCopyWith(_WorkStep value, $Res Function(_WorkStep) _then) = __$WorkStepCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, StepStatus status, StepKind kind, ToolAction action, String? detail, String? input, String? output, DateTime? startedAt, DateTime? endedAt
});




}
/// @nodoc
class __$WorkStepCopyWithImpl<$Res>
    implements _$WorkStepCopyWith<$Res> {
  __$WorkStepCopyWithImpl(this._self, this._then);

  final _WorkStep _self;
  final $Res Function(_WorkStep) _then;

/// Create a copy of WorkStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? status = null,Object? kind = null,Object? action = null,Object? detail = freezed,Object? input = freezed,Object? output = freezed,Object? startedAt = freezed,Object? endedAt = freezed,}) {
  return _then(_WorkStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StepStatus,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as StepKind,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ToolAction,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,input: freezed == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as String?,output: freezed == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
