library;

/// Annotation used to generate mapping code for a class.
///
/// The `mapper_generator` supports two main approaches:
///
/// ### 1. Decentralized Extensions (Recommended)
/// You can add multiple `@Mapper` annotations on your Model class to generate
/// extension methods that convert between layers.
///
/// **Mapping TO a target (Model -> Entity):**
/// ```dart
/// @Mapper(target: SolidesUser) // Default method is 'toEntity'
/// class SolidesUserModel { ... }
/// ```
/// Generates: `extension on SolidesUserModel { SolidesUser toEntity() { ... } }`
///
/// **Mapping FROM a source (Entity -> Model):**
/// ```dart
/// @Mapper(from: SolidesUser, methodName: 'toModel')
/// class SolidesUserModel { ... }
/// ```
/// Generates: `extension on SolidesUser { SolidesUserModel toModel() { ... } }`
///
/// ### 2. Centralized Abstract Class (SmartStruct style)
/// If you prefer a centralized mapper, annotate an abstract class without target/from:
/// ```dart
/// @Mapper()
/// abstract class SolidesUserMapper {
///   SolidesUser toEntity(SolidesUserModel model);
/// }
/// ```
class Mapper {
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

  const Mapper({
    this.target,
    this.from,
    this.methodName = 'toEntity',
    this.ignoreFields = const [],
  }) : assert(!(target != null && from != null),
            'You cannot specify both `target` and `from` in the same annotation. Use multiple @Mapper annotations instead.');
}
