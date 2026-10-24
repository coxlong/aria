import 'package:aria/core/format/markdown_heal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('finished prose is left alone', () {
    const text = 'The build is ready.\n\n- one\n- two\n\n**Done.**';
    expect(healStreamingMarkdown(text), text);
  });

  test('a closed fence is not touched', () {
    const text = 'Run this:\n```bash\nls -la\n```\nThen wait.';
    expect(healStreamingMarkdown(text), text);
  });

  test('an unclosed fence is closed on its own line', () {
    const text = 'Run this:\n```bash\nnpm publish';
    expect(healStreamingMarkdown(text), '$text\n```');
  });

  test(
    'an unclosed fence that ends in a newline does not gain a blank line',
    () {
      const text = 'Run this:\n```bash\nnpm publish\n';
      expect(healStreamingMarkdown(text), '$text```');
    },
  );

  test('an unclosed bold run is closed', () {
    expect(
      healStreamingMarkdown('The build is **ready'),
      'The build is **ready**',
    );
  });

  test('an unclosed inline code run is closed', () {
    expect(healStreamingMarkdown('Run `npm test'), 'Run `npm test`');
  });

  test('punctuation inside a fence is not counted', () {
    const text = '```bash\necho "**not bold"\n```\nDone';
    expect(healStreamingMarkdown(text), text);
  });

  test('a glob inside inline code is not an unclosed bold run', () {
    const text = 'Use `**/*.dart` to match every Dart file.';
    expect(healStreamingMarkdown(text), text);
  });

  test('bold after inline code is still repaired', () {
    const text = 'Use `npm run build` then **wait';
    expect(healStreamingMarkdown(text), '$text**');
  });

  test('an unclosed strikethrough is closed', () {
    expect(healStreamingMarkdown('~~old'), '~~old~~');
  });

  test('empty text stays empty', () {
    expect(healStreamingMarkdown(''), '');
  });
}
