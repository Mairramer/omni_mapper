import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

import '../core/mapper_config.dart';
import '../core/mapping_body_builder.dart';
import '../utils/annotation_parser.dart';
import '../utils/switch_builder.dart';
import '../utils/update_method_builder.dart';

/// Generates extension methods for mapping between a source class and a target class.
class ExtensionGenerator {
  static String generate({
    required ClassElement sourceClass,
    required DartType targetType,
    required ClassElement elementContext,
    required ConstantReader annotation,
  }) {
    final targetClass = targetType.element as ClassElement?;
    if (targetClass == null) {
      throw InvalidGenerationSourceError(
        'Target must be a class.',
        element: sourceClass,
      );
    }

    final config = AnnotationParser.parse(
      annotation,
      classElement: elementContext,
    );

    final capitalizedMethodName = config.methodName.isNotEmpty
        ? '${config.methodName[0].toUpperCase()}${config.methodName.substring(1)}'
        : 'Mapper';

    // Ensure unique name by combining Source class and capitalized method name
    final extensionName = '${sourceClass.name}$capitalizedMethodName';

    final reverseMethodName = config.reverseMethodName.isEmpty
        ? 'to${sourceClass.name}'
        : config.reverseMethodName;

    final subclassesList = annotation.peek('subclasses')?.listValue ?? [];
    final subclasses = <String, String>{};
    for (final subclassObj in subclassesList) {
      final sTypeDart = subclassObj.getField('source')?.toTypeValue();
      final tTypeDart = subclassObj.getField('target')?.toTypeValue();
      final sType = sTypeDart?.getDisplayString();
      final tType = tTypeDart?.getDisplayString();
      final sMethodName = subclassObj.getField('methodName')?.toStringValue();
      if (sType != null &&
          tType != null &&
          sTypeDart?.element != null &&
          tTypeDart?.element != null &&
          sType != 'dynamic' &&
          tType != 'dynamic') {
        subclasses[sType] = sMethodName ?? 'to${tTypeDart!.element!.name}';
      } else {
        throw InvalidGenerationSourceError(
          'Both source and target types must be provided in @SubclassMapping.',
          element: sourceClass,
        );
      }
    }

    var codeBody = MappingBodyBuilder.build(
      sourceClasses: [sourceClass],
      targetClass: targetClass,
      sourceVarNames: ['this'],
      mapperClass: null,
      elementContext: elementContext,
      extensionMethodName: config.methodName,
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
        sourceVarName: 'this',
        isExtension: true,
      );
    }

    final extensionBuilder = Extension((e) {
      e
        ..name = extensionName
        ..on = refer(sourceClass.name ?? '')
        ..methods.add(
          Method(
            (m) => m
              ..name = config.methodName
              ..returns = refer(targetClass.name ?? '')
              ..body = Code(codeBody),
          ),
        );

      if (config.generateUpdateMethod) {
        e.methods.add(
          UpdateMethodBuilder.build(
            sourceClass: sourceClass,
            targetClass: targetClass,
            methodName: 'update${targetClass.name}',
            fieldMaps: config.fieldMaps,
            ignoreFields: config.ignoreFields,
            defaultValues: config.defaultValues,
            ignoreIfNull: config.ignoreIfNull,
          ),
        );
      }
    });

    final emitter = DartEmitter();
    final result = StringBuffer(extensionBuilder.accept(emitter).toString());

    if (config.generateListMapper) {
      final listExtensionBuilder = Extension(
        (e) => e
          ..name = '${extensionName}List'
          ..on = refer('Iterable<${sourceClass.name}>')
          ..methods.add(
            Method(
              (m) => m
                ..name = '${config.methodName}List'
                ..returns = refer('List<${targetClass.name}>')
                ..body = Code(
                  'return map((e) => e.${config.methodName}()).toList();',
                ),
            ),
          ),
      );
      result.writeln();
      result.writeln(listExtensionBuilder.accept(emitter).toString());
    }

    if (config.generateReverse) {
      final reverseFieldMaps = config.fieldMaps.map((k, v) => MapEntry(v, k));
      final reverseIgnoreFields = config.fieldMaps.entries
          .where((e) => config.ignoreFields.contains(e.value))
          .map((e) => e.key)
          .toList();
      final reverseCodeBody = MappingBodyBuilder.build(
        sourceClasses: [targetClass],
        targetClass: sourceClass,
        sourceVarNames: ['this'],
        mapperClass: null,
        elementContext: elementContext,
        extensionMethodName: reverseMethodName,
        ignoreFields: reverseIgnoreFields,
        fieldMaps: reverseFieldMaps,
        customMappings:
            {}, // Reverse mappings don't automatically mirror custom mappings
        converters: config.converters,
        uses: config.uses,
        strictMode: config.strictMode,
      );

      final reverseExtensionName =
          '${targetClass.name}${reverseMethodName[0].toUpperCase()}${reverseMethodName.substring(1)}';

      final reverseExtensionBuilder = Extension((e) {
        e
          ..name = reverseExtensionName
          ..on = refer(targetClass.name ?? '')
          ..methods.add(
            Method(
              (m) => m
                ..name = reverseMethodName
                ..returns = refer(sourceClass.name ?? '')
                ..body = Code(reverseCodeBody),
            ),
          );

        if (config.generateUpdateMethod) {
          e.methods.add(
            UpdateMethodBuilder.build(
              sourceClass: targetClass,
              targetClass: sourceClass,
              methodName: 'update${sourceClass.name}',
              fieldMaps: reverseFieldMaps,
              ignoreFields: reverseIgnoreFields,
              defaultValues:
                  <
                    String,
                    DefaultValueConfig
                  >{}, // Reverse mappings don't automatically mirror default values
              ignoreIfNull: config.ignoreIfNull,
            ),
          );
        }
      });

      result.writeln();
      result.writeln(reverseExtensionBuilder.accept(emitter).toString());

      if (config.generateListMapper) {
        final listExtensionBuilder = Extension(
          (e) => e
            ..name = '${reverseExtensionName}List'
            ..on = refer('Iterable<${targetClass.name}>')
            ..methods.add(
              Method(
                (m) => m
                  ..name = '${reverseMethodName}List'
                  ..returns = refer('List<${sourceClass.name}>')
                  ..body = Code(
                    'return map((e) => e.$reverseMethodName()).toList();',
                  ),
              ),
            ),
        );
        result.writeln();
        result.writeln(listExtensionBuilder.accept(emitter).toString());
      }
    }

    return result.toString();
  }
}
