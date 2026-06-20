import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

import '../core/mapping_body_builder.dart';
import '../utils/annotation_parser.dart';
import '../utils/switch_builder.dart';

/// Generates an implementation class for an abstract mapper class.
class AbstractClassGenerator {
  static String generate({
    required ClassElement element,
    required ConstantReader annotation,
  }) {
    final constructors = element.constructors
        .where((c) => !c.isFactory)
        .toList();

    final classBuilder = Class((c) {
      c
        ..name = '${element.name}Impl'
        ..extend = refer(element.name ?? '')
        ..methods.addAll(
          element.methods
              .where((m) => m.isAbstract)
              .map((m) => _generateMethod(m, element, annotation)),
        );

      for (final constructor in constructors) {
        if ((constructor.name == null || constructor.name!.isEmpty) &&
            constructor.formalParameters.isEmpty) {
          continue;
        }

        c.constructors.add(
          Constructor((cb) {
            final cName = constructor.name;
            cb.name = (cName == null || cName.isEmpty || cName == 'new')
                ? null
                : cName;

            if (cb.name != null) {
              cb.initializers.add(Code('super.${cb.name}()'));
            }
            for (final param in constructor.formalParameters) {
              final parameterBuilder = Parameter((pb) {
                pb
                  ..name = param.name ?? ''
                  ..toSuper = true
                  ..named = param.isNamed
                  ..required = param.isRequiredNamed;
                if (param.hasDefaultValue && param.defaultValueCode != null) {
                  pb.defaultTo = Code(param.defaultValueCode!);
                }
              });
              if (param.isOptional) {
                cb.optionalParameters.add(parameterBuilder);
              } else {
                cb.requiredParameters.add(parameterBuilder);
              }
            }
          }),
        );
      }
    });

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

    final config = AnnotationParser.parse(annotation);
    final subclasses = <String, String>{};
    for (final meta in method.metadata.annotations) {
      final obj = meta.computeConstantValue();
      if (obj != null && obj.type?.element?.name == 'SubclassMapping') {
        final sTypeDart = obj.getField('source')?.toTypeValue();
        final tTypeDart = obj.getField('target')?.toTypeValue();
        final sType = sTypeDart?.getDisplayString();
        final tType = tTypeDart?.getDisplayString();
        final sMethodName = obj.getField('methodName')?.toStringValue();
        if (sType != null &&
            tType != null &&
            sTypeDart?.element != null &&
            tTypeDart?.element != null &&
            sType != 'dynamic' &&
            tType != 'dynamic') {
          if (sMethodName != null) {
            subclasses[sType] = sMethodName;
          } else {
            // Find a method in the abstract class that matches source and target
            String? foundMethod;
            for (final m in mapperClass.methods) {
              if (m.isAbstract && m.formalParameters.length == 1) {
                if (m.returnType.element == tTypeDart?.element &&
                    m.formalParameters.first.type.element ==
                        sTypeDart?.element) {
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

    for (final field in targetClass.fields) {
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
              if (config.fieldMaps.values.contains(fieldName)) {
                throw InvalidGenerationSourceError(
                  'Conflict: The field "$fieldName" is mapped in both @OmniField and mappings. Please remove one of the definitions.',
                  element: field,
                );
              }
              config.fieldMaps[name] = fieldName;
            }
          }
        }
      }
    }

    for (final sClass in sourceClasses) {
      for (final field in sClass.fields) {
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
                if (config.fieldMaps.containsKey(fieldName)) {
                  throw InvalidGenerationSourceError(
                    'Conflict: The field "$fieldName" is mapped in both @OmniField and mappings. Please remove one of the definitions.',
                    element: field,
                  );
                }
                config.fieldMaps[fieldName] = name;
              }
            }
          }
        }
      }
    }

    var codeBody = MappingBodyBuilder.build(
      sourceClasses: sourceClasses,
      targetClass: targetClass,
      sourceVarNames: sourceVarNames,
      mapperClass: mapperClass,
      elementContext: mapperClass,
      ignoreFields: config.ignoreFields,
      fieldMaps: config.fieldMaps,
      defaultValues: config.defaultValues,
      customMappings: config.customMappings,
      converters: config.converters,
      uses: config.uses,
      strictMode: config.strictMode,
      hookType: config.hookType,
    );

    if (subclasses.isNotEmpty) {
      codeBody = SwitchBuilder.build(
        codeBody: codeBody,
        subclasses: subclasses,
        sourceVarName: sourceVarNames.first,
      );
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
