import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'generators/abstract_class_generator.dart';
import 'generators/extension_generator.dart';

class MapperGenerator extends Generator {
  final typeChecker = const TypeChecker.fromUrl('package:omni_mapper/omni_mapper.dart#OmniMapper');

  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final values = <String>[];
    for (final element in library.allElements) {
      if (element is ClassElement) {
        final annotations = typeChecker.annotationsOf(element);
        for (final annotation in annotations) {
          values.add(generateForAnnotatedElement(element, ConstantReader(annotation), buildStep));
        }
      }
    }
    return values.join('\n\n');
  }

  String generateForAnnotatedElement(
    ClassElement element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
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
        throw InvalidGenerationSourceError('`from` must be a class.', element: element);
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
