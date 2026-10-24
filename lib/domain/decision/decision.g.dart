// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DecisionOption _$DecisionOptionFromJson(Map<String, dynamic> json) =>
    _DecisionOption(
      id: json['id'] as String,
      label: json['label'] as String,
      kind: $enumDecode(_$DecisionOptionKindEnumMap, json['kind']),
    );

Map<String, dynamic> _$DecisionOptionToJson(_DecisionOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'kind': _$DecisionOptionKindEnumMap[instance.kind]!,
    };

const _$DecisionOptionKindEnumMap = {
  DecisionOptionKind.allowOnce: 'allowOnce',
  DecisionOptionKind.allowAlways: 'allowAlways',
  DecisionOptionKind.rejectOnce: 'rejectOnce',
  DecisionOptionKind.rejectAlways: 'rejectAlways',
  DecisionOptionKind.other: 'other',
};
