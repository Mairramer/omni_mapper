import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

import '../core/nested_field_resolver.dart';

class UpdateMethodBuilder {
  static Method build({
    required ClassElement sourceClass,
    required ClassElement targetClass,
    required String methodName,
    required Map<String, String> fieldMaps,
    required List<String> ignoreFields,
    required Map<String, String> defaultValues,
    required bool ignoreIfNull,
  }) {
    final updateBodyBuffer = StringBuffer();

    final sourceFieldNames = <String>{};
    final sourceFieldTypes = <String, DartType>{};
    final typesToCheck = <InterfaceElement>[
      sourceClass,
      ...sourceClass.allSupertypes.map((t) => t.element).whereType<InterfaceElement>(),
    ];
    for (final element in typesToCheck) {
      if (element.name == 'Object') {
        continue;
      }
      for (final f in element.fields) {
        if (!f.isStatic && f.name != null) {
          sourceFieldNames.add(f.name!);
          if (!sourceFieldTypes.containsKey(f.name!)) {
            sourceFieldTypes[f.name!] = f.type;
          }
        }
      }
      for (final g in element.getters) {
        if (!g.isStatic && g.name != null) {
          sourceFieldNames.add(g.name!);
          if (!sourceFieldTypes.containsKey(g.name!)) {
            sourceFieldTypes[g.name!] = g.returnType;
          }
        }
      }
    }

    for (final field in targetClass.fields) {
      final fieldName = field.name;
      if (fieldName == null || field.isStatic || field.isFinal || field.setter == null) {
        continue;
      }
      if (ignoreFields.contains(fieldName)) {
        continue;
      }

      String sourceFieldName = fieldName;
      for (final entry in fieldMaps.entries) {
        if (entry.value == fieldName) {
          sourceFieldName = entry.key;
          break;
        }
      }

      bool hasSourceField = sourceFieldNames.contains(sourceFieldName);
      ResolvedNestedField? nestedField;

      if (!hasSourceField) {
        nestedField = resolveNestedField(
          sourceClass,
          sourceFieldName,
          '',
        );
        if (nestedField != null) {
          hasSourceField = true;
        }
      }

      if (hasSourceField) {
        final sourceFieldType = nestedField?.type ?? sourceFieldTypes[sourceFieldName];
        String accessString;
        if (nestedField != null) {
          accessString = nestedField.path;
          if (accessString.startsWith('target.') || accessString.startsWith('target?.')) {
            accessString = 'this.$accessString';
          }
        } else {
          accessString = sourceFieldName == 'target' ? 'this.$sourceFieldName' : sourceFieldName;
        }
        final targetFieldType = field.type;
        final sourceTypeElement = sourceFieldType?.element;
        final targetTypeElement = targetFieldType.element;

        final isNullable =
            sourceFieldType?.nullabilitySuffix == NullabilitySuffix.question || accessString.contains('?.');

        if (sourceTypeElement is EnumElement &&
            targetTypeElement is EnumElement &&
            sourceTypeElement != targetTypeElement) {
          final targetEnumName = targetTypeElement.name;
          if (ignoreIfNull && isNullable) {
            updateBodyBuffer.writeln(
              'if ($accessString case final $fieldName?) {\n  target.$fieldName = $targetEnumName.values.byName($fieldName.name);\n}',
            );
          } else if (isNullable) {
            updateBodyBuffer.writeln(
              'target.$fieldName = $accessString != null ? $targetEnumName.values.byName(($accessString)!.name) : null;',
            );
          } else {
            updateBodyBuffer.writeln(
              'target.$fieldName = $targetEnumName.values.byName($accessString.name);',
            );
          }
        } else {
          if (ignoreIfNull && isNullable) {
            updateBodyBuffer.writeln(
              'if ($accessString case final $fieldName?) {\n  target.$fieldName = $fieldName;\n}',
            );
          } else {
            updateBodyBuffer.writeln('target.$fieldName = $accessString;');
          }
        }
      } else if (defaultValues.containsKey(fieldName)) {
        updateBodyBuffer.writeln(
          'target.$fieldName = ${defaultValues[fieldName]};',
        );
      }
    }

    return Method(
      (m) => m
        ..name = methodName
        ..returns = refer('void')
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'target'
              ..type = refer(targetClass.name ?? ''),
          ),
        )
        ..body = Code(updateBodyBuffer.toString()),
    );
  }
}
