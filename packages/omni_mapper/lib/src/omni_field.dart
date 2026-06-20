/// @docImport 'omni_mapper_annotation.dart';
library;

/// An annotation used to configure mapping behaviors on a per-field basis.
///
/// Use this annotation directly on the fields of a class annotated with
/// [OmniMapper] to configure how that specific field maps to the other class.
///
/// ```dart
/// @OmniMapper(target: UserEntity)
/// class UserModel {
///   @OmniField(name: 'user_id')
///   final String id;
/// }
/// ```
class OmniField {
  /// Creates an [OmniField].
  const OmniField({
    this.name,
  });

  /// The alias name for this field in the target or source class.
  ///
  /// If the class containing this field is configured as the target
  /// (mapping from another class), this specifies the name of the source field.
  ///
  /// If the class containing this field is configured as the source
  /// (mapping to another class), this specifies the name of the target field.
  final String? name;
}
