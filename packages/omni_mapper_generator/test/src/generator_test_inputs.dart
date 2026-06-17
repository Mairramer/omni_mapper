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
    return EntityB(id: id, title: title);
  }

  void updateEntityB(EntityB target) {}
}

extension ModelBToEntityList on Iterable<ModelB> {
  List<EntityB> toEntityList() {
    return map((e) => e.toEntity()).toList();
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
    return ModelC(id: id, title: title);
  }

  void updateModelC(ModelC target) {}
}

extension EntityCToModelList on Iterable<EntityC> {
  List<ModelC> toModelList() {
    return map((e) => e.toModel()).toList();
  }
}
''')
@OmniMapper(from: EntityC, methodName: 'toModel')
class ModelC {
  final int id;
  final String title;
  ModelC({required this.id, required this.title});
}

// --- APPROACH D (Advanced Features) ---
class EntityD {
  final int id;
  final String status;
  final DateTime createdAt;
  EntityD({required this.id, required this.status, required this.createdAt});
}

class StringDateConverter extends OmniConverter<String, DateTime> {
  const StringDateConverter();
  @override
  DateTime convert(String source) => DateTime.parse(source);
}

@ShouldGenerate(r'''
extension ModelDToEntity on ModelD {
  EntityD toEntity() {
    return EntityD(
      id: userId,
      status: "active",
      createdAt: const StringDateConverter().convert(createdAt),
    );
  }

  void updateEntityD(EntityD target) {}
}

extension ModelDToEntityList on Iterable<ModelD> {
  List<EntityD> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
''')
@OmniMapper(
  target: EntityD,
  fieldMaps: {'userId': 'id'},
  defaultValues: {'status': '"active"'},
  converters: [StringDateConverter],
  generateListMapper: true,
  generateUpdateMethod: true,
)
class ModelD {
  final int userId;
  final String createdAt;
  ModelD({required this.userId, required this.createdAt});
}

// --- APPROACH E (In-Place Update) ---
class MutableEntityE {
  int id;
  String name;
  MutableEntityE({required this.id, required this.name});
}

@ShouldGenerate(r'''
extension ModelEToMutableEntityE on ModelE {
  MutableEntityE toMutableEntityE() {
    return MutableEntityE(id: id, name: name);
  }

  void updateMutableEntityE(MutableEntityE target) {
    target.id = this.id;
    target.name = this.name;
  }
}

extension ModelEToMutableEntityEList on Iterable<ModelE> {
  List<MutableEntityE> toMutableEntityEList() {
    return map((e) => e.toMutableEntityE()).toList();
  }
}
''')
@OmniMapper(target: MutableEntityE, methodName: 'toMutableEntityE')
class ModelE {
  final int id;
  final String name;
  ModelE({required this.id, required this.name});
}

// --- ERROR SCENARIOS ---
@ShouldThrow('`@OmniMapper` on a concrete class must specify a `target` or `from` type.')
@OmniMapper()
class InvalidConcreteClass {
  final int id;
  InvalidConcreteClass({required this.id});
}
