import 'package:aria/domain/chat/chat_turn.dart';
import 'package:aria/domain/chat/work_step.dart';
import 'package:flutter_test/flutter_test.dart';

WorkStep _tool(String id, {StepStatus status = StepStatus.completed}) =>
    WorkStep(id: id, title: id, status: status);

void main() {
  test('a finished turn shows its last prose as the answer', () {
    const turn = ChatTurn(
      id: 't1',
      userText: 'Ship it',
      blocks: <TurnBlock>[
        TextBlock(id: 'p1', text: 'Reading the checklist. '),
        ToolBlock(
          step: WorkStep(
            id: 'tc1',
            title: 'Read',
            status: StepStatus.completed,
          ),
        ),
        TextBlock(id: 'p2', text: 'The build is ready.'),
      ],
    );

    expect(turn.answerText, 'The build is ready.');
    // The earlier prose was commentary, not the answer.
    expect(turn.processBlocks.length, 2);
    expect(turn.hasProcess, isTrue);
  });

  test('prose followed by a tool is work, not the answer, while running', () {
    const turn = ChatTurn(
      id: 't1',
      userText: 'Ship it',
      running: true,
      blocks: <TurnBlock>[
        TextBlock(id: 'p1', text: 'Let me check.'),
        ToolBlock(
          step: WorkStep(id: 'tc1', title: 'Read', status: StepStatus.running),
        ),
      ],
    );

    expect(turn.answerText, isEmpty);
    expect(turn.processBlocks.length, 2);
    expect(turn.activeTool?.id, 'tc1');
    expect(turn.capsuleActive, isTrue);
    expect(turn.streamingAnswer, isFalse);
  });

  test('prose at the end of a running turn streams as the answer', () {
    const turn = ChatTurn(
      id: 't1',
      userText: 'Ship it',
      running: true,
      blocks: <TurnBlock>[
        ToolBlock(
          step: WorkStep(
            id: 'tc1',
            title: 'Read',
            status: StepStatus.completed,
          ),
        ),
        TextBlock(id: 'p1', text: 'Done'),
      ],
    );

    expect(turn.answerText, 'Done');
    expect(turn.processBlocks.single, isA<ToolBlock>());
    expect(turn.streamingAnswer, isTrue);
    expect(turn.capsuleActive, isFalse);
  });

  test('a running turn with nothing visible yet waits', () {
    const turn = ChatTurn(id: 't1', userText: 'Ship it', running: true);

    expect(turn.awaitingFirstOutput, isTrue);
    expect(turn.answerText, isEmpty);
    expect(turn.hasProcess, isFalse);
  });

  test('tools keep their wire order and find the active one', () {
    final turn = ChatTurn(
      id: 't1',
      userText: 'Ship it',
      running: true,
      blocks: <TurnBlock>[
        ToolBlock(step: _tool('tc1')),
        ToolBlock(step: _tool('tc2', status: StepStatus.running)),
        ToolBlock(step: _tool('tc3', status: StepStatus.pending)),
      ],
    );

    expect(turn.tools.map((step) => step.id), <String>['tc1', 'tc2', 'tc3']);
    expect(turn.activeTool?.id, 'tc2');
  });
}
