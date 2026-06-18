import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

import '../core/mapping_body_builder.dart';

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
        const [];

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

    final codeBody = MappingBodyBuilder.build(
      sourceClasses: sourceClasses,
      targetClass: targetClass,
      sourceVarNames: sourceVarNames,
      mapperClass: mapperClass,
      elementContext: mapperClass,
      ignoreFields: ignoreFields,
      fieldMaps: fieldMaps,
      defaultValues: defaultValues,
      converters: converters,
      strictMode: strictMode,
      hookType: hookType,
    );

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
