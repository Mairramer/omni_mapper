library;

export 'src/omni_converter.dart';
export 'src/omni_hook.dart';

/// Configures the generation of mapping code.
///
/// The `omni_mapper_generator` supports two main approaches:
///
/// ### 1. Decentralized Extensions (Recommended)
/// You can add multiple `@OmniMapper` annotations on your Model class to generate
/// extension methods that convert between layers.
///
/// **Mapping TO a target (Model -> Entity):**
/// ```dart
/// @OmniMapper(target: UserEntity) // Default method is 'toEntity'
/// class UserModel { ... }
/// ```
/// Generates: `extension on UserModel { UserEntity toEntity() { ... } }`
///
/// **Mapping FROM a source (Entity -> Model):**
/// ```dart
/// @OmniMapper(from: UserEntity, methodName: 'toModel')
/// class UserModel { ... }
/// ```
/// Generates: `extension on UserEntity { UserModel toModel() { ... } }`
///
/// ### 2. Centralized Abstract Class
/// If you prefer a centralized mapper, annotate an abstract class without target/from:
/// ```dart
/// @OmniMapper()
/// abstract class UserMapper {
///   UserEntity toEntity(UserModel model);
/// }
/// ```
class OmniMapper {
  /// The type to which the annotated class is converted.
  ///
  /// Used when generating an extension on the annotated class.
  final Type? target;

  /// The type from which the annotated class is converted.
  ///
  /// Used when generating an extension on the `from` type.
  final Type? from;

  /// The name of the generated method.
  ///
  /// Defaults to 'toEntity'.
  final String methodName;

  /// The field names to ignore during mapping.
  final List<String> ignoreFields;

  /// Custom field mappings from source field name to target field name.
  ///
  /// For example, `{'user_id': 'id'}` maps `source.user_id` to `target.id`.
  final Map<String, String> fieldMaps;

  /// Default values for target fields missing in the source.
  ///
  /// Values must be valid Dart code snippets (e.g., `'true'` or `'"active"'`).
  final Map<String, String> defaultValues;

  /// The [OmniConverter] types used for type mismatches.
  final List<Type> converters;

  /// Whether to generate a list mapping method.
  final bool generateListMapper;

  /// Whether to generate an update method.
  final bool generateUpdateMethod;

  /// Whether to enforce mapping of all target fields.
  ///
  /// If true, the generator throws an error if any target field is unmapped.
  final bool strictMode;

  /// Whether to ignore null source fields during updates.
  final bool ignoreIfNull;

  /// The [OmniHook] used to inject custom logic.
  final Type? hook;

  /// Whether to automatically generate a reverse mapping extension.
  final bool generateReverse;

  /// The name of the generated reverse mapping method.
  ///
  /// Defaults to `to${SourceClassName}`.
  final String reverseMethodName;

  const OmniMapper({
    this.target,
    this.from,
    this.methodName = 'toEntity',
    this.ignoreFields = const [],
    this.fieldMaps = const {},
    this.defaultValues = const {},
    this.converters = const [],
    this.generateListMapper = true,
    this.generateUpdateMethod = true,
    this.strictMode = false,
    this.ignoreIfNull = false,
    this.hook,
    this.generateReverse = false,
    this.reverseMethodName = '',
  }) : assert(
         !(target != null && from != null),
         'You cannot specify both `target` and `from` in the same annotation. Use multiple @OmniMapper annotations instead.',
       );
}

/// Configures multiple [OmniMapper] mappings for a single class.
///
/// Example:
/// ```dart
/// @OmniMappers([
///   OmniMapper(target: EntityA),
///   OmniMapper(target: EntityB, methodName: 'toEntityB'),
/// ])
/// class Model { ... }
/// ```
class OmniMappers {
  final List<OmniMapper> mappers;
  const OmniMappers(this.mappers);
}
