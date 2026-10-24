import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:highlight/highlight_core.dart' as hl;
import 'package:highlight/languages/bash.dart' as lang_bash;
import 'package:highlight/languages/css.dart' as lang_css;
import 'package:highlight/languages/dart.dart' as lang_dart;
import 'package:highlight/languages/javascript.dart' as lang_js;
import 'package:highlight/languages/json.dart' as lang_json;
import 'package:highlight/languages/python.dart' as lang_python;
import 'package:highlight/languages/sql.dart' as lang_sql;
import 'package:highlight/languages/xml.dart' as lang_xml;
import 'package:highlight/languages/yaml.dart' as lang_yaml;
import 'package:markdown/markdown.dart' as md;
import 'package:material_ui/material_ui.dart';

import '../format/markdown_heal.dart';
import '../theme/aria_colors.dart';
import '../theme/aria_tokens.dart';
import '../theme/aria_type.dart';

/// Renders an agent's prose.
///
/// Two things are Aria's rather than the package's:
///
/// * while text is still arriving it is repaired first (see
///   [healStreamingMarkdown]) so a half-arrived answer never flashes raw
///   backticks and then corrects itself. Finished text is rendered untouched:
///   repairing it would append markers the author never wrote — `**` inside
///   inline code such as a `**/*.dart` glob is the common case;
/// * fenced code is drawn here, with the design system's own tokens, instead of
///   inheriting a theme from the markdown package.
class AriaMarkdown extends StatelessWidget {
  const AriaMarkdown(
    this.data, {
    super.key,
    this.selectable = true,
    this.streaming = false,
  });

  final String data;
  final bool selectable;

  /// True while the agent is still emitting this text.
  final bool streaming;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: streaming ? healStreamingMarkdown(data) : data,
      selectable: selectable,
      styleSheet: _sheetOf(context),
      builders: <String, MarkdownElementBuilder>{'code': _CodeBuilder()},
    );
  }
}

MarkdownStyleSheet _sheetOf(BuildContext context) {
  final colors = context.ariaColors;
  final type = context.ariaType;

  return MarkdownStyleSheet(
    p: type.body.copyWith(color: colors.text),
    a: type.body.copyWith(
      color: colors.primary,
      decoration: TextDecoration.underline,
      decorationColor: colors.primary,
    ),
    em: type.body.copyWith(color: colors.text, fontStyle: FontStyle.italic),
    strong: type.body.copyWith(color: colors.text, fontWeight: FontWeight.w600),
    del: type.body.copyWith(
      color: colors.textMuted,
      decoration: TextDecoration.lineThrough,
    ),
    h1: type.headline.copyWith(color: colors.text),
    h2: type.title.copyWith(color: colors.text),
    h3: type.title.copyWith(color: colors.text),
    blockquote: type.body.copyWith(color: colors.textSecondary),
    blockquotePadding: const EdgeInsets.fromLTRB(
      AriaSpacing.sm,
      AriaSpacing.xs,
      AriaSpacing.sm,
      AriaSpacing.xs,
    ),
    blockquoteDecoration: BoxDecoration(
      color: colors.surface,
      border: Border(left: BorderSide(color: colors.primary, width: 3)),
    ),
    code: type.code.copyWith(
      color: colors.textSecondary,
      backgroundColor: colors.inset,
    ),
    codeblockPadding: const EdgeInsets.all(AriaSpacing.sm),
    codeblockDecoration: BoxDecoration(
      color: colors.inset,
      borderRadius: AriaRadius.mdAll,
    ),
    listBullet: type.body.copyWith(color: colors.primary),
    listIndent: AriaSpacing.lg,
    blockSpacing: AriaSpacing.xs,
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: colors.border)),
    ),
  );
}

/// Fenced code blocks get a language header and a copy action.
///
/// Inline code and untagged fences return null and keep the style sheet's
/// treatment, which is already the right one.
final class _CodeBuilder extends MarkdownElementBuilder {
  _CodeBuilder();

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final language = _languageOf(element);
    if (language == null) return null;

