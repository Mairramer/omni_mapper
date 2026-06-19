import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import '../core/mapper_config.dart';

class AnnotationParser {
  static MapperConfig parse(ConstantReader annotation) {
    final ignoreFields =
        annotation
            .peek('ignoreFields')
            ?.listValue
            .map((e) => e.toStringValue() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    final fieldMapsObj = annotation.peek('fieldMaps')?.mapValue;
    final fieldMaps = <String, String>{};
    if (fieldMapsObj != null) {
      for (final entry in fieldMapsObj.entries) {
        final key = entry.key?.toStringValue();
        final value = entry.value?.toStringValue();
        if (key != null && value != null) {
          fieldMaps[key] = value;
        }
      }
    }

    final defaultValuesObj = annotation.peek('defaultValues')?.mapValue;
    final defaultValues = <String, String>{};
    if (defaultValuesObj != null) {
      for (final entry in defaultValuesObj.entries) {
        final key = entry.key?.toStringValue();
        final value = entry.value?.toStringValue();
        if (key != null && value != null) {
          defaultValues[key] = value;
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

        final custom = mapping.getField('custom')?.toStringValue();
        if (custom != null) {
          customMappings[target] = custom;
        }

        final ignore = mapping.getField('ignore')?.toBoolValue() ?? false;
        if (ignore) {
          ignoreFields.add(target);
        }

        final defaultValue = mapping.getField('defaultValue')?.toStringValue();
        if (defaultValue != null) {
          defaultValues[target] = defaultValue;
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
