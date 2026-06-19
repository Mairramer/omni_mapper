/// @docImport 'omni_mapper_annotation.dart';
library;

/// A rule that configures polymorphic subclass routing for a mapper.
///
/// Use this annotation to instruct the generator to dynamically dispatch
/// mapping based on the runtime type of the source object.
///
/// See also:
///
///  * [OmniMapper.subclasses], which uses this class to configure polymorphic
///    routing for decentralized extension mappers.
class SubclassMapping {
  /// The runtime type of the source object.
  final Type source;

  /// The expected target type to be returned.
  final Type target;

  /// The name of the method to call.
  ///
  /// If provided, the generator will call this specific method.
  /// If omitted, the generator will attempt to infer the method name
  /// (e.g., `toEntity()` for extensions, or searching by type for abstract classes).
  final String? methodName;

  const SubclassMapping({
    required this.source,
    required this.target,
    this.methodName,
  });
}
