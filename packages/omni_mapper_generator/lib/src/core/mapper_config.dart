import 'package:analyzer/dart/element/type.dart';

class DefaultValueConfig {
  final String code;
  final DartType? type;

  DefaultValueConfig(this.code, this.type);

  @override
  String toString() => code;
}

class MapperConfig {
  final List<String> ignoreFields;
  final Map<String, String> fieldMaps;
  final Map<String, DefaultValueConfig> defaultValues;
  final Map<String, String> customMappings;
  final List<DartType> converters;
  final bool strictMode;
  final DartType? hookType;
  final List<DartType> uses;
  final bool generateListMapper;
  final bool generateUpdateMethod;
  final bool ignoreIfNull;
  final bool generateReverse;
  final String reverseMethodName;
  final String methodName;
  final String globalCollectionUpdateStrategy;
  final Map<String, String> fieldCollectionUpdateStrategies;

  MapperConfig({
    required this.ignoreFields,
    required this.fieldMaps,
    required this.defaultValues,
    required this.customMappings,
    required this.converters,
    required this.strictMode,
    this.hookType,
    this.uses = const [],
    this.generateListMapper = true,
    this.generateUpdateMethod = true,
    this.ignoreIfNull = false,
    this.generateReverse = false,
    this.reverseMethodName = '',
    this.methodName = 'toEntity',
    this.globalCollectionUpdateStrategy = 'CollectionUpdateStrategy.replace',
    this.fieldCollectionUpdateStrategies = const {},
  });
}
