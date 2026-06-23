import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

import '../core/mapper_config.dart';
import '../core/nested_field_resolver.dart';

class UpdateMethodBuilder {
  static Method build({
    required ClassElement sourceClass,
    required ClassElement targetClass,
    required String methodName,
    required Map<String, String> fieldMaps,
    required List<String> ignoreFields,
    required Map<String, DefaultValueConfig> defaultValues,
    required bool ignoreIfNull,
    required String globalCollectionUpdateStrategy,
    required Map<String, String> fieldCollectionUpdateStrategies,
  }) {
    final updateBodyBuffer = StringBuffer();

    final sourceFieldNames = <String>{};
    final sourceFieldTypes = <String, DartType>{};
    final typesToCheck = <InterfaceElement>[
      sourceClass,
      ...sourceClass.allSupertypes
          .map((t) => t.element)
          .whereType<InterfaceElement>(),
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
      if (fieldName == null || field.isStatic) {
        continue;
      }
      
      final targetFieldType = field.type;
      final isCollection = targetFieldType.isDartCoreList || targetFieldType.isDartCoreSet || targetFieldType.isDartCoreMap;
      final strategyStr = fieldCollectionUpdateStrategies[fieldName] ?? globalCollectionUpdateStrategy;
      final isMutatingCollection = isCollection && (strategyStr == 'CollectionUpdateStrategy.clearAndAddAll' || strategyStr == 'CollectionUpdateStrategy.append');

      if ((field.isFinal || field.setter == null) && !isMutatingCollection) {
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
        final sourceFieldType =
            nestedField?.type ?? sourceFieldTypes[sourceFieldName];
        String accessString;
        if (nestedField != null) {
          accessString = nestedField.path;
          if (accessString.startsWith('target.') ||
              accessString.startsWith('target?.')) {
            accessString = 'this.$accessString';
          }
        } else {
          accessString = sourceFieldName == 'target'
              ? 'this.$sourceFieldName'
              : sourceFieldName;
        }
        final targetFieldType = field.type;
        final sourceTypeElement = sourceFieldType?.element;
        final targetTypeElement = targetFieldType.element;

        final isNullable =
            sourceFieldType?.nullabilitySuffix == NullabilitySuffix.question ||
            accessString.contains('?.');
        final targetNullable =
            targetFieldType.nullabilitySuffix == NullabilitySuffix.question;

        final isCollection = targetFieldType.isDartCoreList || targetFieldType.isDartCoreSet || targetFieldType.isDartCoreMap;
        final strategyStr = fieldCollectionUpdateStrategies[fieldName] ?? globalCollectionUpdateStrategy;
        final isClearAndAddAll = isCollection && strategyStr == 'CollectionUpdateStrategy.clearAndAddAll';
        final isAppend = isCollection && strategyStr == 'CollectionUpdateStrategy.append';

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
        } else if (isClearAndAddAll || isAppend) {
          final targetAccess = targetNullable ? 'target.$fieldName?' : 'target.$fieldName';
          final clearCall = isClearAndAddAll ? '  $targetAccess.clear();\n' : '';
          if (ignoreIfNull && isNullable) {
            updateBodyBuffer.writeln(
              'if ($accessString case final $fieldName?) {\n$clearCall  $targetAccess.addAll($fieldName);\n}',
            );
          } else if (isNullable) {
            updateBodyBuffer.writeln(
              'if ($accessString != null) {\n$clearCall  $targetAccess.addAll($accessString!);\n}',
            );
          } else {
            updateBodyBuffer.writeln(
              '$clearCall  $targetAccess.addAll($accessString);',
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
