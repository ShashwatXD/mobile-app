import 'package:markdown/markdown.dart' as md;

class IbMdTagSyntax extends md.BlockSyntax {
  IbMdTagSyntax() : super();

  final _tagsStack = <String>[];

  @override
  md.Node? parse(md.BlockParser parser) {
    var match = pattern.firstMatch(parser.current.content);
    if (match == null) return null;
    _tagsStack.addAll(match[1]!.split(' '));

    // Subtitle Syntax
    // This is a temporary workaround for subtitle
    // Since Markdown tags after text is not supported
    if (_tagsStack.contains('.fs-9')) {
      parser.advance();
      parser.advance();
      var text = parser.current;

      _tagsStack.remove('.fs-9');
      parser.advance();
      final element = md.Element('h5', []);
      element.attributes['content'] = text.content;
      return element;
    }

    // Pop Quizzes
    if (_tagsStack.contains('.quiz')) {
      var quizContent = '';

      // Eat all quiz content
      do {
        quizContent += '\n${parser.current}';
        parser.advance();
      } while (parser.next != null || !parser.isDone);

      _tagsStack.remove('.quiz');
      final element = md.Element('quiz', []);
      element.attributes['content'] = quizContent;
      return element;
    }

    parser.advance();

    return null;
  }

  @override
  RegExp get pattern => RegExp(r'{:\s?(.+)\s?}');
}
