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

class DummyModel {
  final int id;
  DummyModel(this.id);
}

class DummyTarget {
  final int id;
  DummyTarget(this.id);
}

@ShouldThrow('Both source and target types must be provided in @SubclassMapping.')
@OmniMapper(
  target: DummyTarget,
  subclasses: [
    SubclassMapping(source: DummyModel, target: dynamic),
  ],
)
class InvalidSubclassMappingSource {
  final int id;
  InvalidSubclassMappingSource({required this.id});
}

@ShouldThrow('Could not find a method in AbstractMapperInvalid that maps from DummyModel to DummyTarget. Please define one, or specify the methodName in @SubclassMapping.')
@OmniMapper()
abstract class AbstractMapperInvalid {
  @SubclassMapping(source: DummyModel, target: DummyTarget)
  DummyTarget toTarget(InvalidSubclassMappingSource source);
}
