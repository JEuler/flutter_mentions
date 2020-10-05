part of flutter_mentions;

/// A custom implementation of [TextEditingController] to support @ mention or other
/// trigger based mentions.
class AnnotationEditingController extends TextEditingController {
  final Map<String, Annotation> _mapping;
  final String _pattern;

  // Generate the Regex pattern for matching all the suggestions in one.
  AnnotationEditingController(this._mapping)
      : _pattern = "(${_mapping.keys.map((key) => key).join('|')})";

  /// Can be used to get the markup from the controller directly.
  String get markupText {
    final someVal = text.splitMapJoin(
      RegExp('$_pattern'),
      onMatch: (Match match) {
        final mention = _mapping[match[0]] ??
            _mapping[_mapping.keys.firstWhere((element) {
              final reg = RegExp(element);

              return reg.hasMatch(match[0]);
            })];

        // Default markup format for mentions
        if (!mention.disableMarkup) {
          return '<span data-entity="comment">@${mention.display}</span>';
        } else {
          return match[0];
        }
      },
      onNonMatch: (String text) {
        return text;
      },
    );

    return someVal;
  }

  @override
  TextSpan buildTextSpan({TextStyle style, bool withComposing}) {
    var children = <InlineSpan>[];

    text.splitMapJoin(
      RegExp('$_pattern'),
      onMatch: (Match match) {
        if (_mapping.isNotEmpty) {
          final mention = _mapping[match[0]] ??
              _mapping[_mapping.keys.firstWhere((element) {
                final reg = RegExp(element);

                return reg.hasMatch(match[0]);
              })];

          children.add(
            TextSpan(
              text: match[0],
              style: style.merge(mention.style),
            ),
          );
        }

        return '';
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return '';
      },
    );
    return TextSpan(style: style, children: children);
  }
}
