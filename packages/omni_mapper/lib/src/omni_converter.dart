/// @docImport 'omni_mapper_annotation.dart';
library;

/// An interface for defining custom type conversions.
///
/// When the generator encounters a field where the source type does not match
/// the target type, it looks for an implementation of this class to convert the
/// value.
///
/// To use a custom converter, implement this class and add its type to the
/// [OmniMapper.converters] list.
///
/// See also:
///
///  * [OmniMapper.converters], where the custom converter types are registered.
abstract class OmniConverter<S, T> {
  const OmniConverter();

  /// Converts the [source] object to the target type [T].
  ///
  /// This method is called during mapping whenever a value of type [S] needs to
  /// be mapped to a field of type [T].
  T convert(S source);
}
