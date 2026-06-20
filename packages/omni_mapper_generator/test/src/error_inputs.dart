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

@ShouldThrow(
  'Both source and target types must be provided in @SubclassMapping.',
)
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

@ShouldThrow(
  'Could not find a method in AbstractMapperInvalid that maps from DummyModel to DummyTarget. Please define one, or specify the methodName in @SubclassMapping.',
)
@OmniMapper()
abstract class AbstractMapperInvalid {
  @SubclassMapping(source: DummyModel, target: DummyTarget)
  DummyTarget toTarget(InvalidSubclassMappingSource source);
}

// --- Missing Injection Constructor Error ---
class DependencyWithArgs {
  final int id;
  DependencyWithArgs(this.id);
}

class DependencyWithArgsTarget {
  final int id;
  DependencyWithArgsTarget(this.id);
}

@OmniMapper()
class DependencyWithArgsMapper {
  final int someArg;
  DependencyWithArgsMapper(this.someArg);
  DependencyWithArgsTarget toTarget(DependencyWithArgs model) => throw UnimplementedError();
}

class ParentSource {
  final DependencyWithArgs child;
  ParentSource(this.child);
}

class ParentTarget {
  final DependencyWithArgsTarget child;
  ParentTarget(this.child);
}

@ShouldThrow(
  'The dependency DependencyWithArgsMapper requires arguments in its constructor. You must inject it via a field or getter.',
)
@OmniMapper(uses: [DependencyWithArgsMapper])
abstract class MissingInjectionMapper {
  ParentTarget toTarget(ParentSource model);
}
