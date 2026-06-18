import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

import '../core/mapping_body_builder.dart';
import '../core/nested_field_resolver.dart';

class ExtensionGenerator {
  static String generate({
    required ClassElement sourceClass,
    required DartType targetType,
    required ClassElement elementContext,
    required ConstantReader annotation,
  }) {
    final targetClass = targetType.element as ClassElement?;
    if (targetClass == null) {
      throw InvalidGenerationSourceError('Target must be a class.', element: sourceClass);
    }

    final methodName = annotation.peek('methodName')?.stringValue ?? 'toEntity';
    final capitalizedMethodName = methodName.isNotEmpty
        ? '${methodName[0].toUpperCase()}${methodName.substring(1)}'
        : 'Mapper';

    // Ensure unique name by combining Source class and capitalized method name
    final extensionName = '${sourceClass.name}$capitalizedMethodName';

    final ignoreFields =
        annotation
            .peek('ignoreFields')
            ?.listValue
            .map((e) => e.toStringValue() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        const [];

    final fieldMaps =
        annotation
            .peek('fieldMaps')
            ?.mapValue
            .map((k, v) => MapEntry(k?.toStringValue() ?? '', v?.toStringValue() ?? '')) ??
        const {};

    final defaultValues =
        annotation
            .peek('defaultValues')
            ?.mapValue
            .map((k, v) => MapEntry(k?.toStringValue() ?? '', v?.toStringValue() ?? '')) ??
        const {};

    final converters =
        annotation
            .peek('converters')
            ?.listValue
            .map((e) => e.toTypeValue())
            .where((e) => e != null)
            .cast<DartType>()
            .toList() ??
        const [];

    final generateListMapper = annotation.peek('generateListMapper')?.boolValue ?? true;
    final generateUpdateMethod = annotation.peek('generateUpdateMethod')?.boolValue ?? true;
    final strictMode = annotation.peek('strictMode')?.boolValue ?? false;
    final ignoreIfNull = annotation.peek('ignoreIfNull')?.boolValue ?? false;
    final hookType = annotation.peek('hook')?.typeValue;
    final generateReverse = annotation.peek('generateReverse')?.boolValue ?? false;
    final reverseMethodNameRaw = annotation.peek('reverseMethodName')?.stringValue ?? '';
    final reverseMethodName = reverseMethodNameRaw.isEmpty ? 'to${sourceClass.name}' : reverseMethodNameRaw;

    final codeBody = MappingBodyBuilder.build(
      sourceClass: sourceClass,
      targetClass: targetClass,
      sourceVarName: 'this',
      mapperClass: null,
      elementContext: elementContext,
      extensionMethodName: methodName,
      ignoreFields: ignoreFields,
      fieldMaps: fieldMaps,
      defaultValues: defaultValues,
      converters: converters,
      strictMode: strictMode,
      hookType: hookType,
    );

    final extensionBuilder = Extension((e) {
      e
        ..name = extensionName
        ..on = refer(sourceClass.name ?? '')
        ..methods.add(
          Method(
            (m) => m
              ..name = methodName
              ..returns = refer(targetClass.name ?? '')
              ..body = Code(codeBody),
          ),
        );

      if (generateUpdateMethod) {
        final updateBodyBuffer = StringBuffer();

        final sourceFieldNames = <String>{};
        final sourceFieldTypes = <String, DartType>{};
        for (final f in sourceClass.fields) {
          if (!f.isStatic && f.name != null) {
            sourceFieldNames.add(f.name!);
            sourceFieldTypes[f.name!] = f.type;
          }
        }
        for (final g in sourceClass.getters) {
          if (!g.isStatic && g.name != null) {
            sourceFieldNames.add(g.name!);
            sourceFieldTypes[g.name!] = g.returnType;
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
              'this',
            );
            if (nestedField != null) {
              hasSourceField = true;
            }
          }

          if (hasSourceField) {
            final sourceFieldType = nestedField?.type ?? sourceFieldTypes[sourceFieldName];
            final accessString = nestedField?.path ?? 'this.$sourceFieldName';
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
                  'if ($accessString case final $fieldName?) target.$fieldName = $targetEnumName.values.byName($fieldName.name);',
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
                  'if ($accessString case final $fieldName?) target.$fieldName = $fieldName;',
                );
              } else {
                updateBodyBuffer.writeln('target.$fieldName = $accessString;');
              }
            }
          } else if (defaultValues.containsKey(fieldName)) {
            updateBodyBuffer.writeln('target.$fieldName = ${defaultValues[fieldName]};');
          }
        }

        e.methods.add(
          Method(
            (m) => m
              ..name = 'update${targetClass.name}'
              ..returns = refer('void')
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'target'
                    ..type = refer(targetClass.name ?? ''),
                ),
              )
              ..body = Code(updateBodyBuffer.toString()),
          ),
        );
      }
    });

    final emitter = DartEmitter();
    final result = StringBuffer(extensionBuilder.accept(emitter).toString());

    if (generateListMapper) {
      final listExtensionBuilder = Extension(
        (e) => e
          ..name = '${extensionName}List'
          ..on = refer('Iterable<${sourceClass.name}>')
          ..methods.add(
            Method(
              (m) => m
                ..name = '${methodName}List'
                ..returns = refer('List<${targetClass.name}>')
                ..body = Code('return map((e) => e.$methodName()).toList();'),
            ),
          ),
      );
      result.writeln();
      result.writeln(listExtensionBuilder.accept(emitter).toString());
    }

    if (generateReverse) {
      final reverseFieldMaps = fieldMaps.map((k, v) => MapEntry(v, k));
      final reverseIgnoreFields = fieldMaps.entries
          .where((e) => ignoreFields.contains(e.value))
          .map((e) => e.key)
          .toList();
      final reverseCodeBody = MappingBodyBuilder.build(
        sourceClass: targetClass,
        targetClass: sourceClass,
        sourceVarName: 'this',
        mapperClass: null,
        elementContext: elementContext,
        extensionMethodName: reverseMethodName,
        ignoreFields: reverseIgnoreFields,
        fieldMaps: reverseFieldMaps,
        converters: converters,
        strictMode: strictMode,
      );

      final reverseExtensionName =
          '${targetClass.name}${reverseMethodName[0].toUpperCase()}${reverseMethodName.substring(1)}';

      final reverseExtensionBuilder = Extension((e) {
        e
          ..name = reverseExtensionName
          ..on = refer(targetClass.name ?? '')
          ..methods.add(
            Method(
              (m) => m
                ..name = reverseMethodName
                ..returns = refer(sourceClass.name ?? '')
                ..body = Code(reverseCodeBody),
            ),
          );

        if (generateUpdateMethod) {
          final updateBodyBuffer = StringBuffer();

          final sourceFieldNames = <String>{};
          final sourceFieldTypes = <String, DartType>{};
          for (final f in targetClass.fields) {
            if (!f.isStatic && f.name != null) {
              sourceFieldNames.add(f.name!);
              sourceFieldTypes[f.name!] = f.type;
            }
          }
          for (final g in targetClass.getters) {
            if (!g.isStatic && g.name != null) {
              sourceFieldNames.add(g.name!);
              sourceFieldTypes[g.name!] = g.returnType;
            }
          }

          for (final field in sourceClass.fields) {
            final fieldName = field.name;
            if (fieldName == null || field.isStatic || field.isFinal || field.setter == null) {
              continue;
            }
            if (reverseIgnoreFields.contains(fieldName)) {
              continue;
            }

            final sourceFieldName = fieldMaps[fieldName] ?? fieldName;

            bool hasSourceField = sourceFieldNames.contains(sourceFieldName);
            ResolvedNestedField? nestedField;

            if (!hasSourceField) {
              nestedField = resolveNestedField(
                targetClass,
                sourceFieldName,
                'this',
              );
              if (nestedField != null) {
                hasSourceField = true;
              }
            }

            if (hasSourceField) {
              final sourceFieldType = nestedField?.type ?? sourceFieldTypes[sourceFieldName];
              final accessString = nestedField?.path ?? 'this.$sourceFieldName';
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
                    'if ($accessString case final $fieldName?) target.$fieldName = $targetEnumName.values.byName($fieldName.name);',
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
                    'if ($accessString case final $fieldName?) target.$fieldName = $fieldName;',
                  );
                } else {
                  updateBodyBuffer.writeln('target.$fieldName = $accessString;');
                }
              }
            }
          }

          e.methods.add(
            Method(
              (m) => m
                ..name = 'update${sourceClass.name}'
                ..returns = refer('void')
                ..requiredParameters.add(
                  Parameter(
                    (p) => p
                      ..name = 'target'
                      ..type = refer(sourceClass.name ?? ''),
                  ),
                )
                ..body = Code(updateBodyBuffer.toString()),
            ),
          );
        }
      });

      result.writeln();
      result.writeln(reverseExtensionBuilder.accept(emitter).toString());

      if (generateListMapper) {
        final listExtensionBuilder = Extension(
          (e) => e
            ..name = '${reverseExtensionName}List'
            ..on = refer('Iterable<${targetClass.name}>')
            ..methods.add(
              Method(
                (m) => m
                  ..name = '${reverseMethodName}List'
                  ..returns = refer('List<${sourceClass.name}>')
                  ..body = Code('return map((e) => e.$reverseMethodName()).toList();'),
              ),
            ),
        );
        result.writeln();
        result.writeln(listExtensionBuilder.accept(emitter).toString());
      }
    }

    return result.toString();
  }
}
