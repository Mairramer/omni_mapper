import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

class MappingBodyBuilder {
  static String build({
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

      if (ignoreFields.contains(paramName)) continue;

      final hasSourceField = sourceFieldNames.contains(paramName);

      if (hasSourceField) {
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
          final sourceFieldType = sourceFieldTypes[paramName];
          if (mapperClass == null && sourceFieldType != null) {
            final sourceTypeElement = sourceFieldType.element;
            final targetTypeElement = param.type.element;
            if (sourceTypeElement != null && targetTypeElement != null && sourceTypeElement != targetTypeElement) {
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
