library;

/// Annotation used to generate mapping code for a class.
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
  /// The target type to convert the annotated class INTO.
  /// Use this when generating an extension ON the annotated class.
  final Type? target;

  /// The source type to convert FROM into the annotated class.
  /// Use this when generating an extension ON the `from` type.
  final Type? from;

  /// The name of the generated method. Defaults to 'toEntity'.
  final String methodName;

  /// A list of field names that should be ignored during mapping.
  /// Useful when the target has a field that the source doesn't, or when you want to skip a specific field.
  final List<String> ignoreFields;

  /// A map defining custom field mappings.
  /// The key is the source field name, and the value is the target field name.
  /// Example: `{'user_id': 'id'}` maps `source.user_id` to `target.id`.
  final Map<String, String> fieldMaps;

  /// A map defining default values for target fields if they are missing in the source.
  /// The value should be a valid Dart code snippet (e.g., `'true'` or `'"active"'`).
  final Map<String, String> defaultValues;

  /// A list of converter types that implement `OmniConverter`.
  /// These are used when there's a type mismatch between source and target fields.
  final List<Type> converters;

  /// Whether to generate a list mapping method.
  /// If true, generates an extension like `List<Target> toTargetList()`.
  final bool generateListMapper;

  /// Whether to generate an update method.
  /// If true, generates an extension like `void updateTarget(Target target)`.
  final bool generateUpdateMethod;

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
  }) : assert(
         !(target != null && from != null),
         'You cannot specify both `target` and `from` in the same annotation. Use multiple @OmniMapper annotations instead.',
       );
}

/// Annotation used to define multiple [OmniMapper] mappings for a single class.
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

/// Interface for custom type converters.
/// Implement this class and pass its type to [OmniMapper.converters].
abstract class OmniConverter<S, T> {
  const OmniConverter();
  T convert(S source);
}