    final code = element.textContent;
    return _CodeBlock(
      code: code.endsWith('\n') ? code.substring(0, code.length - 1) : code,
      language: language,
    );
  }

  static String? _languageOf(md.Element element) {
    final classes = element.attributes['class'];
    if (classes == null) return null;
    for (final name in classes.split(' ')) {
      if (name.startsWith('language-')) {
        final language = name.substring('language-'.length).toLowerCase();
        return language.isEmpty ? null : language;
      }
    }
    return null;
  }
}

class _CodeBlock extends StatefulWidget {
  const _CodeBlock({required this.code, required this.language});

  final String code;
  final String language;

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AriaSpacing.xs),
      decoration: BoxDecoration(
        color: colors.inset,
        borderRadius: AriaRadius.mdAll,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AriaSpacing.sm,
              AriaSpacing.xxs,
              AriaSpacing.xxs,
              AriaSpacing.xxs,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.language,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: type.caption.copyWith(color: colors.textMuted),
                  ),
                ),
                TextButton(
                  onPressed: () => _copied ? null : _copy(),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.textMuted,
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.border),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AriaSpacing.sm),
            child: Text.rich(
              _highlighted(widget.code, widget.language, context),
              style: type.code.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// `highlight` with every bundled language would drag its whole catalogue into
// the binary; these are the ones an agent actually emits.
bool _languagesReady = false;

void _registerLanguages() {
  if (_languagesReady) return;
  _languagesReady = true;
  hl.highlight
    ..registerLanguage('bash', lang_bash.bash)
    ..registerLanguage('sh', lang_bash.bash)
    ..registerLanguage('shell', lang_bash.bash)
    ..registerLanguage('zsh', lang_bash.bash)
    ..registerLanguage('json', lang_json.json)
    ..registerLanguage('dart', lang_dart.dart)
    ..registerLanguage('python', lang_python.python)
    ..registerLanguage('javascript', lang_js.javascript)
    ..registerLanguage('js', lang_js.javascript)
    ..registerLanguage('yaml', lang_yaml.yaml)
    ..registerLanguage('yml', lang_yaml.yaml)
    ..registerLanguage('xml', lang_xml.xml)
    ..registerLanguage('html', lang_xml.xml)
    ..registerLanguage('css', lang_css.css)
    ..registerLanguage('sql', lang_sql.sql);
}

TextSpan _highlighted(String code, String language, BuildContext context) {
  final colors = context.ariaColors;
  final base = context.ariaType.code.copyWith(color: colors.textSecondary);

  _registerLanguages();
  final hl.Result result;
  try {
    result = hl.highlight.parse(code, language: language);
  } on Object {
    return TextSpan(text: code, style: base);
  }

  final nodes = result.nodes;
  if (nodes == null || nodes.isEmpty) {
    return TextSpan(text: code, style: base);
  }
  return TextSpan(
    style: base,
    children: <InlineSpan>[for (final node in nodes) _span(node, base, colors)],
  );
}

InlineSpan _span(hl.Node node, TextStyle base, AriaColors colors) {
  final value = node.value;
  if (value != null) return TextSpan(text: value, style: base);

  final style = _styleOf(node.className, base, colors);
  final children = node.children;
  if (children == null || children.isEmpty) return TextSpan(style: style);
  return TextSpan(
    style: style,
    children: <InlineSpan>[
      for (final child in children) _span(child, base, colors),
    ],
  );
}

TextStyle _styleOf(String? className, TextStyle base, AriaColors colors) {
  final token = className?.split(' ').firstOrNull;
  return switch (token) {
    'keyword' ||
    'selector-tag' ||
    'built_in' ||
    'meta' => base.copyWith(color: colors.primary),
    'string' ||
    'attr' ||
    'attribute' ||
    'regexp' => base.copyWith(color: colors.success),
    'comment' || 'quote' => base.copyWith(color: colors.textMuted),
    'number' || 'literal' || 'bullet' => base.copyWith(color: colors.warning),
    'title' ||
    'section' ||
    'name' ||
    'function' => base.copyWith(color: colors.text),
    'type' || 'class' || 'variable' => base.copyWith(color: colors.attention),
    _ => base.copyWith(color: colors.textSecondary),
  };
}
