/// @docImport 'omni_mapper_annotation.dart';
library;

/// An interface for injecting custom logic into the mapping lifecycle.
///
/// Subclass this to execute arbitrary code immediately before or after a target
/// object is constructed.
///
/// To use a custom hook, provide your subclass type to the [OmniMapper.hook]
/// parameter.
///
/// See also:
///
///  * [OmniMapper.hook], where the hook type is registered.
abstract class OmniHook<S, T> {
  const OmniHook();

  /// Called immediately before the target object is constructed.
  ///
  /// This allows mutating the [source] or performing side effects before the
  /// properties are evaluated for mapping.
  void before(S source) {}

  /// Called immediately after the [target] object is constructed, but before
  /// it is returned from the mapping method.
  ///
  /// This allows applying final mutations or adjustments to the newly created
  /// [target] object.
  void after(S source, T target) {}
}
