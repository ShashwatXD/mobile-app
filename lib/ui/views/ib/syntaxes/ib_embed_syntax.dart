import 'package:markdown/markdown.dart' as md;

class IbEmbedSyntax extends md.BlockSyntax {
  IbEmbedSyntax() : super();

  @override
  md.Node parse(md.BlockParser parser) {
    var text = parser.current;
    parser.advance();

    final element = md.Element('iframe', []);
    element.attributes['content'] = text.content;
    return element;
  }

  @override
  RegExp get pattern => RegExp(r'^<iframe[^>]+>((?<!<\/iframe)[^])*<\/iframe>');
}
