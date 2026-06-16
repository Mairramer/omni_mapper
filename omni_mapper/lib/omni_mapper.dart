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

  const OmniMapper({
    this.target,
    this.from,
    this.methodName = 'toEntity',
    this.ignoreFields = const [],
  }) : assert(!(target != null && from != null),
            'You cannot specify both `target` and `from` in the same annotation. Use multiple @OmniMapper annotations instead.');
}
