import 'package:aria/domain/chat/chat_turn.dart';
import 'package:aria/domain/chat/work_step.dart';
import 'package:aria/features/chat/presentation/chat_stream.dart';
import 'package:flutter_test/flutter_test.dart';

/// Prose is the only break: thinking and tools on either side of it become
/// separate runs, and a run at the end of a turn stays open.
void main() {
  ChatTurn turn(
    String id, {
    required List<TurnBlock> blocks,
    String user = 'Do the thing',
    bool running = false,
    bool stopped = false,
  }) => ChatTurn(
    id: id,
    userText: user,
    blocks: blocks,
    running: running,
    stopped: stopped,
  );

  ToolBlock tool(String id, {StepStatus status = StepStatus.completed}) =>
      ToolBlock(
        step: WorkStep(
          id: id,
          title: id,
          status: status,
          output: 'result of $id',
        ),
      );

  test('a run before prose folds, and the next run starts after it', () {
    final items = buildChatStream(<ChatTurn>[
      turn(
        'turn1',
        blocks: <TurnBlock>[
          const ThoughtBlock(id: 'th1', text: 'First, look at the files.'),
          tool('read'),
          const TextBlock(id: 'p1', text: 'Reading it now.'),
          const ThoughtBlock(id: 'th2', text: 'Now write the change.'),
          tool('write'),
          const TextBlock(id: 'p2', text: 'Done.'),
        ],
      ),
    ]);

    expect(items, hasLength(5));
    expect(items[0], isA<UserItem>());
    expect(items[1], isA<RunItem>());
    expect((items[1] as RunItem).folded, isTrue);
    expect((items[1] as RunItem).steps, hasLength(2));
    expect(items[2], isA<ProseItem>());
    expect(items[3], isA<RunItem>());
    expect((items[3] as RunItem).folded, isTrue);
    expect(items[4], isA<ProseItem>());
  });

  test('a run with no prose after it stays open', () {
    final items = buildChatStream(<ChatTurn>[
      turn(
        'turn1',
        blocks: <TurnBlock>[
          const ThoughtBlock(id: 'th1', text: 'Look.'),
          tool('read'),
          tool('deploy', status: StepStatus.running),
        ],
        running: true,
      ),
    ]);

    expect(items, hasLength(2));
    final run = items[1] as RunItem;
    expect(run.folded, isFalse);
    expect(run.running, isTrue);
    expect(run.toolCount, 2);
    expect(run.thoughtCount, 1);
  });

  test('user messages and turn endings are hard boundaries', () {
    final items = buildChatStream(<ChatTurn>[
      turn('turn1', blocks: <TurnBlock>[tool('read')]),
      turn('turn2', blocks: <TurnBlock>[tool('write')]),
    ]);

    expect(items, hasLength(4));
    expect(items[0], isA<UserItem>());
    expect(items[1], isA<RunItem>());
    expect(items[2], isA<UserItem>());
    expect(items[3], isA<RunItem>());
    expect((items[1] as RunItem).id, isNot((items[3] as RunItem).id));
  });

  test('a stopped turn keeps a notice after its open run', () {
    final items = buildChatStream(<ChatTurn>[
      turn('turn1', blocks: <TurnBlock>[tool('read')], stopped: true),
    ]);

    expect(items, hasLength(3));
    expect(items[2], isA<NoticeItem>());
  });

  test('failed steps are counted for the fold line', () {
    final items = buildChatStream(<ChatTurn>[
      turn(
        'turn1',
        blocks: <TurnBlock>[
          tool('read', status: StepStatus.failed),
          tool('write'),
          const TextBlock(id: 'p1', text: 'Partial.'),
        ],
      ),
    ]);

    final run = items[1] as RunItem;
    expect(run.failedCount, 1);
    expect(run.folded, isTrue);
  });

  test('consecutive prose stays separate items', () {
    final items = buildChatStream(<ChatTurn>[
      turn(
        'turn1',
        blocks: const <TurnBlock>[
          TextBlock(id: 'p1', text: 'One.'),
          TextBlock(id: 'p2', text: 'Two.'),
        ],
      ),
    ]);

    expect(items, hasLength(3));
    expect(items[1], isA<ProseItem>());
    expect(items[2], isA<ProseItem>());
  });
}
