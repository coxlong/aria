/// A tool call reported by the agent.
final class ToolCallInfo {
  final String id;
  final String title;
  final String? kind;
  final String? status;
  final List<Map<String, Object?>>? locations;
  final Object? rawInput;
  final Object? rawOutput;
  final List<Map<String, Object?>>? content;

  /// Agent-specific extension data. Claude Code puts
  /// `{claudeCode: {toolName: 'Bash'}}` here; other agents omit it.
  final Map<String, Object?>? meta;

  const ToolCallInfo({
    required this.id,
    required this.title,
    this.kind,
    this.status,
    this.locations,
    this.rawInput,
    this.rawOutput,
    this.content,
    this.meta,
  });

  /// Claude Code tool name, derived from `_meta`; null for other agents.
  String? get toolName {
    final claudeCode = meta?['claudeCode'];
    if (claudeCode is Map<String, Object?>) {
      final name = claudeCode['toolName'];
      if (name is String && name.isNotEmpty) return name;
    }
    return null;
  }

  bool get isCompleted => status == 'completed';

  /// Text extracted from the ACP content blocks.
  String get contentText {
    final blocks = content ?? _contentFromRawOutput();
    if (blocks == null) return '';
    final buffer = StringBuffer();
    for (final block in blocks) {
      final inner = block['content'];
      if (inner is Map<String, Object?> && inner['text'] is String) {
        if (buffer.isNotEmpty) buffer.write('\n');
        buffer.write(inner['text'] as String);
      }
    }
    return buffer.toString();
  }

  List<Map<String, Object?>>? _contentFromRawOutput() {
    final output = rawOutput;
    if (output is List) {
      return output.whereType<Map<String, Object?>>().toList();
    }
    return null;
  }

  /// Returns a copy with the mutable display fields patched.
  ///
  /// Null arguments mean "leave unchanged" for scalar fields. [meta] is merged
  /// one level deep: Claude Code sends `_meta` keys across several
  /// `tool_call_update` frames, so replacing the map wholesale would drop
  /// keys that arrived earlier.
  ToolCallInfo copyWith({
    String? title,
    String? status,
    Object? rawInput,
    Object? rawOutput,
    List<Map<String, Object?>>? content,
    Map<String, Object?>? meta,
  }) => ToolCallInfo(
    id: id,
    title: title ?? this.title,
    kind: kind,
    status: status ?? this.status,
    locations: locations,
    rawInput: rawInput ?? this.rawInput,
    rawOutput: rawOutput ?? this.rawOutput,
    content: content ?? this.content,
    meta: _mergeMeta(this.meta, meta),
  );

  static Map<String, Object?>? _mergeMeta(
    Map<String, Object?>? base,
    Map<String, Object?>? patch,
  ) {
    if (patch == null) return base;
    if (base == null) return patch;
    final result = Map<String, Object?>.of(base);
    patch.forEach((key, value) {
      final current = result[key];
      result[key] =
          current is Map<String, Object?> && value is Map<String, Object?>
          ? <String, Object?>{...current, ...value}
          : value;
    });
    return result;
  }

  factory ToolCallInfo.fromJson(Map<String, Object?> json) => ToolCallInfo(
    id: json['toolCallId'] as String? ?? json['id'] as String? ?? '',
    title: json['title'] as String? ?? 'Tool',
    kind: json['kind'] as String?,
    status: json['status'] as String?,
    locations: _mapList(json['locations']),
    rawInput: json['rawInput'],
    rawOutput: json['rawOutput'],
    content: _mapList(json['content']),
    meta: json['_meta'] is Map<String, Object?>
        ? json['_meta'] as Map<String, Object?>
        : null,
  );

  static List<Map<String, Object?>>? _mapList(Object? value) {
    if (value is! List) return null;
    return value.whereType<Map<String, Object?>>().toList(growable: false);
  }
}
