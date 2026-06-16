import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';
import '../core/mapping_body_builder.dart';

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
    final capitalizedMethodName =
        methodName.isNotEmpty ? '${methodName[0].toUpperCase()}${methodName.substring(1)}' : 'Mapper';
    
    // Ensure unique name by combining Source class and capitalized method name
    final extensionName = '${sourceClass.name}$capitalizedMethodName';

    final ignoreFields = annotation
            .peek('ignoreFields')
            ?.listValue
            .map((e) => e.toStringValue() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        const [];

    final codeBody = MappingBodyBuilder.build(
      sourceClass: sourceClass,
      targetClass: targetClass,
      sourceVarName: 'this',
      mapperClass: null,
      elementContext: elementContext,
      extensionMethodName: methodName,
      ignoreFields: ignoreFields,
    );

    final extensionBuilder = Extension((e) => e
      ..name = extensionName
      ..on = refer(sourceClass.name ?? '')
      ..methods.add(Method(
        (m) => m
          ..name = methodName
          ..returns = refer(targetClass.name ?? '')
          ..body = Code(codeBody),
      )));

    final emitter = DartEmitter();
    return extensionBuilder.accept(emitter).toString();
  }
}
