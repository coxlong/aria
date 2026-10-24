import 'package:acp/acp.dart';
import 'package:aria/state/conversation_reducer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConversationReducer', () {
    test('streams assistant text into a single message', () {
      final reducer = ConversationReducer()..onUserMessage('hi');

      reducer
        ..apply(const AgentMessageChunk('s1', 'Hel'))
        ..apply(const AgentMessageChunk('s1', 'lo'));

      expect(reducer.messages, hasLength(2));
      expect(reducer.messages.last.role, 'assistant');
      expect(reducer.messages.last.content, 'Hello');
      expect(reducer.messages.last.streaming, isTrue);
    });

    test('ends the turn', () {
      final reducer = ConversationReducer()
        ..onUserMessage('hi')
        ..apply(const AgentMessageChunk('s1', 'done'));

      reducer.endTurn(stopReason: 'end_turn');

      expect(reducer.messages.last.streaming, isFalse);
      expect(reducer.messages.last.content, 'done');
    });

    test('keeps thought, tool and text blocks in wire order', () {
      final reducer = ConversationReducer()..onUserMessage('run');

      reducer
        ..apply(const AgentThoughtChunk('s1', 'reasoning'))
        ..apply(
          const ToolCallStarted(
            's1',
            ToolCallInfo(id: 't1', title: 'Bash', status: 'in_progress'),
          ),
        )
        ..apply(const AgentMessageChunk('s1', 'result'));

      final message = reducer.messages.last;
      expect(message.blocks, hasLength(3));
      expect(message.blocks[0], isA<ThoughtBlock>());
      expect(message.blocks[1], isA<ToolBlock>());
      expect(message.blocks[2], isA<TextBlock>());
      expect((message.blocks[0] as ThoughtBlock).text, 'reasoning');
      expect(message.content, 'result');
      expect(message.processSteps, hasLength(2));
    });

    test('patches tool calls by id, even after the turn ends', () {
      final reducer = ConversationReducer()..onUserMessage('run');

      reducer
        ..apply(
          const ToolCallStarted('s1', ToolCallInfo(id: 't1', title: 'Bash')),
        )
        ..endTurn(stopReason: 'end_turn')
        ..apply(
          const ToolCallPatched('s1', toolCallId: 't1', status: 'completed'),
        );

      expect(reducer.toolById('t1')?.status, 'completed');
      final block = reducer.messages.last.blocks.single as ToolBlock;
      expect(block.call.status, 'completed');
    });

    test('ignores patches for unknown tool calls', () {
      final reducer = ConversationReducer()
        ..apply(const ToolCallPatched('s1', toolCallId: 'missing'));

      expect(reducer.messages, isEmpty);
      expect(reducer.toolById('missing'), isNull);
    });

    test('replay history is never marked streaming', () {
      final reducer = ConversationReducer()
        ..beginReplay()
        ..apply(const UserMessageChunk('s1', 'old question'))
        ..apply(const AgentMessageChunk('s1', 'old answer'))
        ..endReplay();

      expect(reducer.messages, hasLength(2));
      expect(reducer.messages.every((message) => !message.streaming), isTrue);
    });

    test('live chunks after replay start a new message', () {
      final reducer = ConversationReducer()
        ..beginReplay()
        ..apply(const AgentMessageChunk('s1', 'old answer'))
        ..endReplay()
        ..onUserMessage('new question')
        ..apply(const AgentMessageChunk('s1', 'new answer'));

      expect(reducer.messages, hasLength(3));
      expect(reducer.messages.last.content, 'new answer');
      expect(reducer.messages.last.streaming, isTrue);
    });

    test('ignores config and unknown updates', () {
      final reducer = ConversationReducer()..onUserMessage('hi');

      reducer
        ..apply(const CurrentModeUpdate('s1', 'plan'))
        ..apply(const ConfigOptionUpdate('s1', <Map<String, Object?>>[]))
        ..apply(const UnknownSessionUpdate('s1', 'plan', <String, Object?>{}));

      expect(reducer.messages, hasLength(1));
    });

    test('reset clears messages and tool index', () {
      final reducer = ConversationReducer()
        ..onUserMessage('hi')
        ..apply(
          const ToolCallStarted('s1', ToolCallInfo(id: 't1', title: 'Bash')),
        )
        ..reset();

      expect(reducer.messages, isEmpty);
      expect(reducer.toolById('t1'), isNull);
    });
  });
}
