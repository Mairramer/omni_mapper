import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

import '../core/mapping_body_builder.dart';

/// Generates an implementation class for an abstract mapper class.
class AbstractClassGenerator {
  static String generate({
    required ClassElement element,
    required ConstantReader annotation,
  }) {
    final classBuilder = Class(
      (c) => c
        ..name = '${element.name}Impl'
        ..extend = refer(element.name ?? '')
        ..methods.addAll(
          element.methods
              .where((m) => m.isAbstract)
              .map((m) => _generateMethod(m, element, annotation)),
        ),
    );

    final emitter = DartEmitter();
    return classBuilder.accept(emitter).toString();
  }

  static Method _generateMethod(
    MethodElement method,
    ClassElement mapperClass,
    ConstantReader annotation,
  ) {
    final methodParams = method.formalParameters;
    if (methodParams.isEmpty) {
      throw InvalidGenerationSourceError(
        'Mapper methods must have at least one parameter.',
        element: method,
      );
    }

    final sourceClasses = <ClassElement>[];
    final sourceVarNames = <String>[];
    for (final param in methodParams) {
      final paramClass = param.type.element as ClassElement?;
      if (paramClass == null) {
        throw InvalidGenerationSourceError(
          'Mapper method parameters must be classes.',
          element: method,
        );
      }
      sourceClasses.add(paramClass);
      sourceVarNames.add(param.name ?? '');
    }

    final targetClass = method.returnType.element as ClassElement?;

    if (targetClass == null) {
      throw InvalidGenerationSourceError(
        'Mapper methods must return a class.',
        element: method,
      );
    }

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

    final subclasses = <String, String>{};
    for (final meta in method.metadata.annotations) {
      final obj = meta.computeConstantValue();
      if (obj != null && obj.type?.element?.name == 'SubclassMapping') {
        final sType = obj.getField('source')?.toTypeValue()?.getDisplayString();
        final tType = obj.getField('target')?.toTypeValue()?.getDisplayString();
        final sMethodName = obj.getField('methodName')?.toStringValue();
        if (sType != null && tType != null) {
          if (sMethodName != null) {
            subclasses[sType] = sMethodName;
          } else {
            // Find a method in the abstract class that matches source and target
            String? foundMethod;
            for (final m in mapperClass.methods) {
              if (m.isAbstract && m.formalParameters.length == 1) {
                if (m.returnType.getDisplayString() == tType &&
                    m.formalParameters.first.type.getDisplayString() == sType) {
                  foundMethod = m.name;
                  break;
                }
              }
            }

            if (foundMethod != null) {
              subclasses[sType] = foundMethod;
            } else {
              throw InvalidGenerationSourceError(
                'Could not find a method in ${mapperClass.name} that maps from $sType to $tType. Please define one, or specify the methodName in @SubclassMapping.',
                element: method,
              );
            }
          }
        } else {
          throw InvalidGenerationSourceError(
            'Both source and target types must be provided in @SubclassMapping.',
            element: method,
          );
        }
      }
    }

    var codeBody = MappingBodyBuilder.build(
      sourceClasses: sourceClasses,
      targetClass: targetClass,
      sourceVarNames: sourceVarNames,
      mapperClass: mapperClass,
      elementContext: mapperClass,
      ignoreFields: ignoreFields,
      fieldMaps: fieldMaps,
      defaultValues: defaultValues,
      customMappings: customMappings,
      converters: converters,
      strictMode: strictMode,
      hookType: hookType,
    );

    if (subclasses.isNotEmpty) {
      final sourceVarName = sourceVarNames.first;
      final switchBuffer = StringBuffer();
      switchBuffer.writeln('return switch ($sourceVarName) {');
      for (final entry in subclasses.entries) {
        switchBuffer.writeln('  ${entry.key} s => ${entry.value}(s),');
      }

      final simpleConstructorRegex = RegExp(r'^return ([\s\S]+);\s*$');
      final match = simpleConstructorRegex.firstMatch(codeBody.trim());

      if (match != null) {
        switchBuffer.writeln('  _ => ${match.group(1)},');
      } else {
        switchBuffer.writeln('  _ => () {');
        switchBuffer.writeln(codeBody);
        switchBuffer.writeln('  }(),');
      }
      switchBuffer.writeln('};');
      codeBody = switchBuffer.toString();
    }

    return Method(
      (m) => m
        ..name = method.name
        ..annotations.add(refer('override'))
        ..returns = refer(targetClass.name ?? '')
        ..requiredParameters.addAll(
          methodParams.map(
            (p) => Parameter(
              (pb) => pb
                ..name = p.name ?? ''
                ..type = refer(p.type.getDisplayString()),
            ),
          ),
        )
        ..body = Code(codeBody),
    );
  }
}
