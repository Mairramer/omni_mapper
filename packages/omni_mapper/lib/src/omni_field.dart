/// @docImport 'omni_mapper_annotation.dart';
library;

import 'collection_update_strategy.dart';

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
    this.ignore = false,
    this.custom,
    this.defaultValue,
    this.collectionUpdateStrategy,
  });

  /// Defines the alias name for this field in the target or source class.
  ///
  /// If the class containing this field is configured as the target
  /// (mapping from another class), this specifies the name of the source field.
  ///
  /// If the class containing this field is configured as the source
  /// (mapping to another class), this specifies the name of the target field.
  final String? name;

  /// Whether to ignore this field during mapping.
  ///
  /// If `true`, this field will not be mapped to the target.
  final bool ignore;

  /// Defines a custom Dart expression used to map this field.
  ///
  /// For example: `custom: 'source.age.toString()'`
  final Object? custom;

  /// Defines a default value to use if the source field is null or missing.
  ///
  /// For example: `defaultValue: 'active'`
  final Object? defaultValue;

  /// Overrides the global collection update strategy for this specific field.
  ///
  /// If provided, this strategy will be used when [OmniMapper.generateUpdateMethod]
  /// is true and this field is a collection type.
  final CollectionUpdateStrategy? collectionUpdateStrategy;
}
