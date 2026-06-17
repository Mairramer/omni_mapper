/// Interface for custom type converters.
/// Implement this class and pass its type to [OmniMapper.converters].
abstract class OmniConverter<S, T> {
  const OmniConverter();
  T convert(S source);
}
