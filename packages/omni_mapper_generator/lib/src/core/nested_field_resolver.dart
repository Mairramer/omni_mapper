import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

class ResolvedNestedField {
  final String path;
  final DartType type;

  ResolvedNestedField(this.path, this.type);
}

ResolvedNestedField? resolveNestedField(
  ClassElement classElement,
  String targetName,
  String currentAccess, {
  bool needsQuestionMark = false,
}) {
  for (final field in classElement.getters) {
    if (field.isStatic || field.name == null) {
      continue;
    }
    final fieldName = field.name!;

    if (fieldName == targetName) {
      final access =
          '$currentAccess${needsQuestionMark ? '?.' : '.'}$fieldName';
      return ResolvedNestedField(access, field.returnType);
    }

    if (targetName.startsWith(fieldName) &&
        targetName.length > fieldName.length) {
      final nextChar = targetName[fieldName.length];
      if (nextChar == nextChar.toUpperCase()) {
        final remainingName =
            nextChar.toLowerCase() + targetName.substring(fieldName.length + 1);
        final fieldTypeElement = field.returnType.element;
        if (fieldTypeElement is ClassElement) {
          final isFieldNullable =
              field.returnType.nullabilitySuffix == NullabilitySuffix.question;
          final access =
              '$currentAccess${needsQuestionMark ? '?.' : '.'}$fieldName';

          final result = resolveNestedField(
            fieldTypeElement,
            remainingName,
            access,
            needsQuestionMark: isFieldNullable,
          );
          if (result != null) {
            return result;
          }
        }
      }
    }
  }

  return null;
}
