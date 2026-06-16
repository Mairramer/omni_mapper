import 'package:omni_mapper/omni_mapper.dart';
import 'package:source_gen_test/source_gen_test.dart';

// --- APPROACH A ---
class EntityA {
  final int id;
  final String title;
  EntityA({required this.id, required this.title});
}

class ModelA {
  final int id;
  final String title;
  ModelA({required this.id, required this.title});
}

@ShouldGenerate(r'''
class MapperAImpl extends MapperA {
  @override
  EntityA toEntity(ModelA model) {
    return EntityA(id: model.id, title: model.title);
  }
}
''')
@OmniMapper()
abstract class MapperA {
  EntityA toEntity(ModelA model);
}

// --- APPROACH B ---
class EntityB {
  final int id;
  final String title;
  EntityB({required this.id, required this.title});
}

@ShouldGenerate(r'''
extension ModelBToEntity on ModelB {
  EntityB toEntity() {
    return EntityB(id: this.id, title: this.title);
  }
}
''')
@OmniMapper(target: EntityB)
class ModelB {
  final int id;
  final String title;
  ModelB({required this.id, required this.title});
}

// --- APPROACH C ---
class EntityC {
  final int id;
  final String title;
  EntityC({required this.id, required this.title});
}

@ShouldGenerate(r'''
extension EntityCToModel on EntityC {
  ModelC toModel() {
    return ModelC(id: this.id, title: this.title);
  }
}
''')
@OmniMapper(from: EntityC, methodName: 'toModel')
class ModelC {
  final int id;
  final String title;
  ModelC({required this.id, required this.title});
}

// --- ERROR SCENARIOS ---
@ShouldThrow('`@OmniMapper` on a concrete class must specify a `target` or `from` type.')
@OmniMapper()
class InvalidConcreteClass {
  final int id;
  InvalidConcreteClass({required this.id});
}
