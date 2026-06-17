import 'package:analyzer/dart/element/element.dart';
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
          element.methods.where((m) => m.isAbstract).map((m) => _generateMethod(m, element, annotation)),
        ),
    );

    final emitter = DartEmitter();
    return classBuilder.accept(emitter).toString();
  }

  static Method _generateMethod(MethodElement method, ClassElement mapperClass, ConstantReader annotation) {
    final methodParams = method.formalParameters;
    if (methodParams.length != 1) {
      throw InvalidGenerationSourceError(
        'Mapper methods must have exactly one parameter.',
        element: method,
      );
    }

    final sourceParam = methodParams.first;
    final sourceClass = sourceParam.type.element as ClassElement?;
    final targetClass = method.returnType.element as ClassElement?;

    if (sourceClass == null || targetClass == null) {
      throw InvalidGenerationSourceError(
        'Mapper methods must use classes as parameters and return types.',
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

    final strictMode = annotation.peek('strictMode')?.boolValue ?? false;
    final hookType = annotation.peek('hook')?.typeValue;

    final codeBody = MappingBodyBuilder.build(
      sourceClass: sourceClass,
      targetClass: targetClass,
      sourceVarName: sourceParam.name ?? '',
      mapperClass: mapperClass,
      elementContext: mapperClass,
      ignoreFields: ignoreFields,
      strictMode: strictMode,
      hookType: hookType,
    );

    return Method(
      (m) => m
        ..name = method.name
        ..annotations.add(refer('override'))
        ..returns = refer(targetClass.name ?? '')
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = sourceParam.name ?? ''
              ..type = refer(sourceClass.name ?? ''),
          ),
        )
        ..body = Code(codeBody),
    );
  }
}
