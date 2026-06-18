import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:omni_mapper/omni_mapper.dart';
import 'package:source_gen/source_gen.dart';

import 'generators/abstract_class_generator.dart';
import 'generators/extension_generator.dart';

class MapperGenerator extends GeneratorForAnnotation<OmniMapper> {
  @override
  String? generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@OmniMapper` can only be applied to classes.',
        element: element,
      );
    }
    return _generateFor(element, annotation);
  }

  String? _generateFor(ClassElement element, ConstantReader annotation) {
    final targetType = annotation.peek('target')?.typeValue;
    final fromType = annotation.peek('from')?.typeValue;

    if (targetType != null) {
      // Approach B: Extension on Concrete Model Class mapping TO target
      return ExtensionGenerator.generate(
        sourceClass: element,
        targetType: targetType,
        elementContext: element,
        annotation: annotation,
      );
    } else if (fromType != null) {
      // Approach C: Extension on 'from' mapping TO Concrete Model Class
      final fromClass = fromType.element as ClassElement?;
      if (fromClass == null) {
        throw InvalidGenerationSourceError(
          '`from` must be a class.',
          element: element,
        );
      }
      return ExtensionGenerator.generate(
        sourceClass: fromClass,
        targetType: element.thisType,
        elementContext: element,
        annotation: annotation,
      );
    } else if (element.isAbstract) {
      // Approach A: Abstract Class Mapper
      return AbstractClassGenerator.generate(
        element: element,
        annotation: annotation,
      );
    } else {
      throw InvalidGenerationSourceError(
        '`@OmniMapper` on a concrete class must specify a `target` or `from` type.',
        element: element,
      );
    }
  }
}

class MultiMapperGenerator extends GeneratorForAnnotation<OmniMappers> {
  @override
  String? generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@OmniMappers` can only be applied to classes.',
        element: element,
      );
    }

    final codeBuffer = StringBuffer();
    final mappers = annotation.read('mappers').listValue;

    for (final mapper in mappers) {
      final mapperReader = ConstantReader(mapper);
      final code = MapperGenerator()._generateFor(element, mapperReader);
      if (code != null) {
        codeBuffer.writeln(code);
      }
    }

    if (codeBuffer.isEmpty) {
      return null;
    }
    return codeBuffer.toString();
  }
}
