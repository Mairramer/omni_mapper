class SwitchBuilder {
  static String build({
    required String codeBody,
    required Map<String, String> subclasses,
    required String sourceVarName,
    bool isExtension = false,
  }) {
    if (subclasses.isEmpty) {
      return codeBody;
    }

    final switchBuffer = StringBuffer();
    switchBuffer.writeln('return switch ($sourceVarName) {');
    for (final entry in subclasses.entries) {
      if (isExtension) {
        switchBuffer.writeln('  ${entry.key} s => s.${entry.value}(),');
      } else {
        switchBuffer.writeln('  ${entry.key} s => ${entry.value}(s),');
      }
    }

    final simpleConstructorRegex = RegExp(r'^return ([^;]+);\s*$');
    final simpleThrowRegex = RegExp(r'^(throw\s+[^;]+);\s*$');
    final trimmedBody = codeBody.trim();
    final match = simpleConstructorRegex.firstMatch(trimmedBody);
    final matchThrow = simpleThrowRegex.firstMatch(trimmedBody);

    if (match != null) {
      switchBuffer.writeln('  _ => ${match.group(1)},');
    } else if (matchThrow != null) {
      switchBuffer.writeln('  _ => ${matchThrow.group(1)},');
    } else {
      switchBuffer.writeln('  _ => () {');
      switchBuffer.writeln(codeBody);
      switchBuffer.writeln('  }(),');
    }
    switchBuffer.writeln('};');
    return switchBuffer.toString();
  }
}
