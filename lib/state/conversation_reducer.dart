import 'package:acp/acp.dart';

/// One ordered content block inside an assistant message.
sealed class MsgBlock {
  const MsgBlock();
}

/// Streamed assistant text.
final class TextBlock extends MsgBlock {
  String text;

  TextBlock(this.text);
}

/// A reasoning segment.
final class ThoughtBlock extends MsgBlock {
  String text;

  ThoughtBlock(this.text);
}

/// A tool execution.
final class ToolBlock extends MsgBlock {
  ToolCallInfo call;

  ToolBlock(this.call);
}

/// One row in the execution-process sheet.
final class TurnStep {
  /// `thinking` or `tool`.
  final String kind;
  final String? thinking;
  final ToolCallInfo? tool;

  const TurnStep.thinking(this.thinking) : kind = 'thinking', tool = null;

  const TurnStep.tool(this.tool) : kind = 'tool', thinking = null;

  String get summary {
    switch (kind) {
      case 'thinking':
        final text = (thinking ?? '').trim();
        if (text.isEmpty) return '';
        return text.length > 80 ? '${text.substring(0, 80)}…' : text;
      case 'tool':
        return tool?.title ?? '';
      default:
        return '';
    }
  }
}

/// A message in the conversation.
final class ChatMessage {
  /// `user` or `assistant`.
  final String role;
  final List<MsgBlock> blocks;
  bool streaming;

  ChatMessage({
    required this.role,
    List<MsgBlock>? blocks,
    this.streaming = false,
  }) : blocks = blocks ?? <MsgBlock>[];

  String get content =>
      blocks.whereType<TextBlock>().map((block) => block.text).join();

  bool get hasText => content.trim().isNotEmpty;

  /// Thinking and tool blocks, in wire order.
  List<TurnStep> get processSteps => blocks
      .whereType<MsgBlock>()
      .where((block) => block is! TextBlock)
      .map(
        (block) => switch (block) {
          ThoughtBlock(:final text) => TurnStep.thinking(text),
          ToolBlock(:final call) => TurnStep.tool(call),
          _ => const TurnStep.thinking(''),
        },
      )
      .toList();
}

/// Folds ACP session updates into [ChatMessage]s.
///
/// Pure Dart so it can be unit-tested without Flutter.
final class ConversationReducer {
  final List<ChatMessage> messages = <ChatMessage>[];
  final Map<String, ToolCallInfo> _tools = <String, ToolCallInfo>{};
  ChatMessage? _assistant;
  bool _replaying = false;

  void reset() {
    messages.clear();
    _tools.clear();
    _assistant = null;
    _replaying = false;
  }

  /// History replay: newly created messages are not marked streaming.
  void beginReplay() => _replaying = true;

  /// Ends replay. The next live chunk starts a new message instead of being
  /// appended to the last replayed one.
  void endReplay() {
    _replaying = false;
    _assistant = null;
  }

  void onUserMessage(String text) {
    _assistant = null;
    messages.add(
      ChatMessage(role: 'user', blocks: <MsgBlock>[TextBlock(text)]),
    );
  }

  void apply(SessionUpdate update) {
    switch (update) {
      case UserMessageChunk(:final text):
        _assistant = null;
        final last = messages.isEmpty ? null : messages.last;
        if (last != null && last.role == 'user') {
          _appendText(last, text);
        } else {
          messages.add(
            ChatMessage(role: 'user', blocks: <MsgBlock>[TextBlock(text)]),
          );
        }
      case AgentMessageChunk(:final text):
        _appendText(_ensureAssistant(), text);
      case AgentThoughtChunk(:final text):
        final assistant = _ensureAssistant();
        final last = assistant.blocks.isEmpty ? null : assistant.blocks.last;
        if (last is ThoughtBlock) {
          last.text += text;
        } else {
          assistant.blocks.add(ThoughtBlock(text));
        }
      case ToolCallStarted(:final toolCall):
        _ensureAssistant().blocks.add(ToolBlock(toolCall));
        _tools[toolCall.id] = toolCall;
      case ToolCallPatched(
        :final toolCallId,
        :final title,
        :final status,
        :final rawInput,
        :final rawOutput,
        :final content,
        :final meta,
      ):
        final current = _tools[toolCallId];
        if (current == null) return;
        final patched = current.copyWith(
          title: title,
          status: status,
          rawInput: rawInput,
          rawOutput: rawOutput,
          content: content,
          meta: meta,
        );
        _tools[toolCallId] = patched;
        for (final message in messages) {
          for (final block in message.blocks) {
            if (block is ToolBlock && block.call.id == toolCallId) {
              block.call = patched;
            }
          }
        }
      case CurrentModeUpdate():
      case ConfigOptionUpdate():
      case UnknownSessionUpdate():
        break;
    }
  }

  /// Ends the current turn. Tool patches that arrive later still resolve
  /// through [toolById].
  void endTurn({required String stopReason}) {
    _assistant?.streaming = false;
    _assistant = null;
  }

  ToolCallInfo? toolById(String id) => _tools[id];

  void _appendText(ChatMessage message, String text) {
    final last = message.blocks.isEmpty ? null : message.blocks.last;
    if (last is TextBlock) {
      last.text += text;
    } else {
      message.blocks.add(TextBlock(text));
    }
  }

  ChatMessage _ensureAssistant() {
    var assistant = _assistant;
    if (assistant == null) {
      assistant = ChatMessage(role: 'assistant', streaming: !_replaying);
      messages.add(assistant);
      _assistant = assistant;
    }
    if (!_replaying && !assistant.streaming) assistant.streaming = true;
    return assistant;
  }
}
