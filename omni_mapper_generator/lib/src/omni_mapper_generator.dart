import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

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
      return _generateExtensionMapper(element, targetType, element, annotation);
    } else if (fromType != null) {
      // Approach C: Extension on 'from' mapping TO Concrete Model Class
      final fromClass = fromType.element as ClassElement?;
      if (fromClass == null) {
        throw InvalidGenerationSourceError('`from` must be a class.', element: element);
      }
      return _generateExtensionMapper(fromClass, element.thisType, element, annotation);
    } else if (element.isAbstract) {
      // Approach A: Abstract Class Mapper
      return _generateAbstractClassMapper(element, annotation);
    } else {
      throw InvalidGenerationSourceError(
        '`@OmniMapper` on a concrete class must specify a `target` or `from` type.',
        element: element,
      );
    }
  }

  String _generateAbstractClassMapper(ClassElement element, ConstantReader annotation) {
    final classBuilder = Class((c) => c
      ..name = '${element.name}Impl'
      ..extend = refer(element.name ?? '')
      ..methods.addAll(
        element.methods.where((m) => m.isAbstract).map((m) => _generateMethod(m, element, annotation)),
      ));

    final emitter = DartEmitter();
    return classBuilder.accept(emitter).toString();
  }

  String _generateExtensionMapper(
      ClassElement sourceClass, DartType targetType, ClassElement elementContext, ConstantReader annotation) {
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

    final codeBody = _generateMappingBody(
      sourceClass: sourceClass,
      targetClass: targetClass,
      sourceVarName: 'this',
      mapperClass: null, // No mapper class for extensions currently, so deep mapping relies on other extensions
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

  Method _generateMethod(MethodElement method, ClassElement mapperClass, ConstantReader annotation) {
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

    final ignoreFields = annotation
            .peek('ignoreFields')
            ?.listValue
            .map((e) => e.toStringValue() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        const [];

    final codeBody = _generateMappingBody(
      sourceClass: sourceClass,
      targetClass: targetClass,
      sourceVarName: sourceParam.name ?? '',
      mapperClass: mapperClass,
      elementContext: mapperClass,
      ignoreFields: ignoreFields,
    );

    return Method((m) => m
      ..name = method.name
      ..annotations.add(refer('override'))
      ..returns = refer(targetClass.name ?? '')
      ..requiredParameters.add(
        Parameter((p) => p
          ..name = sourceParam.name ?? ''
          ..type = refer(sourceClass.name ?? '')),
      )
      ..body = Code(codeBody));
  }

  String _generateMappingBody({
    required ClassElement sourceClass,
    required ClassElement targetClass,
    required String sourceVarName,
    required ClassElement? mapperClass,
    required Element elementContext,
    String extensionMethodName = 'toEntity',
    List<String> ignoreFields = const [],
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

    final assignedParams = <String>[];

    final codeBuffer = StringBuffer();
    codeBuffer.writeln('return ${targetClass.name}(');

    final targetParams = targetConstructor.formalParameters;
    for (final param in targetParams) {
      final paramName = param.name;
      if (paramName == null) continue;

      // Check if this field should be ignored
      if (ignoreFields.contains(paramName)) continue;

      final hasSourceField = sourceFieldNames.contains(paramName);

      if (hasSourceField) {
        // Try to find a matching method for nested objects (only in Approach A)
        final sourceFieldType = sourceFieldTypes[paramName];
        MethodElement? nestedMapper;

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

        if (nestedMapper != null) {
          codeBuffer.writeln(
              '$paramName: $sourceVarName.$paramName != null ? ${nestedMapper.name}($sourceVarName.$paramName!) : null,');
        } else {
          // If approach B (mapperClass is null), and types are different, we can assume an extension `toEntity()` exists
          final sourceFieldType = sourceFieldTypes[paramName];
          if (mapperClass == null && sourceFieldType != null) {
            final sourceTypeElement = sourceFieldType.element;
            final targetTypeElement = param.type.element;
            if (sourceTypeElement != null && targetTypeElement != null && sourceTypeElement != targetTypeElement) {
              // Append ?.[methodName]()
              codeBuffer.writeln('$paramName: $sourceVarName.$paramName?.$extensionMethodName(),');
              assignedParams.add(paramName);
              continue;
            }
          }

          if (param.isNamed) {
            codeBuffer.writeln('$paramName: $sourceVarName.$paramName,');
          } else {
            codeBuffer.writeln('$sourceVarName.$paramName,');
          }
        }
        assignedParams.add(paramName);
      } else {
        if (param.isRequired) {
          throw InvalidGenerationSourceError(
            'Missing required field "$paramName" from source class ${sourceClass.name} '
            'to construct ${targetClass.name}.',
            element: elementContext,
          );
        }
      }
    }

    codeBuffer.write(')');

    for (final field in targetClass.fields) {
      final fieldName = field.name;
      if (fieldName == null) continue;
      if (field.isStatic ||
          field.isFinal ||
          field.setter == null ||
          assignedParams.contains(fieldName) ||
          ignoreFields.contains(fieldName)) {
        continue;
      }
      if (sourceFieldNames.contains(fieldName)) {
        codeBuffer.write('..$fieldName = $sourceVarName.$fieldName');
      }
    }

    codeBuffer.writeln(';');

    return codeBuffer.toString();
  }
}
