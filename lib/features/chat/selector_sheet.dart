import 'package:flutter/material.dart';

/// One selectable value in a selector sheet.
typedef SelectorChoice = ({String value, String label});

/// Shows a single-choice sheet and returns the picked value, or null.
Future<String?> showSelectorSheet({
  required BuildContext context,
  required String? selected,
  required List<SelectorChoice> options,
}) {
  return showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => ListView(
      shrinkWrap: true,
      children: [
        for (final option in options)
          ListTile(
            title: Text(option.label),
            selected: option.value == selected,
            onTap: () => Navigator.of(sheetContext).pop(option.value),
          ),
      ],
    ),
  );
}
