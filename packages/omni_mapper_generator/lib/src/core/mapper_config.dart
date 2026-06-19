import 'package:analyzer/dart/element/type.dart';

class MapperConfig {
  final List<String> ignoreFields;
  final Map<String, String> fieldMaps;
  final Map<String, String> defaultValues;
  final Map<String, String> customMappings;
  final List<DartType> converters;
  final bool strictMode;
  final DartType? hookType;
  final bool generateListMapper;
  final bool generateUpdateMethod;
  final bool ignoreIfNull;
  final bool generateReverse;
  final String reverseMethodName;
  final String methodName;

  MapperConfig({
    required this.ignoreFields,
    required this.fieldMaps,
    required this.defaultValues,
    required this.customMappings,
    required this.converters,
    required this.strictMode,
    this.hookType,
    this.generateListMapper = true,
    this.generateUpdateMethod = true,
    this.ignoreIfNull = false,
    this.generateReverse = false,
    this.reverseMethodName = '',
    this.methodName = 'toEntity',
  });
}
