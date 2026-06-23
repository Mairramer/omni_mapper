/// @docImport 'omni_mapper_annotation.dart';
library;

import 'collection_update_strategy.dart';

/// A rule that configures how a specific target field is mapped.
///
/// This class provides fine-grained control over individual fields during the
/// code generation process. It allows renaming fields, providing custom Dart
/// expressions, ignoring fields, or setting default values.
///
/// See also:
///
///  * [OmniMapper.mappings], which takes a list of these rules to configure
///    the mapping behavior.
class MappingRule {
  /// Defines the name of the field in the target object.
  ///
  /// This must match the exact name of the property or constructor parameter
  /// in the destination class.
  final String target;

  /// Defines the name of the source field or a path to nested source properties.
  ///
  /// For example, `'user_id'` or `'user.name'`. When provided, the generator
  /// will use this source field instead of looking for a field with the same
  /// name as [target].
  final String? source;

  /// Defines a pure Dart expression evaluated to map the field.
  ///
  /// This allows injecting custom logic into the generated mapping method.
  ///
  /// When generating extension methods on the source class, the properties
  /// of the source object are directly available in scope. For example,
  /// `'firstName + " " + lastName'`.
  ///
  /// When generating a centralized abstract mapper or handling multiple sources,
  /// you must prefix the expression with the parameter name, such as
  /// `'user.firstName'`.
  final Object? custom;

  /// Whether to entirely ignore this field during mapping.
  ///
  /// If set to true, the generator will not attempt to map this field from the
  /// source object. If the target field is required and has no default value,
  /// ignoring it may result in invalid generated code.
  final bool? ignore;

  /// Defines the default value to use if the field is missing from the source.
  ///
  /// The value must be a valid Dart expression represented as a string. For
  /// example, `'"default_string"'`, `'true'`, or `'const []'`.
  final Object? defaultValue;

  /// Overrides the global collection update strategy for this specific field.
  ///
  /// If provided, this strategy will be used when [OmniMapper.generateUpdateMethod]
  /// is true and this field is a collection type.
  final CollectionUpdateStrategy? collectionUpdateStrategy;

  const MappingRule(
    this.target, {
    this.source,
    this.custom,
    this.ignore,
    this.defaultValue,
    this.collectionUpdateStrategy,
  });
}
