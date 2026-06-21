/// @docImport 'omni_converter.dart';
/// @docImport 'omni_field.dart';
/// @docImport 'omni_hook.dart';
library;

import 'mapping_rule.dart';
import 'subclass_mapping.dart';

/// An annotation used to configure the generation of mapping code.
///
/// The `omni_mapper_generator` provides two main approaches for mapping:
///
/// ### 1. Decentralized Extensions (Recommended)
///
/// Annotating a class with [OmniMapper] generates extension methods on that
/// class (or on the [from] class) to convert instances between layers.
///
/// **Mapping to a target (Model to Entity):**
/// ```dart
/// @OmniMapper(target: UserEntity)
/// class UserModel { ... }
/// ```
/// This generates: `extension on UserModel { UserEntity toEntity() { ... } }`
///
/// **Mapping from a source (Entity to Model):**
/// ```dart
/// @OmniMapper(from: UserEntity, methodName: 'toModel')
/// class UserModel { ... }
/// ```
/// This generates: `extension on UserEntity { UserModel toModel() { ... } }`
///
/// ### 2. Centralized Abstract Class
///
/// If a centralized mapper is preferred, annotate an abstract class and omit
/// both [target] and [from]. The generator will implement the abstract methods.
///
/// ```dart
/// @OmniMapper()
/// abstract class UserMapper {
///   UserEntity toEntity(UserModel model);
/// }
/// ```
///
/// See also:
///
///  * [OmniMappers], which allows applying multiple [OmniMapper] annotations
///    to a single class.
///  * [MappingRule], which provides fine-grained control over how individual
///    fields are mapped.
class OmniMapper {
  /// The type to which the annotated class is converted.
  ///
  /// This defines the return type of the generated extension method.
  final Type? target;

  /// The type from which the annotated class is converted.
  ///
  /// When this is provided, the extension is generated on this type instead of
  /// the annotated class, and the method will return an instance of the
  /// annotated class.
  final Type? from;

  /// The name of the generated method.
  ///
  /// Defaults to 'toEntity'.
  final String methodName;

  /// A list of field names to ignore during mapping.
  ///
  /// See also:
  ///
  ///  * [MappingRule.ignore], which can also be used to ignore fields.
  @Deprecated(
    'Use mappings with MappingRule instead or field level @OmniField(ignore: true). '
    'Deprecated to unify mapping configurations into a single declarative list. '
    'This feature was deprecated after v0.4.0.',
  )
  final List<String> ignoreFields;

  /// Default values for target fields that are missing in the source.
  ///
  /// The values in this map must be valid Dart code snippets, such as `'true'`
  /// or `'"active"'`.
  ///
  /// See also:
  ///
  ///  * [MappingRule.defaultValue], which provides an alternative way to specify
  ///    default values.
  @Deprecated(
    'Use mappings with MappingRule instead or field level @OmniField(defaultValue: ...). '
    'Deprecated to unify mapping configurations into a single declarative list. '
    'This feature was deprecated after v0.4.0.',
  )
  final Map<String, Object?> defaultValues;

  /// A list of [OmniConverter] types used to handle type mismatches.
  ///
  /// The generator automatically applies these converters when the source and
  /// target field types do not match.
  final List<Type> converters;

  /// Whether to generate a method that maps an iterable of objects.
  ///
  /// If true, generates a method (e.g., `toEntityList`) on `Iterable`.
  /// Defaults to true.
  final bool generateListMapper;

  /// Whether to generate a method that updates an existing target object.
  ///
  /// If true, generates a method (e.g., `updateEntity`) that mutates an existing
  /// instance with values from the source. Defaults to false.
  final bool generateUpdateMethod;

  /// Whether to enforce mapping of all target fields.
  ///
  /// If true, the generator throws an error if any target field is unmapped.
  /// Defaults to false.
  final bool strictMode;

  /// Whether to ignore null source fields when updating an existing object.
  ///
  /// If true, null values in the source object will not overwrite non-null
  /// values in the target object during an update. Defaults to false.
  final bool ignoreIfNull;

  /// The [OmniHook] used to inject custom logic before and after the mapping.
  final Type? hook;

  /// Whether to automatically generate a reverse mapping extension.
  ///
  /// If true, generates an additional extension to map back from the target
  /// to the source. Defaults to false.
  final bool generateReverse;

  /// The name of the generated reverse mapping method.
  ///
  /// If empty, defaults to `to${SourceClassName}`.
  final String reverseMethodName;

  /// A list of rules that configure mapping behaviors on a per-field basis.
  ///
  /// This property provides a declarative alternative to [OmniField]
  /// and allows for custom Dart expressions.
  final List<MappingRule> mappings;

  /// A list of polymorphic mappings for decentralized extensions.
  ///
  /// This instructs the generator to output dynamic routing based on the
  /// runtime type of the source object.
  final List<SubclassMapping> subclasses;

  /// A list of other mapper classes to use for mapping complex nested fields.
  ///
  /// This instructs the generator to invoke methods from the specified mappers
  /// when encountering a type mismatch that is handled by one of those mappers.
  final List<Type> uses;

  const OmniMapper({
    this.target,
    this.from,
    this.methodName = 'toEntity',
    @Deprecated(
      'Use mappings with MappingRule instead or field level @OmniField(ignore: true). '
      'Deprecated to unify mapping configurations into a single declarative list. '
      'This feature was deprecated after v0.4.0.',
    )
    this.ignoreFields = const [],
    @Deprecated(
      'Use mappings with MappingRule instead or field level @OmniField(defaultValue: ...). '
      'Deprecated to unify mapping configurations into a single declarative list. '
      'This feature was deprecated after v0.4.0.',
    )
    this.defaultValues = const {},
    this.converters = const [],
    this.generateListMapper = true,
    this.generateUpdateMethod = false,
    this.strictMode = false,
    this.ignoreIfNull = false,
    this.hook,
    this.generateReverse = false,
    this.reverseMethodName = '',
    this.mappings = const [],
    this.subclasses = const [],
    this.uses = const [],
  }) : assert(
         !(target != null && from != null),
         'You cannot specify both `target` and `from` in the same annotation. Use multiple @OmniMapper annotations instead.',
       );
}

/// An annotation that applies multiple [OmniMapper] configurations to a single class.
///
/// This is useful when a single model needs to be mapped to several different
/// target types.
///
/// ```dart
/// @OmniMappers([
///   OmniMapper(target: EntityA),
///   OmniMapper(target: EntityB, methodName: 'toEntityB'),
/// ])
/// class Model { ... }
/// ```
///
/// See also:
///
///  * [OmniMapper], the annotation used to configure a single mapping.
class OmniMappers {
  final List<OmniMapper> mappers;
  const OmniMappers(this.mappers);
}
