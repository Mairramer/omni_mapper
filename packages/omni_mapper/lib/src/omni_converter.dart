/// A custom type converter.
///
/// Implement this class and pass its type to [OmniMapper.converters].
abstract class OmniConverter<S, T> {
  const OmniConverter();

  /// Converts the [source] object to the target type [T].
  T convert(S source);
}
