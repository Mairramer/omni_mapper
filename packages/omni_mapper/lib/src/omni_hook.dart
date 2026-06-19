/// A hook to inject custom logic during mapping.
///
/// Subclass this to execute code before or after a mapping completes.
/// Provide your subclass type to the [OmniMapper.hook] parameter.
abstract class OmniHook<S, T> {
  const OmniHook();

  /// Called before the target object is instantiated.
  void before(S source) {}

  /// Called after the target object is instantiated, but before it is returned.
  void after(S source, T target) {}
}
