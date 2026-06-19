import 'package:omni_mapper/omni_mapper.dart';
import 'package:source_gen_test/source_gen_test.dart';

// --- ERROR SCENARIOS ---
@ShouldThrow(
  '`@OmniMapper` on a concrete class must specify a `target` or `from` type.',
)
@OmniMapper()
class InvalidConcreteClass {
  final int id;
  InvalidConcreteClass({required this.id});
}
