import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import '../core/mapper_config.dart';

class AnnotationParser {
  static String? _parseValue(DartObject? obj) {
    if (obj == null || obj.isNull) {
      return 'null';
    }

    final reader = ConstantReader(obj);
    if (reader.isString) {
      final escaped = reader.stringValue
          .replaceAll(r'\', r'\\')
          .replaceAll("'", r"\'")
          .replaceAll(r'$', r'\$');
      return "'$escaped'";
    }
    if (reader.isInt) {
      return reader.intValue.toString();
    }
    if (reader.isDouble) {
      return reader.doubleValue.toString();
    }
    if (reader.isBool) {
      return reader.boolValue.toString();
    }

    final element = obj.type?.element;
    if (element is EnumElement) {
      final enumName = element.name;
      final valueName = obj.getField('_name')?.toStringValue();
      if (enumName != null && valueName != null) {
        return '$enumName.$valueName';
      }
    }
    if (reader.isList) {
      final items = reader.listValue.map((e) {
        final parsed = _parseValue(e);
        if (parsed == null) {
          throw InvalidGenerationSourceError(
            'Could not parse list item $e. Ensure it is a supported constant type.',
          );
        }
        return parsed;
      });
      return 'const [${items.join(', ')}]';
    }

    if (reader.isMap) {
      final entries = reader.mapValue.entries.map((e) {
        final key = _parseValue(e.key);
        final value = _parseValue(e.value);
        if (key == null || value == null) {
          throw InvalidGenerationSourceError(
            'Could not parse map entry key or value. Key: ${e.key}, Value: ${e.value}. Ensure they are supported constant types.',
          );
        }
        return '$key: $value';
      });
      return 'const {${entries.join(', ')}}';
    }

    try {
      final revived = reader.revive();
      final className = revived.source.fragment;
      if (className.isNotEmpty) {
        final accessor = revived.accessor;
        final constructorName = accessor.isNotEmpty ? '.$accessor' : '';

        final positional = revived.positionalArguments
            .map((e) {
              final parsed = _parseValue(e);
              if (parsed == null) {
                throw InvalidGenerationSourceError(
                  'Could not parse positional argument $e for $className. Ensure it is a supported constant type.',
                );
              }
              return parsed;
            })
            .join(', ');

        final named = revived.namedArguments.entries
            .map((e) {
              final parsed = _parseValue(e.value);
              if (parsed == null) {
                throw InvalidGenerationSourceError(
                  'Could not parse named argument ${e.key}: ${e.value} for $className. Ensure it is a supported constant type.',
                );
              }
              return '${e.key}: $parsed';
            })
            .join(', ');

        final args = [
          if (positional.isNotEmpty) positional,
          if (named.isNotEmpty) named,
        ].join(', ');

        return 'const $className$constructorName($args)';
      }

      if (revived.accessor.isNotEmpty) {
        return revived.accessor;
      }
    } catch (_) {
      // Ignore revive errors
    }

    return null;
  }

  static MapperConfig parse(
    ConstantReader annotation, {
    ClassElement? classElement,
  }) {
    final ignoreFields =
        annotation
            .peek('ignoreFields')
            ?.listValue
            .map((e) => e.toStringValue() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    final fieldMaps = <String, String>{};


    final defaultValuesObj = annotation.peek('defaultValues')?.mapValue;
    final defaultValues = <String, String>{};
    if (defaultValuesObj != null) {
      for (final entry in defaultValuesObj.entries) {
        final key = entry.key?.toStringValue();
        if (key != null) {
          final parsed = _parseValue(entry.value);
          if (parsed != null && parsed != 'null') {
            defaultValues[key] = parsed;
          }
        }
      }
    }

    final customMappings = <String, String>{};
    final mappingsList = annotation.peek('mappings')?.listValue;
    if (mappingsList != null) {
      for (final mapping in mappingsList) {
        final target = mapping.getField('target')?.toStringValue();
        if (target == null) {
          continue;
        }

        final source = mapping.getField('source')?.toStringValue();
        if (source != null) {
          fieldMaps[source] = target;
        }

        final customObj = mapping.getField('custom');
        if (customObj != null && !customObj.isNull) {
          final reader = ConstantReader(customObj);
          if (reader.isString) {
            customMappings[target] = reader.stringValue;
          } else {
            final parsed = _parseValue(customObj);
            if (parsed != null && parsed != 'null') {
              customMappings[target] = parsed;
            }
          }
        }

        final ignore = mapping.getField('ignore')?.toBoolValue() ?? false;
        if (ignore) {
          ignoreFields.add(target);
        }

        final defaultValueObj = mapping.getField('defaultValue');
        if (defaultValueObj != null && !defaultValueObj.isNull) {
          final parsed = _parseValue(defaultValueObj);
          if (parsed != null && parsed != 'null') {
            defaultValues[target] = parsed;
          }
        }
      }
    }

    if (classElement != null) {
      final target = annotation.peek('target')?.typeValue;
      final isSource = target != null;

      for (final field in classElement.fields) {
        final fieldName = field.name;
        if (fieldName == null) {
          continue;
        }

        for (final metadata in field.metadata.annotations) {
          final element = metadata.element;
          if (element is ConstructorElement &&
              element.enclosingElement.name == 'OmniField') {
            final obj = metadata.computeConstantValue();
            if (obj != null) {
              final reader = ConstantReader(obj);
              final name = reader.peek('name')?.stringValue;
              if (name != null) {
                if (isSource) {
                  if (fieldMaps.containsKey(fieldName)) {
                    throw InvalidGenerationSourceError(
                      'Conflict: The field "$fieldName" is mapped in both @OmniField and mappings. Please remove one of the definitions.',
                      element: field,
                    );
                  }
                  fieldMaps[fieldName] = name;
                } else {
                  if (fieldMaps.values.contains(fieldName)) {
                    throw InvalidGenerationSourceError(
                      'Conflict: The field "$fieldName" is mapped in both @OmniField and mappings. Please remove one of the definitions.',
                      element: field,
                    );
                  }
                  fieldMaps[name] = fieldName;
                }
              }
            }
          }
        }
      }
    }

    final converters =
        annotation
            .peek('converters')
            ?.listValue
            .map((e) => e.toTypeValue())
            .whereType<DartType>()
            .toList() ??
        const [];

    final strictMode = annotation.peek('strictMode')?.boolValue ?? false;
    final hookType = annotation.peek('hook')?.typeValue;

    final uses =
        annotation
            .peek('uses')
            ?.listValue
            .map((e) => e.toTypeValue())
            .whereType<DartType>()
            .toList() ??
        const [];

    final generateListMapper =
        annotation.peek('generateListMapper')?.boolValue ?? true;
    final generateUpdateMethod =
        annotation.peek('generateUpdateMethod')?.boolValue ?? true;
    final ignoreIfNull = annotation.peek('ignoreIfNull')?.boolValue ?? false;
    final generateReverse =
        annotation.peek('generateReverse')?.boolValue ?? false;
    final reverseMethodNameRaw =
        annotation.peek('reverseMethodName')?.stringValue ?? '';
    final methodName = annotation.peek('methodName')?.stringValue ?? 'toEntity';

    return MapperConfig(
      ignoreFields: ignoreFields,
      fieldMaps: fieldMaps,
      defaultValues: defaultValues,
      customMappings: customMappings,
      converters: converters,
      strictMode: strictMode,
      hookType: hookType,
      uses: uses,
      generateListMapper: generateListMapper,
      generateUpdateMethod: generateUpdateMethod,
      ignoreIfNull: ignoreIfNull,
      generateReverse: generateReverse,
      reverseMethodName: reverseMethodNameRaw,
      methodName: methodName,
    );
  }
}
