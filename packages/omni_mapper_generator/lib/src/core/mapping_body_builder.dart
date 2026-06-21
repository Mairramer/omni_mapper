import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import 'mapper_config.dart';
import 'nested_field_resolver.dart';

/// Information about a resolved field used during mapping generation.
class ResolvedFieldInfo {
  final DartType type;
  final String accessString;
  final ClassElement sourceClass;

  ResolvedFieldInfo(this.type, this.accessString, this.sourceClass);
}

/// Builds the method body for mapping a source object to a target object.
class MappingBodyBuilder {
  static String build({
    required List<ClassElement> sourceClasses,
    required ClassElement targetClass,
    required List<String> sourceVarNames,
    required ClassElement? mapperClass,
    required Element elementContext,
    String extensionMethodName = 'toEntity',
    List<String> ignoreFields = const [],
    Map<String, String> fieldMaps = const {},
    Map<String, DefaultValueConfig> defaultValues = const {},
    Map<String, String> customMappings = const {},
    List<DartType> converters = const [],
    List<DartType> uses = const [],
    bool strictMode = false,
    DartType? hookType,
  }) {
    // Collect all source fields into a structured map for quick checking
    // name -> list of matching fields (to detect ambiguity)
    final availableSourceFields = <String, List<ResolvedFieldInfo>>{};

    for (var i = 0; i < sourceClasses.length; i++) {
      final sClass = sourceClasses[i];
      final sVar = sourceVarNames[i];
      String getAccess(String name) => sVar == 'this' ? name : '$sVar.$name';

      final addedAccesses = <String>{};

      void tryAdd(String name, DartType type) {
        final access = getAccess(name);
        if (!addedAccesses.contains(access)) {
          addedAccesses.add(access);
          availableSourceFields.putIfAbsent(name, () => []).add(ResolvedFieldInfo(type, access, sClass));
        }
      }

      final typesToCheck = <InterfaceElement>[
        sClass,
        ...sClass.allSupertypes.map((t) => t.element).whereType<InterfaceElement>(),
      ];

      for (final element in typesToCheck) {
        if (element.name == 'Object') {
          continue;
        }
        for (final f in element.fields) {
          if (!f.isStatic && f.name != null) {
            tryAdd(f.name!, f.type);
          }
        }
        for (final g in element.getters) {
          if (!g.isStatic && g.name != null) {
            tryAdd(g.name!, g.returnType);
          }
        }
      }
    }

    ResolvedFieldInfo? resolveField(String targetFieldName) {
      String sourceFieldName = targetFieldName;
      for (final entry in fieldMaps.entries) {
        if (entry.value == targetFieldName) {
          sourceFieldName = entry.key;
          break;
        }
      }

      // Check explicit dot notation in fieldMaps for explicit source targeting
      // E.g., {'user.name': 'fullName'}
      if (sourceFieldName.contains('.')) {
        final parts = sourceFieldName.split('.');
        final prefix = parts.first;
        final rest = parts.skip(1).join('.');

        // 1. Check if prefix matches a parameter name (Multiple Sources)
        for (var i = 0; i < sourceVarNames.length; i++) {
          if (sourceVarNames[i] == prefix) {
            final sClass = sourceClasses[i];
            final nestedField = resolveNestedField(
              sClass,
              rest,
              sourceVarNames[i] == 'this' ? '' : sourceVarNames[i],
            );
            if (nestedField != null) {
              return ResolvedFieldInfo(
                nestedField.type,
                nestedField.path,
                sClass,
              );
            }
          }
        }

        // 2. Check if the entire path resolves against ANY source (e.g., Extension Mappers or nested structures)
        for (var i = 0; i < sourceVarNames.length; i++) {
          final sClass = sourceClasses[i];
          final varName = sourceVarNames[i];
          final nestedField = resolveNestedField(
            sClass,
            sourceFieldName,
            varName == 'this' ? '' : varName,
          );
          if (nestedField != null) {
            return ResolvedFieldInfo(
              nestedField.type,
              nestedField.path,
              sClass,
            );
          }
        }
      }

      final directMatches = availableSourceFields[sourceFieldName];
      if (directMatches != null && directMatches.isNotEmpty) {
        if (directMatches.length > 1) {
          throw InvalidGenerationSourceError(
            'Ambiguous mapping for target field "$targetFieldName". It exists in multiple source classes. Please map it explicitly using fieldMaps.',
            element: elementContext,
          );
        }
        return directMatches.first;
      }

      // Try nested resolution if no direct match
      final nestedMatches = <ResolvedFieldInfo>[];
      for (var i = 0; i < sourceClasses.length; i++) {
        final nestedField = resolveNestedField(
          sourceClasses[i],
          sourceFieldName,
          sourceVarNames[i] == 'this' ? '' : sourceVarNames[i],
        );
        if (nestedField != null) {
          nestedMatches.add(
            ResolvedFieldInfo(
              nestedField.type,
              nestedField.path,
              sourceClasses[i],
            ),
          );
        }
      }

      if (nestedMatches.isNotEmpty) {
        if (nestedMatches.length > 1) {
          throw InvalidGenerationSourceError(
            'Ambiguous nested mapping for target field "$targetFieldName". It exists in multiple source classes. Please map it explicitly using fieldMaps.',
            element: elementContext,
          );
        }
        return nestedMatches.first;
      }

      return null;
    }

    if (targetClass.isAbstract) {
      return "throw UnsupportedError('Cannot instantiate abstract class ${targetClass.name}. Did you forget to map all subclasses?');\n";
    }

    final targetConstructor =
        targetClass.constructors.where((c) => (c.name == null || c.name!.isEmpty) && !c.isPrivate).firstOrNull ??
        targetClass.constructors.where((c) => !c.isPrivate).firstOrNull ??
        targetClass.constructors.first;

    final assignedParams = <String>[];
    final codeBuffer = StringBuffer();

    final hookName = hookType?.element?.name;

    // Before Hook
    if (hookName != null) {
      codeBuffer.writeln(
        'const $hookName().before(${sourceVarNames.first == 'this' ? 'this' : sourceVarNames.first});',
      );
    }

    codeBuffer.writeln('final target = ${targetClass.name}(');

    final targetParams = targetConstructor.formalParameters;
    for (final param in targetParams) {
      final paramName = param.name;
      if (paramName == null) {
        continue;
      }
      if (ignoreFields.contains(paramName)) {
        continue;
      }

      final defaultValue = defaultValues[paramName];
      if (defaultValue != null && defaultValue.type != null && !defaultValue.type!.isDartCoreString) {
        if (!targetClass.library.typeSystem.isAssignableTo(defaultValue.type!, param.type)) {
          throw InvalidGenerationSourceError(
            'Type mismatch for default value of "$paramName": expected ${param.type.getDisplayString()} but got ${defaultValue.type!.getDisplayString()}.',
            element: elementContext,
          );
        }
      }

      if (customMappings.containsKey(paramName)) {
        if (param.isNamed) {
          codeBuffer.writeln('$paramName: ${customMappings[paramName]},');
        } else {
          codeBuffer.writeln('${customMappings[paramName]},');
        }
        assignedParams.add(paramName);
        continue;
      }

      final resolved = resolveField(paramName);

      if (resolved != null) {
        final sourceFieldType = resolved.type;
        final accessString = resolved.accessString;
        final targetFieldType = param.type;
        MethodElement? nestedMapper;
        DartType? matchingConverter;

        // Check for matching converter
        if (sourceFieldType.element != targetFieldType.element) {
          for (final converter in converters) {
            final classElement = converter.element;
            if (classElement is ClassElement) {
              final omniConverter = classElement.allSupertypes
                  .where((t) => t.element.name == 'OmniConverter')
                  .firstOrNull;
              if (omniConverter != null && omniConverter.typeArguments.length == 2) {
                final sType = omniConverter.typeArguments[0];
                final tType = omniConverter.typeArguments[1];
                if (sType.element == sourceFieldType.element && tType.element == targetFieldType.element) {
                  matchingConverter = converter;
                  break;
                }
              }
            }
          }
        }

        if (mapperClass != null) {
          final sourceTypeElement = sourceFieldType.element;
          final targetTypeElement = param.type.element;
          if (sourceTypeElement != null && targetTypeElement != null && sourceTypeElement != targetTypeElement) {
            for (final m in mapperClass.methods) {
              if (m.isAbstract && m.formalParameters.length == 1) {
                final retStr = m.returnType.getDisplayString();
                final tgtStr = targetFieldType.getDisplayString();
                final paramStr = m.formalParameters.first.type.getDisplayString();
                final srcStr = sourceFieldType.getDisplayString();

                if (retStr == tgtStr && paramStr == srcStr) {
                  nestedMapper = m;
                  break;
                }
              }
            }
          }
        }

        String? usesInvocation;
        final sTypeStr = sourceFieldType.getDisplayString();
        final tTypeStr = targetFieldType.getDisplayString();

        if (sTypeStr != tTypeStr && matchingConverter == null && nestedMapper == null) {
          for (final useType in uses) {
            final classElement = useType.element;
            if (classElement is ClassElement) {
              final isListMapping = sourceFieldType.isDartCoreList && targetFieldType.isDartCoreList;

              DartType expectedSource = sourceFieldType;
              DartType expectedTarget = targetFieldType;

              if (isListMapping && sourceFieldType is ParameterizedType && targetFieldType is ParameterizedType) {
                expectedSource = (sourceFieldType).typeArguments.first;
                expectedTarget = (targetFieldType).typeArguments.first;
              }

              MethodElement? matchingMethod;
              for (final m in classElement.methods) {
                if (!m.isStatic && m.formalParameters.length == 1) {
                  final retStr = m.returnType.getDisplayString().replaceAll(
                    '?',
                    '',
                  );
                  final tgtStr = expectedTarget.getDisplayString().replaceAll(
                    '?',
                    '',
                  );
                  final paramStr = m.formalParameters.first.type.getDisplayString().replaceAll('?', '');
                  final srcStr = expectedSource.getDisplayString().replaceAll(
                    '?',
                    '',
                  );

                  if (retStr == tgtStr && paramStr == srcStr) {
                    matchingMethod = m;
                    break;
                  }
                }
              }

              if (matchingMethod != null) {
                final callerName = classElement.isAbstract ? '${classElement.name}Impl' : classElement.name;
                String caller = '$callerName()';

                if (mapperClass != null) {
                  String? injectedFieldName;
                  for (final field in mapperClass.fields) {
                    if (field.type.element == classElement) {
                      injectedFieldName = field.name;
                      break;
                    }
                  }
                  if (injectedFieldName == null) {
                    for (final getter in mapperClass.getters) {
                      if (getter.returnType.element == classElement) {
                        injectedFieldName = getter.name;
                        break;
                      }
                    }
                  }

                  if (injectedFieldName != null) {
                    caller = injectedFieldName;
                  }
                }

                if (caller == '$callerName()') {
                  bool hasZeroArgConstructor = false;
                  for (final constructor in classElement.constructors) {
                    if (constructor.name == null || constructor.name!.isEmpty || constructor.name == 'new') {
                      if (constructor.formalParameters.every(
                        (p) => p.isOptional,
                      )) {
                        hasZeroArgConstructor = true;
                        break;
                      }
                    }
                  }

                  if (!hasZeroArgConstructor) {
                    throw InvalidGenerationSourceError(
                      'The dependency ${classElement.name} requires arguments in its constructor. You must inject it via a field or getter.',
                      element: elementContext,
                    );
                  }
                }

                final isPathNullable =
                    sourceFieldType.nullabilitySuffix == NullabilitySuffix.question || accessString.contains('?.');

                if (isListMapping) {
                  usesInvocation =
                      '$accessString${isPathNullable ? '?' : ''}.map((e) => $caller.${matchingMethod.name}(e)).toList()';
                } else {
                  if (isPathNullable) {
                    usesInvocation = '$accessString != null ? $caller.${matchingMethod.name}(($accessString)!) : null';
                  } else {
                    usesInvocation = '$caller.${matchingMethod.name}($accessString)';
                  }
                }

                if (isPathNullable && targetFieldType.nullabilitySuffix != NullabilitySuffix.question) {
                  if (isListMapping) {
                    usesInvocation = '$usesInvocation ?? $defaultValue';
                  } else {
                    usesInvocation =
                        '$accessString != null ? $caller.${matchingMethod.name}(($accessString)!) : $defaultValue';
                  }
                }
                break;
              }
            }
          }
        }

        if (matchingConverter != null) {
          final converterName = matchingConverter.element?.name;
          if (param.isNamed) {
            codeBuffer.writeln(
              '$paramName: const $converterName().convert($accessString),',
            );
          } else {
            codeBuffer.writeln(
              'const $converterName().convert($accessString),',
            );
          }
        } else if (nestedMapper != null) {
          if (param.isNamed) {
            codeBuffer.writeln(
              '$paramName: $accessString != null ? ${nestedMapper.name}(($accessString)!) : null,',
            );
          } else {
            codeBuffer.writeln(
              '$accessString != null ? ${nestedMapper.name}(($accessString)!) : null,',
            );
          }
        } else if (usesInvocation != null) {
          if (param.isNamed) {
            codeBuffer.writeln('$paramName: $usesInvocation,');
          } else {
            codeBuffer.writeln('$usesInvocation,');
          }
        } else {
          final sourceTypeElement = sourceFieldType.element;
          final targetTypeElement = param.type.element;
          if (sourceTypeElement != null && targetTypeElement != null && sourceTypeElement != targetTypeElement) {
            final isPathNullable =
                sourceFieldType.nullabilitySuffix == NullabilitySuffix.question || accessString.contains('?.');

            // Automatic Enum Mapping
            if (sourceTypeElement is EnumElement && targetTypeElement is EnumElement) {
              final targetEnumName = targetTypeElement.name;
              if (isPathNullable) {
                if (param.isNamed) {
                  codeBuffer.writeln(
                    '$paramName: $accessString != null ? $targetEnumName.values.byName(($accessString)!.name) : null,',
                  );
                } else {
                  codeBuffer.writeln(
                    '$accessString != null ? $targetEnumName.values.byName(($accessString)!.name) : null,',
                  );
                }
              } else {
                if (param.isNamed) {
                  codeBuffer.writeln(
                    '$paramName: $targetEnumName.values.byName($accessString.name),',
                  );
                } else {
                  codeBuffer.writeln(
                    '$targetEnumName.values.byName($accessString.name),',
                  );
                }
              }
              assignedParams.add(paramName);
              continue;
            }

            // Automatic Nested Mapping
            if (sourceFieldType.isDartCoreList && targetFieldType.isDartCoreList) {
              // If it's a list, map it
              if (param.isNamed) {
                codeBuffer.writeln(
                  '$paramName: $accessString${isPathNullable ? '?' : ''}.map((e) => e.$extensionMethodName()).toList(),',
                );
              } else {
                codeBuffer.writeln(
                  '$accessString${isPathNullable ? '?' : ''}.map((e) => e.$extensionMethodName()).toList(),',
                );
              }
            } else {
              if (param.isNamed) {
                codeBuffer.writeln(
                  '$paramName: $accessString${isPathNullable ? '?' : ''}.$extensionMethodName(),',
                );
              } else {
                codeBuffer.writeln(
                  '$accessString${isPathNullable ? '?' : ''}.$extensionMethodName(),',
                );
              }
            }
            assignedParams.add(paramName);
            continue;
          }

          final isPathNullable =
              sourceFieldType.nullabilitySuffix == NullabilitySuffix.question || accessString.contains('?.');
          final targetNullable = targetFieldType.nullabilitySuffix == NullabilitySuffix.question;

          String finalAccess = accessString;
          if (isPathNullable && !targetNullable) {
            final defaultValue = defaultValues[paramName];
            if (defaultValue != null) {
              finalAccess = '$accessString ?? $defaultValue';
            } else {
              throw InvalidGenerationSourceError(
                'Nullability mismatch for field "$paramName": source path is nullable but target is not, and no default value is provided.',
                element: elementContext,
              );
            }
          }

          if (param.isNamed) {
            codeBuffer.writeln('$paramName: $finalAccess,');
          } else {
            codeBuffer.writeln('$finalAccess,');
          }
        }
        assignedParams.add(paramName);
      } else {
        // Fallback to default values
        if (defaultValues.containsKey(paramName)) {
          final defaultValue = defaultValues[paramName]!;
          codeBuffer.writeln('$paramName: $defaultValue,');
          assignedParams.add(paramName);
        } else if (param.isRequired) {
          throw InvalidGenerationSourceError(
            'Missing required field "$paramName" to construct ${targetClass.name}. You can provide a `defaultValue` or `fieldMap`.',
            element: elementContext,
          );
        }
      }
    }

    codeBuffer.write(')');

    for (final field in targetClass.fields) {
      final fieldName = field.name;
      if (fieldName == null) {
        continue;
      }

      if (field.isStatic ||
          field.isFinal ||
          field.setter == null ||
          assignedParams.contains(fieldName) ||
          ignoreFields.contains(fieldName)) {
        continue;
      }

      final defaultValue = defaultValues[fieldName];
      if (defaultValue != null && defaultValue.type != null && !defaultValue.type!.isDartCoreString) {
        if (!targetClass.library.typeSystem.isAssignableTo(defaultValue.type!, field.type)) {
          throw InvalidGenerationSourceError(
            'Type mismatch for default value of "$fieldName": expected ${field.type.getDisplayString()} but got ${defaultValue.type!.getDisplayString()}.',
            element: elementContext,
          );
        }
      }

      if (customMappings.containsKey(fieldName)) {
        codeBuffer.write('..$fieldName = ${customMappings[fieldName]}');
        assignedParams.add(fieldName);
        continue;
      }

      final resolved = resolveField(fieldName);
      if (resolved != null) {
        codeBuffer.write('..$fieldName = ${resolved.accessString}');
        assignedParams.add(fieldName);
      }
    }

    codeBuffer.writeln(';');

    // After Hook
    if (hookName != null) {
      codeBuffer.writeln(
        'const $hookName().after(${sourceVarNames.first == 'this' ? 'this' : sourceVarNames.first}, target);',
      );
    }

    if (strictMode) {
      final unmappedFields = <String>{};

      for (final param in targetParams) {
        if (param.name != null &&
            !assignedParams.contains(param.name) &&
            !ignoreFields.contains(param.name) &&
            !param.hasDefaultValue) {
          unmappedFields.add(param.name!);
        }
      }

      for (final field in targetClass.fields) {
        final fieldName = field.name;
        if (fieldName == null || field.isStatic || field.isFinal || field.setter == null) {
          continue;
        }
        if (!assignedParams.contains(fieldName) && !ignoreFields.contains(fieldName) && !field.hasInitializer) {
          unmappedFields.add(fieldName);
        }
      }

      if (unmappedFields.isNotEmpty) {
        throw InvalidGenerationSourceError(
          'Strict mode is enabled, but the following target properties are unmapped: ${unmappedFields.join(', ')}.\n'
          'To fix this, map them from the source, provide a defaultValue, or ignore them using @OmniField or mappings.',
          element: elementContext,
        );
      }
    }

    codeBuffer.writeln('return target;');
    var body = codeBuffer.toString();

    // Optimize single expression returns
    if (hookName == null) {
      final simpleRegex = RegExp(
        r'^final target = ([^;]+);\s*return target;\s*$',
      );
      final match = simpleRegex.firstMatch(body.trim());
      if (match != null) {
        body = 'return ${match.group(1)};\n';
      }
    }

    return body;
  }
}
