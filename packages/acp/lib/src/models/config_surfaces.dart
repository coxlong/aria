/// Selectable model advertised by an agent.
final class SessionModel {
  final String modelId;
  final String name;
  final String? description;

  const SessionModel({
    required this.modelId,
    required this.name,
    this.description,
  });
}

/// Model selection state.
///
/// ACP agents advertise models in one of two shapes:
/// - `models` object (`availableModels` + `currentModelId`), switched with
///   `session/set_model`;
/// - `configOptions[]` entry whose id/category is `model`, switched with
///   `session/set_config_option`.
///
/// [configId] is non-null for the second shape.
final class SessionModels {
  final List<SessionModel> available;
  final String? currentModelId;
  final String? configId;

  const SessionModels({
    required this.available,
    this.currentModelId,
    this.configId,
  });

  bool get hasModels => available.isNotEmpty;

  String? get currentDisplay {
    final current = currentModelId;
    if (current != null && current.isNotEmpty) {
      for (final model in available) {
        if (model.modelId == current) {
          return _displayName(model.name, current);
        }
      }
      return _displayName(current, current);
    }
    if (available.isNotEmpty) {
      final first = available.first;
      return _displayName(first.name, first.modelId);
    }
    return null;
  }

  static String _displayName(String name, String fallback) {
    final value = name.isEmpty ? fallback : name;
    final dot = value.lastIndexOf(' · ');
    if (dot >= 0) return value.substring(dot + 3);
    final colon = value.lastIndexOf(':');
    return colon >= 0 ? value.substring(colon + 1) : value;
  }

  /// Parses the result of `session/new` or `session/load`.
  factory SessionModels.fromSessionResult(Map<String, Object?> result) {
    final models = result['models'];
    if (models is Map<String, Object?>) {
      final list = models['availableModels'];
      if (list is List) {
        return SessionModels(
          available: list
              .whereType<Map<String, Object?>>()
              .map(
                (json) => SessionModel(
                  modelId: json['modelId'] as String? ?? '',
                  name:
                      json['name'] as String? ??
                      json['modelId'] as String? ??
                      '',
                  description: json['description'] as String?,
                ),
              )
              .toList(growable: false),
          currentModelId: models['currentModelId'] as String?,
        );
      }
    }
    final options = result['configOptions'];
    if (options is List) return SessionModels.fromConfigOptions(options);
    return const SessionModels(available: []);
  }

  /// Parses a `configOptions[]` array for the model option.
  factory SessionModels.fromConfigOptions(List<Object?> options) {
    for (final option in options) {
      if (option is! Map<String, Object?>) continue;
      final id = option['id'];
      final category = option['category'];
      final isModel =
          id == 'model' || category == 'model' || category == 'model_config';
      if (!isModel) continue;
      final rawOptions = option['options'];
      if (rawOptions is! List) continue;
      return SessionModels(
        available: rawOptions
            .whereType<Map<String, Object?>>()
            .map(
              (json) => SessionModel(
                modelId: json['value'] as String? ?? '',
                name: json['name'] as String? ?? json['value'] as String? ?? '',
                description: json['description'] as String?,
              ),
            )
            .toList(growable: false),
        currentModelId: option['currentValue'] as String?,
        configId: id is String ? id : 'model',
      );
    }
    return const SessionModels(available: []);
  }
}

/// Selectable session mode.
final class SessionMode {
  final String id;
  final String name;
  final String? description;

  const SessionMode({required this.id, required this.name, this.description});
}

/// Mode selection state (`modes` object, `session/set_mode`).
final class SessionModes {
  final List<SessionMode> available;
  final String? currentModeId;

  const SessionModes({required this.available, this.currentModeId});

  bool get hasModes => available.isNotEmpty;

  String? get currentDisplay {
    final current = currentModeId;
    if (current != null && current.isNotEmpty) {
      for (final mode in available) {
        if (mode.id == current) {
          return mode.name.isNotEmpty ? mode.name : mode.id;
        }
      }
      return current;
    }
    if (available.isNotEmpty) {
      final first = available.first;
      return first.name.isNotEmpty ? first.name : first.id;
    }
    return null;
  }

  factory SessionModes.fromSessionResult(Map<String, Object?> result) {
    final modes = result['modes'];
    if (modes is Map<String, Object?>) {
      final list = modes['availableModes'];
      if (list is List) {
        return SessionModes(
          available: list
              .whereType<Map<String, Object?>>()
              .map(
                (json) => SessionMode(
                  id: json['id'] as String? ?? '',
                  name: json['name'] as String? ?? json['id'] as String? ?? '',
                  description: json['description'] as String?,
                ),
              )
              .toList(growable: false),
          currentModeId: modes['currentModeId'] as String?,
        );
      }
    }
    return const SessionModes(available: []);
  }
}

/// Selectable reasoning effort level.
final class SessionEffort {
  final String value;
  final String name;

  const SessionEffort({required this.value, required this.name});
}

/// Reasoning-effort state, parsed from a `thought_level` config option.
final class SessionEfforts {
  final List<SessionEffort> available;
  final String? currentValue;
  final String? configId;

  const SessionEfforts({
    required this.available,
    this.currentValue,
    this.configId,
  });

  bool get hasEfforts => available.isNotEmpty;

  String? get currentDisplay {
    final current = currentValue;
    if (current != null && current.isNotEmpty) {
      for (final effort in available) {
        if (effort.value == current) {
          return effort.name.isNotEmpty ? effort.name : current;
        }
      }
      return current;
    }
    if (available.isNotEmpty) {
      final first = available.first;
      return first.name.isNotEmpty ? first.name : first.value;
    }
    return null;
  }

  factory SessionEfforts.fromSessionResult(Map<String, Object?> result) {
    final options = result['configOptions'];
    if (options is List) return SessionEfforts.fromConfigOptions(options);
    return const SessionEfforts(available: []);
  }

  factory SessionEfforts.fromConfigOptions(List<Object?> options) {
    for (final option in options) {
      if (option is! Map<String, Object?>) continue;
      final id = option['id'];
      final category = option['category'];
      final isEffort =
          category == 'thought_level' ||
          id == 'effort' ||
          id == 'thought_level' ||
          id == 'reasoning_effort';
      if (!isEffort) continue;
      final rawOptions = option['options'];
      if (rawOptions is! List) continue;
      return SessionEfforts(
        available: rawOptions
            .whereType<Map<String, Object?>>()
            .map(
              (json) => SessionEffort(
                value: json['value'] as String? ?? '',
                name: json['name'] as String? ?? json['value'] as String? ?? '',
              ),
            )
            .toList(growable: false),
        currentValue: option['currentValue'] as String?,
        configId: id is String ? id : 'effort',
      );
    }
    return const SessionEfforts(available: []);
  }
}
