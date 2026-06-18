import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import 'nested_field_resolver.dart';

class MappingBodyBuilder {
  static String build({
    required ClassElement sourceClass,
    required ClassElement targetClass,
    required String sourceVarName,
    required ClassElement? mapperClass,
    required Element elementContext,
    String extensionMethodName = 'toEntity',
    List<String> ignoreFields = const [],
    Map<String, String> fieldMaps = const {},
    Map<String, String> defaultValues = const {},
    List<DartType> converters = const [],
    bool strictMode = false,
    DartType? hookType,
  }) {
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

    ConstructorElement targetConstructor;
    try {
      targetConstructor = targetClass.constructors.firstWhere(
        (c) => (c.name ?? '').isEmpty,
      );
    } catch (_) {
      targetConstructor = targetClass.constructors.first;
    }

    String sourceFieldAccess(String name) => sourceVarName == 'this' ? name : '$sourceVarName.$name';

    final assignedParams = <String>[];
    final codeBuffer = StringBuffer();

    final hookName = hookType?.element?.name;

    // Before Hook
    if (hookName != null) {
      codeBuffer.writeln('$hookName().before(${sourceVarName == 'this' ? 'this' : sourceVarName});');
    }

    codeBuffer.writeln('final target = ${targetClass.name}(');

    final targetParams = targetConstructor.formalParameters;
    for (final param in targetParams) {
      final paramName = param.name;
      if (paramName == null) {
        continue;
      }

      if (ignoreFields.contains(paramName)) {
        continue;
      }

      // Find mapped source field if provided in fieldMaps
      String sourceFieldName = paramName;
      for (final entry in fieldMaps.entries) {
        if (entry.value == paramName) {
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
          sourceVarName == 'this' ? 'this' : sourceVarName,
        );
        if (nestedField != null) {
          hasSourceField = true;
        }
      }

      if (hasSourceField) {
        final sourceFieldType = nestedField?.type ?? sourceFieldTypes[sourceFieldName];
        final accessString = nestedField?.path ?? sourceFieldAccess(sourceFieldName);
        final targetFieldType = param.type;
        MethodElement? nestedMapper;
        DartType? matchingConverter;

        // Check for matching converter
        if (sourceFieldType != null && sourceFieldType.element != targetFieldType.element) {
          for (final converter in converters) {
            final classElement = converter.element;
            if (classElement is ClassElement) {
              final omniConverter = classElement.allSupertypes
                  .where((t) => t.element.name == 'OmniConverter')
                  .firstOrNull;
              if (omniConverter != null && omniConverter.typeArguments.length == 2) {
                final sType = omniConverter.typeArguments[0];
                final tType = omniConverter.typeArguments[1];
                if (sType.element == sourceFieldType.element && tType.element == targetFieldType.element) {
                  matchingConverter = converter;
                  break;
                }
              }
            }
          }
        }

        if (mapperClass != null && sourceFieldType != null) {
          final sourceTypeElement = sourceFieldType.element;
          final targetTypeElement = param.type.element;
          if (sourceTypeElement != null && targetTypeElement != null && sourceTypeElement != targetTypeElement) {
            for (final m in mapperClass.methods) {
              if (m.isAbstract && m.formalParameters.length == 1) {
                if (m.returnType.element == targetTypeElement &&
                    m.formalParameters.first.type.element == sourceTypeElement) {
                  nestedMapper = m;
                  break;
                }
              }
            }
          }
        }

        if (matchingConverter != null) {
          final converterName = matchingConverter.element?.name;
          codeBuffer.writeln('$paramName: const $converterName().convert($accessString),');
        } else if (nestedMapper != null) {
          codeBuffer.writeln('$paramName: $accessString != null ? ${nestedMapper.name}(($accessString)!) : null,');
        } else {
          if (mapperClass == null && sourceFieldType != null) {
            final sourceTypeElement = sourceFieldType.element;
            final targetTypeElement = param.type.element;
            if (sourceTypeElement != null && targetTypeElement != null && sourceTypeElement != targetTypeElement) {
              // Automatic Enum Mapping
              if (sourceTypeElement is EnumElement && targetTypeElement is EnumElement) {
                final targetEnumName = targetTypeElement.name;
                if (sourceFieldType.nullabilitySuffix == NullabilitySuffix.question) {
                  codeBuffer.writeln(
                    '$paramName: $accessString != null ? $targetEnumName.values.byName(($accessString)!.name) : null,',
                  );
                } else {
                  codeBuffer.writeln(
                    '$paramName: $targetEnumName.values.byName($accessString.name),',
                  );
                }
                assignedParams.add(paramName);
                continue;
              }

              // Automatic Nested Mapping
              if (sourceFieldType.isDartCoreList && targetFieldType.isDartCoreList) {
                // If it's a list, map it
                codeBuffer.writeln(
                  '$paramName: $accessString?.map((e) => e.$extensionMethodName()).toList(),',
                );
              } else {
                codeBuffer.writeln('$paramName: $accessString?.$extensionMethodName(),');
              }
              assignedParams.add(paramName);
              continue;
            }
          }

          if (param.isNamed) {
            codeBuffer.writeln('$paramName: $accessString,');
          } else {
            codeBuffer.writeln('$accessString,');
          }
        }
        assignedParams.add(paramName);
      } else {
        // Fallback to default values
        if (defaultValues.containsKey(paramName)) {
          codeBuffer.writeln('$paramName: ${defaultValues[paramName]},');
          assignedParams.add(paramName);
        } else if (param.isRequired) {
          throw InvalidGenerationSourceError(
            'Missing required field "$paramName" from source class ${sourceClass.name} '
            'to construct ${targetClass.name}. You can provide a `defaultValue` or `fieldMap`.',
            element: elementContext,
          );
        }
      }
    }

    codeBuffer.write(')');

    for (final field in targetClass.fields) {
      final fieldName = field.name;
      if (fieldName == null) {
        continue;
      }
      if (field.isStatic ||
          field.isFinal ||
          field.setter == null ||
          assignedParams.contains(fieldName) ||
          ignoreFields.contains(fieldName)) {
        continue;
      }
      bool hasSourceField = sourceFieldNames.contains(fieldName);
      ResolvedNestedField? nestedField;

      if (!hasSourceField) {
        nestedField = resolveNestedField(
          sourceClass,
          fieldName,
          sourceVarName == 'this' ? 'this' : sourceVarName,
        );
        if (nestedField != null) {
          hasSourceField = true;
        }
      }

      if (hasSourceField) {
        final accessString = nestedField?.path ?? sourceFieldAccess(fieldName);
        codeBuffer.write('..$fieldName = $accessString');
        assignedParams.add(fieldName);
      }
    }

    codeBuffer.writeln(';');

    // After Hook
    if (hookName != null) {
      codeBuffer.writeln('$hookName().after(${sourceVarName == 'this' ? 'this' : sourceVarName}, target);');
    }

    if (strictMode) {
      final unmappedFields = <String>{};

      for (final param in targetParams) {
        if (param.name != null &&
            !assignedParams.contains(param.name) &&
            !ignoreFields.contains(param.name) &&
            !param.hasDefaultValue) {
          unmappedFields.add(param.name!);
        }
      }

      for (final field in targetClass.fields) {
        final fieldName = field.name;
        if (fieldName == null || field.isStatic || field.isFinal || field.setter == null) {
          continue;
        }
        if (!assignedParams.contains(fieldName) && !ignoreFields.contains(fieldName) && !field.hasInitializer) {
          unmappedFields.add(fieldName);
        }
      }

      if (unmappedFields.isNotEmpty) {
        throw InvalidGenerationSourceError(
          'Strict mode is enabled, but the following target properties are unmapped: ${unmappedFields.join(', ')}.\n'
          'To fix this, map them from the source, provide a defaultValue, or add them to ignoreFields.',
          element: elementContext,
        );
      }
    }

    codeBuffer.writeln('return target;');
    return codeBuffer.toString();
  }
}
